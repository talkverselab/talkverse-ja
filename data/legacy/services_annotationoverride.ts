// User 가 빨간펜 annotation 을 폰에서 직접 수정한 결과 (turn 별 override)
// 원본 JSON 의 annotation 위에 override 적용 → 표시
// Export 시 통합 마크다운 가능
import AsyncStorage from '@react-native-async-storage/async-storage';
import type { Annotation } from '../components/AnnotatedText';

const KEY_PREFIX = 'annOverride:v1:';

class AnnotationOverrideImpl {
  private listeners = new Set<() => void>();

  private k(level: string, turn: number) {
    return `${KEY_PREFIX}${level}:${turn}`;
  }

  /** turn 의 override annotations 가져옴 (없으면 null). */
  async get(level: string, turn: number): Promise<Annotation[] | null> {
    const v = await AsyncStorage.getItem(this.k(level, turn));
    if (!v) return null;
    try {
      return JSON.parse(v) as Annotation[];
    } catch {
      return null;
    }
  }

  /** turn 의 annotations 를 전체 교체. null 또는 [] 면 override 제거. */
  async set(level: string, turn: number, anns: Annotation[] | null): Promise<void> {
    if (!anns || anns.length === 0) {
      await AsyncStorage.removeItem(this.k(level, turn));
    } else {
      await AsyncStorage.setItem(this.k(level, turn), JSON.stringify(anns));
    }
    this.listeners.forEach((l) => l());
  }

  /** 원본 + override merge (override 가 있으면 우선) */
  async getEffective(
    level: string,
    turn: number,
    fallback: Annotation[] | undefined
  ): Promise<Annotation[]> {
    const ov = await this.get(level, turn);
    if (ov !== null) return ov;
    return fallback ?? [];
  }

  /** level 의 모든 override turn list */
  async all(level: string): Promise<Array<{ turn: number; annotations: Annotation[] }>> {
    const keys = await AsyncStorage.getAllKeys();
    const target = `${KEY_PREFIX}${level}:`;
    const result: Array<{ turn: number; annotations: Annotation[] }> = [];
    for (const k of keys) {
      if (!k.startsWith(target)) continue;
      const turn = parseInt(k.slice(target.length), 10);
      const raw = await AsyncStorage.getItem(k);
      if (!raw) continue;
      try {
        result.push({ turn, annotations: JSON.parse(raw) });
      } catch {}
    }
    return result.sort((a, b) => a.turn - b.turn);
  }

  /** 마크다운 export — Claude 에게 넘길 수 있는 형식 */
  async exportMarkdown(level: string): Promise<string> {
    const all = await this.all(level);
    if (all.length === 0) return `# ${level} annotation override\n\n(수정 없음)\n`;
    const lines = [`# ${level} 빨간펜 수정`, '', `총 ${all.length} turn`, ''];
    all.forEach((o) => {
      lines.push(`## turn ${o.turn}`);
      lines.push('```json');
      lines.push(JSON.stringify(o.annotations, null, 2));
      lines.push('```');
      lines.push('');
    });
    return lines.join('\n');
  }

  addListener(fn: () => void) { this.listeners.add(fn); }
  removeListener(fn: () => void) { this.listeners.delete(fn); }
}

export const AnnotationOverride = new AnnotationOverrideImpl();
