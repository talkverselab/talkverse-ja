// services/Haptic.ts — Haptic feedback wrapper (Phase 1 UX polish, 2026-05-16).
//
// 디자인 원칙 (2026 mobile UX):
//   * primary action 100ms 안 visual + haptic feedback — 무반응 = "고장"
//   * Haptic 은 *조심스럽게* — 과도하면 배터리·짜증 (Apple HIG)
//   * Web / Haptic 미지원 환경 = silent no-op (try/catch)
//
// expo-haptics 가 설치되지 않은 환경에서도 안전 (dynamic require).
// Production 에서 expo-haptics 추가 시 자동 활성화.

let _Haptics: any = null;
let _initialized = false;

function getHaptics(): any | null {
  if (_initialized) return _Haptics;
  _initialized = true;
  try {
    // dynamic require — bundler 가 미설치 모듈 무시 가능
    // eslint-disable-next-line @typescript-eslint/no-require-imports, @typescript-eslint/no-var-requires
    _Haptics = require('expo-haptics');
  } catch {
    _Haptics = null;
  }
  return _Haptics;
}

function safe(fn: () => Promise<void> | void): Promise<void> {
  try {
    const r = fn();
    if (r && typeof (r as Promise<void>).catch === 'function') {
      return (r as Promise<void>).catch(() => undefined);
    }
    return Promise.resolve();
  } catch {
    return Promise.resolve();
  }
}

export const Haptic = {
  /** 가벼운 tap — 카드 flip, 메뉴 진입, 일반 버튼 */
  light: () => safe(() => {
    const H = getHaptics();
    if (!H) return;
    return H.impactAsync(H.ImpactFeedbackStyle.Light);
  }),
  /** 중간 강도 — drag end, 강한 confirm */
  medium: () => safe(() => {
    const H = getHaptics();
    if (!H) return;
    return H.impactAsync(H.ImpactFeedbackStyle.Medium);
  }),
  /** 성공 — 알아요, 저장, 정답 */
  success: () => safe(() => {
    const H = getHaptics();
    if (!H) return;
    return H.notificationAsync(H.NotificationFeedbackType.Success);
  }),
  /** 경고 — 오답, 잘못된 입력 */
  warning: () => safe(() => {
    const H = getHaptics();
    if (!H) return;
    return H.notificationAsync(H.NotificationFeedbackType.Warning);
  }),
  /** 토글 / 선택 변경 — region, 별, me 토글 */
  selection: () => safe(() => {
    const H = getHaptics();
    if (!H) return;
    return H.selectionAsync();
  }),
};
