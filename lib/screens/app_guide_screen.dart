import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../widgets/japanese_decor.dart';

/// 앱 사용법 — 처음 쓰는 사람을 위한 순서·탭별 안내·알아 둘 것(사용자 지시 2026-11-08 "앱사용법 만들라고 했잖아").
/// 들어가는 곳: 두 화면 왼쪽 레일 맨 아래(「앱 소개」 위), 설정 및 프로필 → 정보.
class AppGuideScreen extends StatelessWidget {
  const AppGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.washi,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(tr('앱 사용법'), style: const TextStyle(color: AppColors.sumi, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 2),
            Text(tr('처음이라면 이 순서로'), style: const TextStyle(color: AppColors.sumiLight, fontSize: 10, letterSpacing: 2)),
          ],
        ),
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 24 + bottomInset(context)),
        children: [
          _Lead(tr('하루 15분이면 충분합니다. 배우기에서 새 것을 익히고, 복습에서 잊기 전에 다시 보고, 탐색에서 궁금한 것을 찾습니다.')),
          const SizedBox(height: 18),
          _H(tr('1. 추천 순서')),
          _Step('①', tr('50음도와 발음'), tr('히라가나·가타카나를 먼저 익힙니다. 글자를 누르면 소리와 입모양이 나옵니다.')),
          _Step('②', tr('주제별 회화'), tr('R0(왕초보)부터 시작합니다. 문장의 ▶ 로 원어민 음성을 듣고, 밑줄 친 단어를 누르면 단어창, 한자를 길게 누르면 한자 설명이 열립니다.')),
          _Step('③', tr('절벽 단어'), tr('R1부터 20어씩 한 단원입니다. 타일을 누르면 발음합니다. 자주 나오는 말부터라 적게 외워도 많이 들립니다.')),
          _Step('④', tr('오늘의 복습'), tr('매일 열어서 나온 카드만 넘기면 됩니다. 맞히면 다음 복습 간격이 늘고, 틀리면 처음부터 다시 나옵니다.')),
          const SizedBox(height: 18),
          _H(tr('2. 탭별 안내')),
          _Step('学', tr('배우기'), tr('기초(50음도·한자) → 문법(조사) → 회화 → 단어 → 에피소드 → 참고(패밀리 한자) 순서로 놓여 있습니다.')),
          _Step('復', tr('복습'), tr('오늘의 복습 카드, 문장 플래시카드, 복습 덱, 한자 퀴즈, 조사 테스트.')),
          _Step('探', tr('탐색'), tr('한자 사전·한자음, JLPT 단어, 절벽 단어, 영어 등에서 온 말.')),
          _Step('我', tr('설정 및 프로필'), tr('진행·성과, 이름과 성별(회화 속 「나」), 표시 언어, 후리가나.')),
          const SizedBox(height: 18),
          _H(tr('3. 알아 두면 좋은 것')),
          _Step('ふ', tr('후리가나'), tr('화면 위 「ふ」 버튼으로 켜고 끕니다. 기본은 숨김입니다 — 힘들어도 보지 않고 익혀 보세요.')),
          _Step('♂♀', tr('성별'), tr('설정에서 고른 성별에 따라 회화 속 「나」의 말투(僕/私 등)와 목소리가 바뀝니다.')),
          _Step('▭▭', tr('큰 화면'), tr('가로 화면·태블릿에서는 왼쪽 목록, 오른쪽 내용으로 나뉩니다. 학습·퀴즈는 전체 화면으로 열립니다.')),
          _Step('ⓘ', tr('앱 소개'), tr('단어·한자를 R1~R5 로 나눈 기준(절벽구간)은 「앱 소개」에 있습니다.')),
          const SizedBox(height: 24),
          const BrushDivider(),
          const SizedBox(height: 10),
          Center(child: Text(tr('継続は力なり · 계속은 힘이다'), style: const TextStyle(color: AppColors.sumiLight, fontSize: 11, letterSpacing: 2))),
        ],
      ),
    );
  }
}

class _Lead extends StatelessWidget {
  final String text;
  const _Lead(this.text);
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line), boxShadow: kCardShadow),
        child: Text(text, style: const TextStyle(color: AppColors.sumi, fontSize: 14, height: 1.6)),
      );
}

class _H extends StatelessWidget {
  final String text;
  const _H(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GradText(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
      );
}

class _Step extends StatelessWidget {
  final String mark, title, body;
  const _Step(this.mark, this.title, this.body);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: AppColors.washiDeep, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.line)),
              child: Text(mark, style: const TextStyle(color: AppColors.sumi, fontSize: 14, fontWeight: FontWeight.w800)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppColors.sumi, fontSize: 14.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 2),
                  Text(body, style: const TextStyle(color: AppColors.sumiLight, fontSize: 13, height: 1.5)),
                ],
              ),
            ),
          ],
        ),
      );
}
