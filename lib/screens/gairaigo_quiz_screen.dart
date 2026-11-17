import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/tts_service.dart';

/// 외국어 유래 단어 퀴즈 복습(사용자 지시 2026-11-17 「JLPT 스타일로」).
/// 문자·어휘 영역의 두 꼴 — 표기(바르게 쓴 가타카나 고르기)와 뜻 고르기, 보기 1~4.
/// 표기 문제의 틀린 보기는 규칙을 어긴 꼴(ッ·ー 빼거나 넣기, 탁음 바꾸기)로 만든다. 틀린 단어는 다음 복습에 먼저.
const int kGairaigoQuizSize = 10;
const String _kWrong = 'gairaigo_quiz_wrong';

class GQWord {
  final String ja, en, ko;
  const GQWord(this.ja, this.en, this.ko);
}

const _voice = {
  'カ': 'ガ', 'キ': 'ギ', 'ク': 'グ', 'ケ': 'ゲ', 'コ': 'ゴ', 'サ': 'ザ', 'シ': 'ジ', 'ス': 'ズ', 'セ': 'ゼ', 'ソ': 'ゾ',
  'タ': 'ダ', 'チ': 'ジ', 'ツ': 'ズ', 'テ': 'デ', 'ト': 'ド', 'ハ': 'バ', 'ヒ': 'ビ', 'フ': 'ブ', 'ヘ': 'ベ', 'ホ': 'ボ',
  'パ': 'バ', 'ピ': 'ビ', 'プ': 'ブ', 'ペ': 'ベ', 'ポ': 'ボ',
};
final Map<String, String> _swap = {for (final e in _voice.entries) e.key: e.value, for (final e in _voice.entries) e.value: e.key};
const _small = 'ァィゥェォャュョッー';

/// 규칙을 어긴 꼴들(실제 단어와 겹치는 것은 뺀다) — ッ·ー 를 빼거나 넣고, 탁음을 바꾼다.
List<String> gairaigoMisspellings(String ja, Set<String> real) {
  final c = ja.split('');
  final out = <String>{};
  for (var i = 0; i < c.length; i++) {
    if (c[i] == 'ッ' || c[i] == 'ー') {
      out.add(([...c]..removeAt(i)).join());
      continue;
    }
    final s = _swap[c[i]];
    if (s != null) out.add(([...c]..[i] = s).join());
    final next = i + 1 < c.length ? c[i + 1] : '';
    if (_small.contains(c[i]) || c[i] == 'ン' || _small.contains(next) && next.isNotEmpty) continue;
    out.add(([...c]..insert(i + 1, 'ー')).join());
    if (next.isNotEmpty && next != 'ン') out.add(([...c]..insert(i + 1, 'ッ')).join());
  }
  return out.where((s) => s != ja && s.isNotEmpty && !real.contains(s)).toList();
}

class _Q {
  final GQWord w;
  final bool spelling; // true = 표기, false = 뜻
  final List<String> options;
  const _Q(this.w, this.spelling, this.options);
  String get answer => spelling ? w.ja : w.ko;
}

class GairaigoQuizScreen extends StatefulWidget {
  final List<GQWord> words;
  final int? seed;
  const GairaigoQuizScreen({super.key, required this.words, this.seed});
  @override
  State<GairaigoQuizScreen> createState() => _GairaigoQuizScreenState();
}

class _GairaigoQuizScreenState extends State<GairaigoQuizScreen> {
  late final _rnd = Random(widget.seed);
  List<_Q>? _qs;
  int _i = 0;
  String? _picked;
  int _right = 0;
  final List<GQWord> _missed = [];

  @override
  void initState() {
    super.initState();
    _build();
  }

  Future<void> _build() async {
    final p = await SharedPreferences.getInstance();
    final wrong = (p.getStringList(_kWrong) ?? const []).toSet();
    final uniq = <String, GQWord>{for (final w in widget.words) w.ja: w}.values.toList()..shuffle(_rnd);
    uniq.sort((a, b) => (wrong.contains(b.ja) ? 1 : 0) - (wrong.contains(a.ja) ? 1 : 0));
    final picked = uniq.take(kGairaigoQuizSize).toList()..shuffle(_rnd);
    final real = {for (final w in widget.words) w.ja};
    final qs = <_Q>[];
    for (var k = 0; k < picked.length; k++) {
      final w = picked[k];
      final miss = (gairaigoMisspellings(w.ja, real)..shuffle(_rnd)).take(3).toList();
      if (k.isEven && miss.length == 3) {
        qs.add(_Q(w, true, [w.ja, ...miss]..shuffle(_rnd)));
      } else {
        final others = ({for (final o in uniq) if (o.ko != w.ko) o.ko}.toList()..shuffle(_rnd)).take(3);
        qs.add(_Q(w, false, [w.ko, ...others]..shuffle(_rnd)));
      }
    }
    if (mounted) setState(() => _qs = qs);
  }

