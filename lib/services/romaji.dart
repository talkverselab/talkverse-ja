/// 가나 → 로마자(헵번식). 영어 등 한국어가 아닌 UI 에서 한글 독음 자리에 보여 준다(2026-11-11 글로벌판 1단계).
/// 장음은 글자대로(おう→ou, ー는 앞 모음 반복), 촉음은 다음 자음 겹침(っち→tchi), ん 뒤 모음·や행은 n'.
/// 조사 は·へ·を 는 가나만으로 가릴 수 없어 글자대로(ha·he·o) 적는다.
class Romaji {
  static const _h = 'あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽぁぃぅぇぉゃゅょゎゔ';
  static const _r = 'a i u e o ka ki ku ke ko sa shi su se so ta chi tsu te to na ni nu ne no ha hi fu he ho ma mi mu me mo ya yu yo ra ri ru re ro wa o n ga gi gu ge go za ji zu ze zo da ji zu de do ba bi bu be bo pa pi pu pe po a i u e o ya yu yo wa vu';
  static final Map<String, String> _map = () {
    final r = _r.split(' ');
    return {for (var i = 0; i < _h.length; i++) _h[i]: r[i]};
  }();

  static String _hira(String s) => String.fromCharCodes(s.runes.map((c) => c >= 0x30A1 && c <= 0x30F6 ? c - 0x60 : c));

  static String fromKana(String kana) {
    final k = _hira(kana);
    final out = StringBuffer();
    String last = '';
    void put(String s) {
      out.write(s);
      if (s.isNotEmpty) last = s;
    }

    for (var i = 0; i < k.length; i++) {
      final c = k[i];
      final nx = i + 1 < k.length ? k[i + 1] : '';
      if (c == 'っ') {
        final r = _map[nx] ?? '';
        if (r.isNotEmpty) put(r.startsWith('ch') ? 't' : r[0]);
        continue;
      }
      if (c == 'ー') {
        if (last.isNotEmpty) put(last[last.length - 1]);
        continue;
      }
      final r = _map[c];
      if (r == null) {
        out.write(c == '、' ? ', ' : c == '。' ? '. ' : c == '？' ? '? ' : c == '！' ? '! ' : c == '…' ? '… ' : c == '　' ? ' ' : c);
        last = '';
        continue;
      }
      if (nx.isNotEmpty && 'ゃゅょ'.contains(nx) && r.length > 1 && r.endsWith('i')) {
        final base = r.substring(0, r.length - 1), y = _map[nx]!;
        put(const {'sh', 'ch', 'j'}.contains(base) ? base + y.substring(1) : base + y);
        i++;
        continue;
      }
      if (nx.isNotEmpty && 'ぁぃぅぇぉ'.contains(nx) && const {'fu', 'te', 'de', 'u', 'vu'}.contains(r)) {
        put((const {'fu': 'f', 'te': 't', 'de': 'd', 'u': 'w', 'vu': 'v'}[r]!) + _map[nx]!);
        i++;
        continue;
      }
      if (c == 'ん' && nx.isNotEmpty && 'あいうえおやゆよ'.contains(nx)) {
        put("n'");
        continue;
      }
      put(r);
    }
    return out.toString().replaceAll(RegExp(r' +'), ' ').trim();
  }
}
