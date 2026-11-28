import 'dart:convert';

import 'package:http/http.dart' as http;

import '../usage_log.dart';
import 'account.dart';

/// 화면 열람 기록의 화면 ID — 서버 화면 목록(tool/usage_catalog.json, tool/usage_catalog.py 가 만든다)의 `page` 와 글자까지 같아야 한다.
/// ID 꼴을 바꾸면 tool/usage_catalog.py 도 같이 고치고 목록을 다시 내보낼 것(test/usage_pages_test.dart 가 견준다).
class UsagePages {
  UsagePages._();

  /// 회화 한 편(편 id 그대로).
  static String conv(String id) => 'conv/$id';

  /// 언어감각 회차(회차 id 그대로).
  static String sense(String lessonId) => 'sense/$lessonId';

  /// 급별 JLPT 한 장.
  static String course(int level, int chapter) => 'course/n$level/$chapter';

  /// 문형 누적 읽기 한 단원. [confuse] = 헷갈리는 말.
  static String pattern(int unit, {bool confuse = false}) => '${confuse ? 'conf' : 'pat'}/u$unit';

  /// JLPT 낱말 한 급.
  static String words(int level) => 'words/n$level';

  static void view(String page) => UsageLog.view(page);
}

/// 환불 규정의 열람률 기준 — 숫자는 여기 한 곳(서버 `rule` 이 오면 그 값을 쓴다).
class RefundRule {
  RefundRule._();
  static const blockPct = 30; // 유료 화면을 이만큼(%) 이상 열면 환불 없음
  static const url = 'https://talkverse.uk/refund/';
}

/// 「내 정보」 열람률 — 유료 화면 중 연 수 / 전체. 못 받으면 null(표시하지 않는다).
class UsageSummary {
  final int viewed, total, blockPct;
  const UsageSummary(this.viewed, this.total, this.blockPct);
  int get pct => total == 0 ? 0 : (viewed * 100 / total).floor();

  static Future<UsageSummary?> fetch({http.Client? client}) async {
    try {
      final at = await Account.accessToken();
      if (at == null) return null;
      final r = await (client ?? http.Client())
          .get(Uri.parse('${Account.base}/v1/usage/summary?lang=ja'), headers: {'Authorization': 'Bearer $at'})
          .timeout(const Duration(seconds: 8));
      if (r.statusCode != 200) return null;
      return parse(jsonDecode(r.body) as Map<String, dynamic>, exam: Account.hasExam('ja'));
    } catch (_) {
      return null;
    }
  }

  /// 유료 = pro, 시험 권한이 있으면 exam 도 합친다(서버 환불 계산과 같은 기준).
  static UsageSummary parse(Map<String, dynamic> j, {required bool exam}) {
    var v = 0, t = 0;
    for (final x in (j['tiers'] as List? ?? const [])) {
      final m = x as Map;
      if (m['tier'] == 'pro' || (exam && m['tier'] == 'exam')) {
        v += (m['viewed'] as num?)?.toInt() ?? 0;
        t += (m['total'] as num?)?.toInt() ?? 0;
      }
    }
    final rule = j['rule'];
    final b = rule is Map ? rule['none_from'] : null; // 비율(0.3)
    return UsageSummary(v, t, b is num && b > 0 && b <= 1 ? (b * 100).round() : RefundRule.blockPct);
  }
}
