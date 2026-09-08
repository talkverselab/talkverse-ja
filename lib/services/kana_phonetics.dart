/// 가나별 발음 정보 — IPA · 조음 위치/입모양 · 영어/한국어 비교.
///
/// 출처(넷의 IPA 자료 기준):
/// - IPA 표기: Wikipedia "Japanese phonology", "Help:IPA/Japanese"
/// - 한·일 비교: 도쿄외대 조선어 자료(tufs.ac.jp), 나무위키 "일본어/발음" 등
/// 차트 이미지: Wikimedia Commons (CC BY-SA) — assets/images/ipa/
class KanaPhonetics {
  final String ipa; // 음절 전체 IPA, 예: [ka]
  final String place; // 소리나는 곳·입모양 (IPA 조음 용어)
  final String engIpa; // 가까운 영어 소리 IPA + 예시 단어
  final String engHow; // 영어로 발음 방법 설명 (영문)
  final String korSim; // 비슷한 한국어 소리
  final String korDiff; // 한국어와의 차이점
  final bool vowelOnly; // あ행 여부(모음 차트만 표시)

  const KanaPhonetics({
    required this.ipa,
    required this.place,
    required this.engIpa,
    required this.engHow,
    required this.korSim,
    required this.korDiff,
    this.vowelOnly = false,
  });
}

class _V {
  final String ipa, mouth, engIpa, engHow, korSim, korDiff;
  const _V(this.ipa, this.mouth, this.engIpa, this.engHow, this.korSim, this.korDiff);
}

// 모음 5개 — Wikipedia "Japanese phonology" 기준.
const Map<String, _V> _vowels = {
  'a': _V(
    'ä',
    '입을 크게 벌리고 혀는 낮게, 입안 한가운데(중설 저모음). 입술은 힘을 뺀다.',
    '[ɑ] — father의 a',
    "Like the 'a' in \"father\", but shorter and made in the very center of the mouth.",
    '아',
    "한국어 '아'[ɐ]와 거의 같지만, 일본어 あ[ä]가 혀 위치가 조금 더 낮고 입을 약간 덜 벌린다.",
  ),
  'i': _V(
    'i',
    '혀를 앞·위로 높이고 입술은 옆으로 살짝 편다(전설 고모음).',
    '[iː] — see의 ee',
    "Like the 'ee' in \"see\", but short and crisp — don't stretch it.",
    '이',
    "한국어 '이'와 사실상 같다. 짧게 끊어 주기만 하면 된다.",
  ),
  'u': _V(
    'ɯᵝ',
    '혀는 뒤·위로 높이지만 입술을 내밀지 않는다(비원순 후설 고모음). 입술은 평평하게 살짝 오므리는 정도.',
    '[uː] — boot의 oo (단, 입술 모양이 다름)',
    "Like the 'oo' in \"boot\" but with relaxed, unrounded lips — as if smiling slightly while saying it.",
    '우/으',
    "한국어 '우'[u]는 입술을 동그랗게 내밀지만, 일본어 う[ɯ]는 입술을 내밀지 않는다. '우'와 '으'의 중간 소리에 가깝다.",
  ),
  'e': _V(
    'e̞',
    '혀를 앞쪽 중간 높이에 두고 입을 반쯤 벌린다(전설 중모음).',
    '[ɛ] — get의 e',
    "Between the 'e' in \"get\" and the first part of \"gate\" — a pure, steady vowel.",
    '에',
    "한국어 '에'와 거의 같다. 일본어 쪽이 입을 조금 더 벌리는 정도의 차이.",
  ),
  'o': _V(
    'o̞',
    '혀를 뒤쪽 중간 높이에 두고 입술을 둥글게(후설 중모음·원순). 단, 과하게 내밀지 않는다.',
    '[oʊ] — go의 o (첫 부분만)',
    "Like the beginning of the 'o' in \"go\", but keep it pure — don't glide into 'u'.",
    '오',
    "한국어 '오'와 거의 같지만, 일본어 お가 입술을 조금 덜 내민다.",
  ),
};

class _C {
  final String ipa, place, engIpa, engHow, korSim, korDiff;
  const _C(this.ipa, this.place, this.engIpa, this.engHow, this.korSim, this.korDiff);
}

