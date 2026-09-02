import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/theme.dart';
import '../services/ko_reading.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/selectable_ja_text.dart';

/// 조사 레슨 — particles.json (격조사·보조사 + 종조사). 항목 펼치기 + 예문 TTS + 4지선다 테스트.
class GrammarLessonScreen extends StatefulWidget {
  const GrammarLessonScreen({super.key});

  @override
  State<GrammarLessonScreen> createState() => _GrammarLessonScreenState();
}

class _GrammarLessonScreenState extends State<GrammarLessonScreen> {
  Map<String, dynamic>? _data;
  int _sectionIdx = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final raw = await rootBundle.loadString('assets/data/grammar/particles.json');
    if (!mounted) return;
    setState(() => _data = json.decode(raw) as Map<String, dynamic>);
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(data?['title'] as String? ?? '조사',
                style: const TextStyle(color: AppColors.sumi, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(data?['subtitle'] as String? ?? '',
                style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 1)),
          ],
        ),
        actions: [
          const KoReadingToggleAction(),
          if (data != null)
            IconButton(
              tooltip: '조사 테스트',
              icon: const Icon(Icons.quiz, color: AppColors.beni),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GrammarTestScreen(data: data)),
              ),
            ),
        ],
      ),
      body: data == null
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : _body(data),
    );
  }

  Widget _body(Map<String, dynamic> data) {
    final sections = (data['sections'] as List).cast<Map<String, dynamic>>();
    final section = sections[_sectionIdx];
    final items = (section['items'] as List).cast<Map<String, dynamic>>();
    return Column(
      children: [
        Container(
          color: AppColors.washiDeep,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: List.generate(sections.length, (i) {
              final s = sections[i];
              final selected = i == _sectionIdx;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _sectionIdx = i),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected ? AppColors.ai : AppColors.washi,
                      border: Border.all(color: AppColors.ai, width: selected ? 1.5 : 0.8),
                    ),
                    child: Text(
                      '${s['emoji']} ${s['title']} · ${(s['items'] as List).length}',
                      style: TextStyle(
                        color: selected ? AppColors.washi : AppColors.ai,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
        const AsanohaDivider(height: 10),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) => _ParticleTile(item: items[i], index: i),
          ),
        ),
      ],
    );
  }
}

class _ParticleTile extends StatefulWidget {
  final Map<String, dynamic> item;
  final int index;
  const _ParticleTile({required this.item, required this.index});

  @override
  State<_ParticleTile> createState() => _ParticleTileState();
}