  Future<void> _record(String ja, bool ok) async {
    final p = await SharedPreferences.getInstance();
    final s = (p.getStringList(_kWrong) ?? const []).toSet();
    ok ? s.remove(ja) : s.add(ja);
    await p.setStringList(_kWrong, s.toList());
  }

  void _again() => setState(() {
        _qs = null;
        _i = 0;
        _picked = null;
        _right = 0;
        _missed.clear();
        _build();
      });

  @override
  Widget build(BuildContext context) {
    final qs = _qs;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: Text(tr('퀴즈 복습'))),
      body: qs == null
          ? const Center(child: CircularProgressIndicator())
          : _i >= qs.length
              ? _summary(qs.length)
              : _question(qs[_i], qs.length),
    );
  }

  Widget _summary(int n) => Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('🎉', style: TextStyle(fontSize: 44)),
            const SizedBox(height: 10),
            Text(trf('{0}문제 중 {1}개 맞힘', [n, _right]), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.sumi)),
            if (_missed.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(tr('틀린 단어 — 다음 복습에 먼저 나와요'), style: const TextStyle(fontSize: 12, color: AppColors.sumiLight)),
              const SizedBox(height: 6),
              for (final w in _missed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text('${w.ja}  ${w.en.isEmpty ? '' : '${w.en} · '}${w.ko}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.sumi)),
                ),
            ],
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              OutlinedButton(key: const ValueKey('gq-again'), onPressed: _again, child: Text(tr('한 번 더'))),
              const SizedBox(width: 10),
              FilledButton(onPressed: () => Navigator.of(context).maybePop(), style: FilledButton.styleFrom(backgroundColor: AppColors.sumi), child: Text(tr('나가기'))),
            ]),
          ]),
        ),
      );

  Widget _question(_Q q, int n) {
    final w = q.w;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset(context)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Text('${tr(q.spelling ? '표기' : '뜻')} · ${_i + 1} / $n', style: const TextStyle(fontSize: 12, color: AppColors.sumiLight)),
        const SizedBox(height: 14),
        Text(
          q.spelling ? (w.en.isEmpty ? w.ko : '${w.en} · ${w.ko}') : w.ja,
          key: const ValueKey('gq-stem'),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.sumi, decoration: TextDecoration.underline, decorationColor: AppColors.sumiLight),
        ),
        const SizedBox(height: 8),
        Text(tr(q.spelling ? '가타카나로 바르게 쓴 것을 고르세요.' : '뜻으로 맞는 것을 고르세요.'), style: const TextStyle(fontSize: 14, color: AppColors.sumi)),
        if (_picked != null && !q.spelling && w.en.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(w.en, style: const TextStyle(fontSize: 13, color: AppColors.ai, fontWeight: FontWeight.w700)),
        ],
        const SizedBox(height: 14),
        for (var k = 0; k < q.options.length; k++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: OutlinedButton(
              key: ValueKey('gq-opt-$k'),
              style: OutlinedButton.styleFrom(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                backgroundColor: _picked == null ? null : (q.options[k] == q.answer ? const Color(0x3336A35B) : (q.options[k] == _picked ? const Color(0x33D83A3A) : null)),
                side: BorderSide(color: _picked != null && q.options[k] == q.answer ? AppColors.matcha : AppColors.line, width: 1.4),
              ),
              onPressed: _picked != null
                  ? null
                  : () {
                      final ok = q.options[k] == q.answer;
                      TtsService.instance.speak(w.ja);
                      _record(w.ja, ok);
                      setState(() {
                        _picked = q.options[k];
                        ok ? _right++ : _missed.add(w);
                      });
                    },
              child: Row(children: [
                SizedBox(width: 26, child: Text('${k + 1}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.sumiLight))),
                Expanded(child: Text(q.options[k], style: TextStyle(fontSize: q.spelling ? 20 : 16, fontWeight: FontWeight.w800, color: AppColors.sumi))),
              ]),
            ),
          ),
        if (_picked != null)
          FilledButton(
            key: const ValueKey('gq-next'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.sumi, minimumSize: const Size.fromHeight(48)),
            onPressed: () => setState(() {
              _i++;
              _picked = null;
            }),
            child: Text(tr('다음 →')),
          ),
      ]),
    );
  }
}
