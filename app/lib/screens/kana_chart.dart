import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/app_background.dart';

const _hiraRows = [
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

const _kataRows = [
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
  ['wa', '', '', '', 'wo'],
  ['n', '', '', '', ''],
];

class KanaChartScreen extends StatelessWidget {
  const KanaChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('かな 50音', style: TextStyle(fontWeight: FontWeight.w700)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'ひらがな'),
              Tab(text: 'カタカナ'),
            ],
            labelColor: AppColors.ink,
            unselectedLabelColor: AppColors.inkLight,
            indicatorColor: AppColors.sakuraDeep,
            labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
        ),
        body: AppBackground(
          scatterSeed: 17,
          child: TabBarView(
            children: [
              _chart(_hiraRows, accent: AppColors.sakura),
              _chart(_kataRows, accent: AppColors.honeySoft),
            ],
          ),
        ),
      ),
    );
  }

  Widget _chart(List<List<String>> rows, {required Color accent}) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: [
        for (int i = 0; i < rows.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: List.generate(5, (j) {
                final char = rows[i][j];
                final roma = _romaji[i][j];
                if (char.isEmpty) return const Expanded(child: SizedBox(height: 64));
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.cardFront,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.inkOutline, width: 0.8),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.ink.withValues(alpha: 0.06),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                          spreadRadius: -1,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(char, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink)),
                        Text(roma, style: const TextStyle(fontSize: 10, color: AppColors.inkSoft, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
