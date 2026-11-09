import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/l10n.dart';
import '../core/theme.dart';

/// 이용약관·개인정보처리방침 주소(출시 점검 2026-11-09, uk 공통). 결제 화면·로그인·설정에서 같은 링크를 쓴다.
class Legal {
  Legal._();
  static const terms = 'https://talkverse.uk/terms/';
  static const privacy = 'https://talkverse.uk/talkverse/ja/privacy/';
  static Future<void> open(String url) => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}

/// 「이용약관 · 개인정보처리방침」 한 줄 링크.
class LegalLinks extends StatelessWidget {
  final String? lead; // 앞에 붙는 안내(예: 로그인 동의 문구)
  const LegalLinks({super.key, this.lead});
  @override
  Widget build(BuildContext context) {
    const link = TextStyle(fontSize: 12, color: AppColors.ai, fontWeight: FontWeight.w700, decoration: TextDecoration.underline);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      if (lead != null) Text(lead!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11.5, color: AppColors.muted, height: 1.45)),
      Wrap(alignment: WrapAlignment.center, crossAxisAlignment: WrapCrossAlignment.center, children: [
        TextButton(onPressed: () => Legal.open(Legal.terms), child: Text(tr('이용약관'), style: link)),
        const Text('·', style: TextStyle(color: AppColors.muted)),
        TextButton(onPressed: () => Legal.open(Legal.privacy), child: Text(tr('개인정보처리방침'), style: link)),
      ]),
    ]);
  }
}

/// 맞춤 회화(AI 생성) 표시 + 신고(스토어 심사 대비, 2026-11-09). 신고는 메일로 — 편 ID 가 제목에 들어간다.
class AiContentBanner extends StatelessWidget {
  final String id;
  const AiContentBanner({super.key, required this.id});
  static const reportMail = 'talkverse.lab@gmail.com';

  Future<void> _report() => launchUrl(Uri(
        scheme: 'mailto',
        path: reportMail,
        query: 'subject=${Uri.encodeComponent('[신고] 맞춤 회화 $id')}&body=${Uri.encodeComponent('어떤 문장이 어떻게 문제인지 적어 주세요.\n\n')}',
      ));

  @override
  Widget build(BuildContext context) => Container(
        color: AppColors.ai.withValues(alpha: 0.07),
        padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
        child: Row(children: [
          const Icon(Icons.auto_awesome, size: 16, color: AppColors.ai),
          const SizedBox(width: 8),
          Expanded(child: Text(tr('AI 가 만든 회화입니다. 어색하거나 부적절한 내용이 있으면 신고해 주세요.'), style: const TextStyle(fontSize: 12, color: AppColors.sumi, height: 1.35))),
          TextButton.icon(
            onPressed: _report,
            icon: const Icon(Icons.flag_outlined, size: 16, color: AppColors.beniDeep),
            label: Text(tr('신고'), style: const TextStyle(fontSize: 12.5, color: AppColors.beniDeep, fontWeight: FontWeight.w800)),
          ),
        ]),
      );
}
