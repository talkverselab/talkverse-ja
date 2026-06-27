// 검수 모드 — turn 별 user 메모 (AsyncStorage 기반)
// vi/notes/redpen_review.md 로 export 가능
import AsyncStorage from '@react-native-async-storage/async-storage';

const KEY_PREFIX = 'userMemo:v1:';

class UserMemoImpl {
  private listeners = new Set<() => void>();

  private k(level: string, turn: number) {
    return `${KEY_PREFIX}${level}:${turn}`;
  }

  async get(level: string, turn: number): Promise<string> {
    const v = await AsyncStorage.getItem(this.k(level, turn));
    return v ?? '';
  }

  async set(level: string, turn: number, memo: string): Promise<void> {
    if (memo.trim() === '') {
      await AsyncStorage.removeItem(this.k(level, turn));
    } else {
      await AsyncStorage.setItem(this.k(level, turn), memo);
    }
    this.listeners.forEach((l) => l());
  }

  async has(level: string, turn: number): Promise<boolean> {
    const v = await AsyncStorage.getItem(this.k(level, turn));
    return v !== null && v.trim() !== '';
  }

  async all(level: string): Promise<Array<{ turn: number; memo: string }>> {
    const keys = await AsyncStorage.getAllKeys();
    const target = `${KEY_PREFIX}${level}:`;
    const result: Array<{ turn: number; memo: string }> = [];
    for (const k of keys) {
      if (!k.startsWith(target)) continue;
      const turn = parseInt(k.slice(target.length), 10);
      const memo = await AsyncStorage.getItem(k);
      if (memo) result.push({ turn, memo });
    }
    return result.sort((a, b) => a.turn - b.turn);
  }

  async exportMarkdown(level: string): Promise<string> {
    const memos = await this.all(level);
    if (memos.length === 0) return `# ${level} 검수 메모\n\n(메모 없음)\n`;
    const lines = [`# ${level} 검수 메모`, '', `총 ${memos.length} 개`, ''];
    memos.forEach((m) => {
      lines.push(`## turn ${m.turn}`);
      lines.push(m.memo);
      lines.push('');
    });
    return lines.join('\n');
  }

  addListener(fn: () => void) { this.listeners.add(fn); }
  removeListener(fn: () => void) { this.listeners.delete(fn); }
}

export const UserMemo = new UserMemoImpl();
