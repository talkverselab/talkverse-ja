import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../services/tts_service.dart';
import '../widgets/japanese_decor.dart';
import '../widgets/kana_sound_sheet.dart';
import '../core/platform.dart';
import '../core/l10n.dart';

const _hira = [
  ['あ', 'い', 'う', 'え', 'お'],
  ['か', 'き', 'く', 'け', 'こ'],
  ['さ', 'し', 'す', 'せ', 'そ'],
  ['た', 'ち', 'つ', 'て', 'と'],
  ['な', 'に', 'ぬ', 'ね', 'の'],
  ['は', 'ひ', 'ふ', 'へ', 'ほ'],
  ['ま', 'み', 'む', 'め', 'も'],
  ['や', '', 'ゆ', '', 'よ'],
  ['ら', 'り', 'る', 'れ', 'ろ'],
  ['わ', '', '', '', 'を'],
  ['ん', '', '', '', ''],
];

const _kata = [
  ['ア', 'イ', 'ウ', 'エ', 'オ'],
  ['カ', 'キ', 'ク', 'ケ', 'コ'],
  ['サ', 'シ', 'ス', 'セ', 'ソ'],
  ['タ', 'チ', 'ツ', 'テ', 'ト'],
  ['ナ', 'ニ', 'ヌ', 'ネ', 'ノ'],
  ['ハ', 'ヒ', 'フ', 'ヘ', 'ホ'],
  ['マ', 'ミ', 'ム', 'メ', 'モ'],
  ['ヤ', '', 'ユ', '', 'ヨ'],
  ['ラ', 'リ', 'ル', 'レ', 'ロ'],
  ['ワ', '', '', '', 'ヲ'],
  ['ン', '', '', '', ''],
];

const _romaji = [
  ['a', 'i', 'u', 'e', 'o'],
  ['ka', 'ki', 'ku', 'ke', 'ko'],
  ['sa', 'shi', 'su', 'se', 'so'],
  ['ta', 'chi', 'tsu', 'te', 'to'],
  ['na', 'ni', 'nu', 'ne', 'no'],
  ['ha', 'hi', 'fu', 'he', 'ho'],
  ['ma', 'mi', 'mu', 'me', 'mo'],
  ['ya', '', 'yu', '', 'yo'],
  ['ra', 'ri', 'ru', 're', 'ro'],
  ['wa', '', '', '', 'o'],
  ['n', '', '', '', ''],
];

List<String> get _rowNames => [tr('あ행'), tr('か행'), tr('さ행'), tr('た행'), tr('な행'), tr('は행'), tr('ま행'), tr('や행'), tr('ら행'), tr('わ행'), 'ん'];

// 濁音·半濁音
const _dakuHira = [
  ['が', 'ぎ', 'ぐ', 'げ', 'ご'],
  ['ざ', 'じ', 'ず', 'ぜ', 'ぞ'],
  ['だ', 'ぢ', 'づ', 'で', 'ど'],
  ['ば', 'び', 'ぶ', 'べ', 'ぼ'],
  ['ぱ', 'ぴ', 'ぷ', 'ぺ', 'ぽ'],
];
const _dakuKata = [
  ['ガ', 'ギ', 'グ', 'ゲ', 'ゴ'],
  ['ザ', 'ジ', 'ズ', 'ゼ', 'ゾ'],
  ['ダ', 'ヂ', 'ヅ', 'デ', 'ド'],
  ['バ', 'ビ', 'ブ', 'ベ', 'ボ'],
  ['パ', 'ピ', 'プ', 'ペ', 'ポ'],
];
const _dakuRomaji = [
  ['ga', 'gi', 'gu', 'ge', 'go'],
  ['za', 'ji', 'zu', 'ze', 'zo'],
  ['da', 'ji', 'zu', 'de', 'do'],
  ['ba', 'bi', 'bu', 'be', 'bo'],
  ['pa', 'pi', 'pu', 'pe', 'po'],
];
List<String> get _dakuRowNames => [tr('が행'), tr('ざ행'), tr('だ행'), tr('ば행'), tr('ぱ행')];