class _ParticleTileState extends State<_ParticleTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final it = widget.item;
    final examples = (it['examples'] as List? ?? []).cast<Map<String, dynamic>>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.washi,
        border: Border.all(color: _open ? AppColors.ai : AppColors.kin.withValues(alpha: 0.5), width: _open ? 1.4 : 0.8),
        boxShadow: [
          BoxShadow(color: AppColors.sumi.withValues(alpha: 0.05), blurRadius: 6, offset: const Offset(1, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    color: AppColors.ai,
                    child: FittedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Text(
                          it['ja'] as String,
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.washi),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(it['ko'] as String,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.sumi)),
                            const SizedBox(width: 6),
                            Text('[${it['reading']}]',
                                style: const TextStyle(fontSize: 11, color: AppColors.sumiLight, fontStyle: FontStyle.italic)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          color: AppColors.kin.withValues(alpha: 0.2),
                          child: Text(it['kind'] as String,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.sumi)),
                        ),
                      ],
                    ),
                  ),
                  Icon(_open ? Icons.expand_less : Icons.expand_more, color: AppColors.sumiLight),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            child: _open
                ? Container(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: AppColors.washiDeep,
                          child: Text('💡 ${it['tip']}',
                              style: const TextStyle(fontSize: 12, color: AppColors.sumi, height: 1.4)),
                        ),
                        const SizedBox(height: 8),
                        ...examples.map((ex) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SelectableJaText(
                                          text: ex['ja'] as String,
                                          highlightText: it['ja'] as String,
                                          style: const TextStyle(
                                              fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.sumi, height: 1.3),
                                        ),
                                        if (ex['kana'] != null && ex['kana'] != ex['ja'])
                                          Text(ex['kana'] as String,
                                              style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
                                        if (ex['kana'] != null)
                                          KoReadingText(ex['kana'] as String,
                                              style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
                                        Text(ex['ko'] as String,
                                            style: const TextStyle(fontSize: 12, color: AppColors.ai, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.volume_up, color: AppColors.beni, size: 20),
                                    onPressed: () => TtsService.instance.speak(ex['ja'] as String),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

/// 조사 4지선다 — 예문의 조사를 빈칸으로, 정답 조사 고르기.
class GrammarTestScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const GrammarTestScreen({super.key, required this.data});

  @override
  State<GrammarTestScreen> createState() => _GrammarTestScreenState();
}

class _GQ {
  final String blanked;
  final String full;
  final String ko;
  final String answer;
  final List<String> options;
  _GQ(this.blanked, this.full, this.ko, this.answer, this.options);
}

class _GrammarTestScreenState extends State<GrammarTestScreen> {
  final _rand = Random();
  List<_GQ> _qs = [];
  int _idx = 0;
  int? _selected;
  int _correct = 0;

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    final sections = (widget.data['sections'] as List).cast<Map<String, dynamic>>();
    final particles = <String>{};
    final pool = <_GQ>[];
    final all = <Map<String, dynamic>>[];
    for (final s in sections) {
      all.addAll((s['items'] as List).cast<Map<String, dynamic>>());
    }
    for (final it in all) {
      final p = (it['ja'] as String).split(' / ').first.trim();
      particles.add(p);
    }
    for (final it in all) {
      final p = (it['ja'] as String).split(' / ').first.trim();
      for (final ex in (it['examples'] as List).cast<Map<String, dynamic>>()) {
        final ja = ex['ja'] as String;
        final pos = ja.indexOf(p);
        if (pos < 0) continue;
        final blanked = '${ja.substring(0, pos)}（　）${ja.substring(pos + p.length)}';
        final distract = particles.where((x) => x != p).toList()..shuffle(_rand);
        final options = [p, ...distract.take(3)]..shuffle(_rand);
        pool.add(_GQ(blanked, ja, ex['ko'] as String, p, options));
      }
    }
    pool.shuffle(_rand);
    setState(() {
      _qs = pool.take(15).toList();
      _idx = 0;
      _selected = null;
      _correct = 0;
    });
  }

  void _select(int i) {
    if (_selected != null) return;
    setState(() {
      _selected = i;
      if (_qs[_idx].options[i] == _qs[_idx].answer) _correct++;
    });
    TtsService.instance.speak(_qs[_idx].full);
  }

  void _next() {
    if (_idx < _qs.length - 1) {
      setState(() {
        _idx++;
        _selected = null;
      });
    } else {
      final pct = (_correct / _qs.length * 100).round();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.washi,
          shape: const RoundedRectangleBorder(),
          title: const Text('🎉 조사 테스트 완료', style: TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w900)),
          content: Text('$_correct / ${_qs.length}  ·  $pct%',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.beni)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('나가기', style: TextStyle(color: AppColors.sumiLight)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _build();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.beni,
                foregroundColor: AppColors.washi,
                shape: const RoundedRectangleBorder(),
              ),
              child: const Text('다시'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(title: const Text('조사 테스트 · 빈칸 4지선다')),
      body: _qs.isEmpty
          ? const Center(child: CircularProgressIndicator(color: AppColors.beni))
          : _body(),
    );
  }

  Widget _body() {
    final q = _qs[_idx];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('${_idx + 1} / ${_qs.length}',
                      style: const TextStyle(fontSize: 11, color: AppColors.sumiLight, letterSpacing: 1)),
                  const Spacer(),
                  Text('✓ $_correct', style: const TextStyle(fontSize: 11, color: AppColors.sumiLight)),
                ],
              ),
              const SizedBox(height: 6),
              Stack(
                children: [
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.washiDeep,
                      border: Border.all(color: AppColors.kin.withValues(alpha: 0.4)),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: (_idx + 1) / _qs.length,
                    child: Container(height: 6, color: AppColors.ai),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.washi,
                    border: Border.all(color: AppColors.kin, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _selected == null ? q.blanked : q.full,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: AppColors.sumi, height: 1.4),
                      ),
                      const SizedBox(height: 10),
                      Text(q.ko,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 14, color: AppColors.ai, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 2.4,
                    children: List.generate(q.options.length, (i) {
                      final opt = q.options[i];
                      final revealed = _selected != null;
                      final isCorrect = opt == q.answer;
                      Color bg = AppColors.washi;
                      Color fg = AppColors.sumi;
                      Color border = AppColors.kin.withValues(alpha: 0.6);
                      if (revealed && isCorrect) {
                        bg = AppColors.matcha;
                        fg = AppColors.washi;
                        border = AppColors.matcha;
                      } else if (revealed && _selected == i) {
                        bg = AppColors.beni;
                        fg = AppColors.washi;
                        border = AppColors.beni;
                      }
                      return InkWell(
                        onTap: () => _select(i),
                        child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: bg, border: Border.all(color: border, width: 1.2)),
                          child: Text(opt, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: fg)),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: SizedBox(
              height: 50,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selected != null ? _next : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.beni,
                  foregroundColor: AppColors.washi,
                  disabledBackgroundColor: AppColors.sumiLight.withValues(alpha: 0.3),
                  shape: const RoundedRectangleBorder(),
                  elevation: 0,
                ),
                child: Text(
                  _idx == _qs.length - 1 ? '결과 보기' : '다음 →',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 3),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }
}