// 자음(행) — 대표값. 예외 음절은 _overrides에서 별도 처리.
const Map<String, _C> _consonants = {
  'k': _C('k', '혀 뒤쪽을 여린입천장(연구개)에 붙였다 떼며 터뜨린다(무성 연구개 파열음).',
      '[k] — sky의 k',
      "Like the 'k' in \"sky\" — with less puff of air than the 'k' in \"key\".",
      'ㄱ/ㅋ',
      "한국어 ㅋ보다 숨(기식)이 약하고 ㄱ보다는 강하다. 단어 중간에서는 거의 ㄲ처럼 들리기도 한다."),
  's': _C('s', '혀끝을 윗잇몸에 가까이 대고 좁은 틈으로 바람을 내보낸다(무성 치경 마찰음).',
      '[s] — sun의 s',
      "Exactly like the 's' in \"sun\".",
      'ㅅ',
      "한국어 ㅅ과 거의 같다. 단, ㅆ처럼 세게 조이지 않는다."),
  't': _C('t', '혀끝을 윗잇몸에 붙였다 떼며 터뜨린다(무성 치경 파열음).',
      '[t] — stop의 t',
      "Like the 't' in \"stop\" — lighter aspiration than the 't' in \"top\".",
      'ㄷ/ㅌ',
      "한국어 ㅌ보다 숨이 약하고 ㄷ보다는 강하다. 단어 중간에서는 ㄸ에 가깝게 들린다."),
  'n': _C('n', '혀끝을 윗잇몸에 붙이고 코로 소리를 내보낸다(치경 비음).',
      '[n] — no의 n',
      "Exactly like the 'n' in \"no\".",
      'ㄴ',
      "한국어 ㄴ과 같다."),
  'h': _C('h', '목 안쪽에서 숨을 내쉬며 내는 소리(무성 성문 마찰음).',
      '[h] — hat의 h',
      "Like the 'h' in \"hat\".",
      'ㅎ',
      "한국어 ㅎ과 거의 같다."),
  'm': _C('m', '두 입술을 붙이고 코로 소리를 내보낸다(양순 비음).',
      '[m] — mom의 m',
      "Exactly like the 'm' in \"mom\".",
      'ㅁ',
      "한국어 ㅁ과 같다."),
  'y': _C('j', "혀 가운데를 센입천장에 가까이 올리며 미끄러지듯 시작한다(경구개 접근음).",
      '[j] — yes의 y',
      "Like the 'y' in \"yes\".",
      '야/유/요의 첫소리',
      "한국어 '야·유·요'의 첫소리와 같다."),
  'r': _C('ɾ', '혀끝으로 윗잇몸을 한 번 가볍게 튕긴다(치경 탄음). 영어 r처럼 혀를 말지 않는다!',
      '[ɾ] — better의 tt (미국식)',
      "Like the quick 'tt' in American \"better\" or \"water\" — a single tap of the tongue. NOT the English 'r'.",
      'ㄹ',
      "모음 사이의 한국어 ㄹ(예: '나라'의 ㄹ)과 거의 같다. 영어식으로 혀를 말면 안 된다."),
  'g': _C('g', '혀 뒤쪽을 연구개에 붙였다 떼며, 성대를 울리면서 터뜨린다(유성 연구개 파열음).',
      '[g] — go의 g',
      "Like the 'g' in \"go\" — voiced from the very start.",
      'ㄱ',
      "한국어는 단어 첫머리의 ㄱ이 무성음이라, 어두의 が는 '가'보다 성대가 먼저 울리는 더 탁한 소리다. 한국인이 가장 놓치기 쉬운 부분."),
  'z': _C('z', '혀끝을 윗잇몸 가까이 대고 성대를 울리며 바람을 내보낸다(유성 치경 마찰음). 어두에서는 [dz]로 터뜨리듯.',
      '[z] — zoo의 z',
      "Like the 'z' in \"zoo\" — keep your vocal cords buzzing.",
      'ㅈ (정확히 대응하는 소리 없음)',
      "한국어 ㅈ은 무성음이라 ざ행과 다르다. '자'라고 읽으면 じゃ처럼 들리므로, 영어 z처럼 성대를 울려야 한다."),
  'd': _C('d', '혀끝을 윗잇몸에 붙였다 떼며 성대를 울리면서 터뜨린다(유성 치경 파열음).',
      '[d] — do의 d',
      "Like the 'd' in \"do\" — voiced from the start.",
      'ㄷ',
      "어두의 だ는 한국어 '다'(무성)보다 성대가 먼저 울린다. が행과 같은 원리의 차이."),
  'b': _C('b', '두 입술을 붙였다 떼며 성대를 울리면서 터뜨린다(유성 양순 파열음).',
      '[b] — boy의 b',
      "Like the 'b' in \"boy\" — voiced from the start.",
      'ㅂ',
      "어두의 ば는 한국어 '바'(무성)보다 성대가 먼저 울리는 탁한 소리다."),
  'p': _C('p', '두 입술을 붙였다 떼며 터뜨린다(무성 양순 파열음).',
      '[p] — spy의 p',
      "Like the 'p' in \"spy\" — less puff than the 'p' in \"pie\".",
      'ㅂ/ㅍ',
      "한국어 ㅍ보다 숨이 약하다. 단어 중간에서는 ㅃ에 가깝게 들린다."),
};