// 拗音
const _youHira = [
  ['きゃ', 'きゅ', 'きょ'],
  ['しゃ', 'しゅ', 'しょ'],
  ['ちゃ', 'ちゅ', 'ちょ'],
  ['にゃ', 'にゅ', 'にょ'],
  ['ひゃ', 'ひゅ', 'ひょ'],
  ['みゃ', 'みゅ', 'みょ'],
  ['りゃ', 'りゅ', 'りょ'],
  ['ぎゃ', 'ぎゅ', 'ぎょ'],
  ['じゃ', 'じゅ', 'じょ'],
  ['びゃ', 'びゅ', 'びょ'],
  ['ぴゃ', 'ぴゅ', 'ぴょ'],
];
const _youKata = [
  ['キャ', 'キュ', 'キョ'],
  ['シャ', 'シュ', 'ショ'],
  ['チャ', 'チュ', 'チョ'],
  ['ニャ', 'ニュ', 'ニョ'],
  ['ヒャ', 'ヒュ', 'ヒョ'],
  ['ミャ', 'ミュ', 'ミョ'],
  ['リャ', 'リュ', 'リョ'],
  ['ギャ', 'ギュ', 'ギョ'],
  ['ジャ', 'ジュ', 'ジョ'],
  ['ビャ', 'ビュ', 'ビョ'],
  ['ピャ', 'ピュ', 'ピョ'],
];
const _youRomaji = [
  ['kya', 'kyu', 'kyo'],
  ['sha', 'shu', 'sho'],
  ['cha', 'chu', 'cho'],
  ['nya', 'nyu', 'nyo'],
  ['hya', 'hyu', 'hyo'],
  ['mya', 'myu', 'myo'],
  ['rya', 'ryu', 'ryo'],
  ['gya', 'gyu', 'gyo'],
  ['ja', 'ju', 'jo'],
  ['bya', 'byu', 'byo'],
  ['pya', 'pyu', 'pyo'],
];

/// 50음도 — 청음·탁음·요음 × 히라가나/가타카나. 셀 탭 → TTS.
class KanaChartScreen extends StatefulWidget {
  const KanaChartScreen({super.key});

  @override
  State<KanaChartScreen> createState() => _KanaChartScreenState();
}

class _KanaChartScreenState extends State<KanaChartScreen> {
  int _set = 0; // 0 청음, 1 탁음, 2 요음
  bool _showRomaji = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.washi,
        appBar: AppBar(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr('50음도와 발음'), style: TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
              SizedBox(height: 2),
              Text(tr('탭하면 발음·IPA 상세'), style: TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
            ],
          ),
          actions: [
            IconButton(
              tooltip: tr('로마자'),
              icon: Text('Aa',
                  style: TextStyle(
                      fontWeight: FontWeight.w900, color: _showRomaji ? AppColors.beni : AppColors.sumiLight)),
              onPressed: () => setState(() => _showRomaji = !_showRomaji),
            ),
          ],
          bottom: const TabBar(
            tabs: [Tab(text: 'ひらがな'), Tab(text: 'カタカナ')],
            labelColor: AppColors.beni,
            unselectedLabelColor: AppColors.sumiLight,
            indicatorColor: AppColors.beni,
            labelStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: SeigaihaPattern(opacity: 0.05)),
            Column(
              children: [
                _setChips(),
                const AsanohaDivider(height: 8),
                Expanded(
                  child: TabBarView(
                    children: [
                      _chart(katakana: false),
                      _chart(katakana: true),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _setChips() {
    final labels = [tr('청음 46'), tr('탁음·반탁음 25'), tr('요음 33')];
    return Container(
      color: AppColors.washiDeep,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: List.generate(3, (i) {
          final selected = _set == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _set = i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: selected ? AppColors.beni : AppColors.washi,
                  border: Border.all(color: AppColors.beni, width: selected ? 1.5 : 0.8),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    color: selected ? AppColors.washi : AppColors.beni,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _chart({required bool katakana}) {
    final List<List<String>> rows;
    final List<List<String>> romaji;
    final List<String> names;
    final int cols;
    switch (_set) {
      case 1:
        rows = katakana ? _dakuKata : _dakuHira;
        romaji = _dakuRomaji;
        names = _dakuRowNames;
        cols = 5;
        break;
      case 2:
        rows = katakana ? _youKata : _youHira;
        romaji = _youRomaji;
        names = rows.map((r) => r.first).toList();
        cols = 3;
        break;
      default:
        rows = katakana ? _kata : _hira;
        romaji = _romaji;
        names = _rowNames;
        cols = 5;
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(12, 12, 12, 80 + bottomInset(context)),
      itemCount: rows.length,
      itemBuilder: (context, r) {
        final color = _set == 2 ? kanaRowColor(r + 1) : (_set == 1 ? kanaRowColor(r + 1) : kanaRowColor(r));
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 58,
                alignment: Alignment.center,
                color: color,
                child: Text(
                  names[r],
                  style: const TextStyle(color: AppColors.washi, fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Row(
                  children: List.generate(cols, (c) {
                    final k = rows[r][c];
                    final ro = romaji[r][c];
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: k.isEmpty
                            ? const SizedBox(height: 58)
                            : InkWell(
                                onTap: () => showKanaSoundSheet(context, kana: k, romaji: ro, color: color),
                                child: Container(
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: AppColors.washi,
                                    border: Border.all(color: color.withValues(alpha: 0.7)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: color.withValues(alpha: 0.12),
                                        blurRadius: 4,
                                        offset: const Offset(1, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        k,
                                        style: TextStyle(
                                          fontSize: cols == 3 ? 20 : 24,
                                          fontWeight: FontWeight.w900,
                                          color: AppColors.sumi,
                                          height: 1.1,
                                        ),
                                      ),
                                      if (_showRomaji)
                                        Text(
                                          ro,
                                          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w700),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }
}
