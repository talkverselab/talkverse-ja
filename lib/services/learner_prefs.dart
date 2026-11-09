import 'package:flutter/foundation.dart';
import '../core/prefs.dart';

/// 학습자 프로필(「나」) — 2026-11-02 사용자 지시 "성별이 정해지면 나가 나오는 거니까".
/// 회화의 화자 A = 학습자. 성별 → A 의 목소리(나중엔 장면 그림의 A 도), 이름 → `{name}` 자리.
class LearnerPrefs {
  LearnerPrefs._();
  static const _kName = 'learner_name';
  static const _kGender = 'learner_gender'; // male | female
  static const _kFurigana = 'furigana_show';

  static final ValueNotifier<String> name = ValueNotifier('');
  static final ValueNotifier<String> gender = ValueNotifier('male');
  /// 후리가나 표시 — 기본 **미표시**(사용자 지시 2026-11-07 "힘들어도 후리가나를 보지 않고 익혀보세요"). 문장·단어 어디서나 이 값 하나.
  static final ValueNotifier<bool> furigana = ValueNotifier(false);

  static Future<void> load() async {
    final p = await Prefs.getInstance();
    name.value = p.getString(_kName) ?? '';
    gender.value = p.getString(_kGender) ?? 'male';
    furigana.value = p.getBool(_kFurigana) ?? false;
  }

  static Future<void> setFurigana(bool v) async {
    furigana.value = v;
    (await Prefs.getInstance()).setBool(_kFurigana, v);
  }

  static Future<void> setName(String v) async {
    name.value = v.trim();
    (await Prefs.getInstance()).setString(_kName, name.value);
  }

  static Future<void> setGender(String v) async {
    gender.value = v == 'female' ? 'female' : 'male';
    (await Prefs.getInstance()).setString(_kGender, gender.value);
  }

  static bool get isFemale => gender.value == 'female';

  /// 화자 코드 → 목소리 성별. A = 학습자(프로필), C = 남성 조연, 그 밖(B·D) = 여성.
  static String voiceGender(String speaker) => speaker == 'A' ? gender.value : (speaker == 'C' ? 'male' : 'female');

  /// 본문의 `{name}` 치환. 이름이 없으면 일본어 관용 자리표시 「〇〇」(한국어 줄은 「○○」).
  static String fill(String text, {bool ko = false}) {
    if (!text.contains('{')) return text;
    final n = name.value.isNotEmpty ? name.value : (ko ? '○○' : '〇〇');
    return text.replaceAll('{name}', n).replaceAll(RegExp(r'\{[a-z_]+\}'), ko ? '○○' : '〇〇'); // 그 밖의 자리({hotel}·{photo_word} 등)도 — 음성이 있는 턴은 음성 본문(값이 채워진 글)이 먼저 보인다
  }
}