// 대표값과 다른 음절들 — Wikipedia "Japanese phonology" 기준.
const Map<String, KanaPhonetics> _overrides = {
  'shi': KanaPhonetics(
    ipa: 'ɕi',
    place: '혀 앞부분을 넓게 센입천장 쪽으로 올려 바람을 내보낸다(무성 치경구개 마찰음). 영어 sh보다 혀가 앞·위쪽.',
    engIpa: '[ʃ] — she의 sh (비슷하지만 더 밝은 소리)',
    engHow: "Like \"she\", but with the tongue closer to the hard palate — a brighter, thinner 'sh'.",
    korSim: '시',
    korDiff: "한국어 '시'의 ㅅ도 [ɕ]라서 거의 같은 소리다. 짧게 끊어 주면 된다.",
  ),
  'chi': KanaPhonetics(
    ipa: 'tɕi',
    place: '혀 앞부분을 센입천장에 붙였다 떼며 마찰과 함께 터뜨린다(무성 치경구개 파찰음).',
    engIpa: '[tʃ] — cheese의 ch',
    engHow: "Like the 'ch' in \"cheese\", but lighter and with less puff of air.",
    korSim: '치/찌',
    korDiff: "한국어 ㅊ보다 숨이 약해서 '치'와 '찌'의 중간으로 들린다. 단어 중간에서는 '찌'에 가깝다.",
  ),
  'tsu': KanaPhonetics(
    ipa: 'tsɯᵝ',
    place: "혀끝을 윗잇몸에 붙였다 떼는 순간 [s]의 마찰이 이어진다(무성 치경 파찰음). 입술은 내밀지 않는다.",
    engIpa: '[ts] — cats의 ts',
    engHow: "Say the 'ts' at the end of \"cats\", then add the Japanese u — all as one quick syllable.",
    korSim: '츠/쓰 (정확히 대응하는 소리 없음)',
    korDiff: "한국어에 없는 소리다. '츠'는 숨이 너무 세고 '쓰'는 앞의 [t]가 빠진 것. t와 s를 한 번에 붙여 내야 한다.",
  ),
  'hi': KanaPhonetics(
    ipa: 'çi',
    place: '혀 가운데를 센입천장에 가까이 올려 좁은 틈으로 바람을 내보낸다(무성 경구개 마찰음).',
    engIpa: '[ç] — hue, human의 h',
    engHow: "Like the 'h' in \"hue\" or \"human\" — a hissy h made at the roof of the mouth.",
    korSim: '히',
    korDiff: "한국어 '히'의 ㅎ도 이 위치에서 나므로 거의 같다. 다만 일본어 쪽이 마찰이 조금 더 강하다.",
  ),
  'fu': KanaPhonetics(
    ipa: 'ɸɯᵝ',
    place: '두 입술을 가까이 붙여 그 틈으로 바람을 내보낸다(무성 양순 마찰음). 이(치아)는 쓰지 않는다!',
    engIpa: '[f] — food의 f (비슷하지만 이를 안 씀)',
    engHow: "Like blowing out a candle softly — an 'f' made with both lips only, never the teeth.",
    korSim: '후 (정확히 대응하는 소리 없음)',
    korDiff: "한국어 '후'의 ㅎ은 목에서 나지만 ふ는 입술 사이에서 난다. 영어 f처럼 이를 입술에 대지도 않는다. 촛불 끄듯 '후–' 하는 소리.",
  ),
  'ni': KanaPhonetics(
    ipa: 'ɲi',
    place: '혀 가운데를 센입천장에 넓게 붙이고 코로 소리를 낸다(경구개 비음).',
    engIpa: '[nj] — new(영국식)의 n',
    engHow: "Like the 'n' in British \"new\" [njuː] — an n with a built-in y sound.",
    korSim: '니',
    korDiff: "한국어 '니'와 거의 같다.",
  ),
  'wa': KanaPhonetics(
    ipa: 'ɰa',
    place: '혀 뒤를 살짝 올리고 입술은 거의 내밀지 않은 채 다음 모음으로 미끄러진다(연구개 접근음).',
    engIpa: '[w] — want의 w (입술을 덜 둥글게)',
    engHow: "Like the 'w' in \"want\", but with much less lip rounding — lips stay relaxed.",
    korSim: '와',
    korDiff: "한국어 '와'는 입술을 둥글게 내밀지만, 일본어 わ는 입술을 거의 내밀지 않는다.",
  ),
  'n': KanaPhonetics(
    ipa: 'ɴ',
    place: '음절 하나 길이를 가진 콧소리. 단독·어말에서는 목젖 근처(구개수 비음), 뒤 소리에 따라 [n]·[m]·[ŋ]으로 변한다.',
    engIpa: '[n]/[m]/[ŋ] — sing의 ng에 가까울 때가 많음',
    engHow: "A full-length nasal hum. Before b/p it sounds like 'm', before k/g like 'ng' in \"sing\", at the end of a word it hums near the uvula.",
    korSim: '받침 ㄴ/ㅁ/ㅇ',
    korDiff: "한국어 받침처럼 딱 닫히지 않고, 한 박자를 온전히 차지하는 콧소리다. 뒤 소리에 따라 ㄴ·ㅁ·ㅇ 사이를 오간다.",
  ),
  'ji': KanaPhonetics(
    ipa: 'dʑi',
    place: '혀 앞부분을 센입천장에 붙였다 떼며 성대를 울려 터뜨린다(유성 치경구개 파찰음).',
    engIpa: '[dʒ] — jeep의 j',
    engHow: "Like the 'j' in \"jeep\" — voiced, with the tongue high on the palate.",
    korSim: '지',
    korDiff: "한국어 ㅈ은 무성음이라, じ는 '지'보다 성대가 먼저 울리는 탁한 소리다. 영어 j에 더 가깝다.",
  ),
  'zu': KanaPhonetics(
    ipa: 'zɯᵝ',
    place: '혀끝을 윗잇몸 가까이 대고 성대를 울리며 바람을 내보낸다(유성 치경 마찰음). 어두에서는 [dz].',
    engIpa: '[z] — zoo의 z',
    engHow: "Like the 'z' in \"zoo\" with the Japanese unrounded u.",
    korSim: '즈 (정확히 대응하는 소리 없음)',
    korDiff: "한국어에 없는 유성 마찰음. '즈'라고 읽으면 무성이 되므로, 벌이 윙윙거리듯 성대를 울리며 내야 한다.",
  ),
};

// 요음(y+모음) IPA 자음부 — 구개음화 표기.
const Map<String, String> _youOnset = {
  'ky': 'kʲ', 'sh': 'ɕ', 'ch': 'tɕ', 'ny': 'ɲ', 'hy': 'ç',
  'my': 'mʲ', 'ry': 'ɾʲ', 'gy': 'gʲ', 'j': 'dʑ', 'by': 'bʲ', 'py': 'pʲ',
};

/// romaji로 발음 정보 조회. 대응 없으면 null.
KanaPhonetics? kanaPhoneticsOf(String romaji) {
  if (romaji.isEmpty) return null;
  final ov = _overrides[romaji];
  if (ov != null) return ov;

  // 모음 단독 (あ행)
  final v0 = _vowels[romaji];
  if (v0 != null) {
    return KanaPhonetics(
      ipa: v0.ipa,
      place: v0.mouth,
      engIpa: v0.engIpa,
      engHow: v0.engHow,
      korSim: v0.korSim,
      korDiff: v0.korDiff,
      vowelOnly: true,
    );
  }

  final vKey = romaji.substring(romaji.length - 1);
  final v = _vowels[vKey];
  if (v == null) return null;
  var onset = romaji.substring(0, romaji.length - 1);

  // 요음 (kya, sha, cho, ja …)
  if (onset.length >= 2 || onset == 'j') {
    final yIpa = _youOnset[onset];
    if (yIpa != null) {
      final base = onset == 'sh'
          ? _overrides['shi']!
          : onset == 'ch'
              ? _overrides['chi']!
              : onset == 'j'
                  ? _overrides['ji']!
                  : null;
      final c = _consonants[onset[0]];
      return KanaPhonetics(
        ipa: '$yIpa${v.ipa}',
        place: base?.place ??
            '${c?.place ?? ''}\n동시에 혀 가운데를 센입천장 쪽으로 올려(구개음화) 한 박자에 발음한다.',
        engIpa: base?.engIpa ?? '${c?.engIpa ?? ''} + y',
        engHow: base != null
            ? base.engHow
            : "Blend the consonant with a 'y' glide into the vowel — one beat, not two (e.g. \"kya\", not \"ki-ya\").",
        korSim: base?.korSim ?? _koYou(onset, vKey),
        korDiff: base?.korDiff ??
            "한 글자처럼 한 박자에 붙여 낸다. '키야'처럼 두 박자로 끊으면 안 된다.",
      );
    }
  }

  final c = _consonants[onset];
  if (c == null) return null;
  return KanaPhonetics(
    ipa: '${c.ipa}${v.ipa}',
    place: '${c.place}\n모음: ${v.mouth}',
    engIpa: '${c.engIpa}  ·  모음 ${v.engIpa}',
    engHow: '${c.engHow} ${v.engHow}',
    korSim: '${c.korSim} + ${v.korSim}',
    korDiff: c.korDiff,
  );
}

String _koYou(String onset, String v) {
  const map = {'a': 'ㅑ', 'u': 'ㅠ', 'o': 'ㅛ'};
  return '자음 + ${map[v] ?? v}';
}
