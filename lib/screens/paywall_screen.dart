import 'package:flutter/material.dart';

import '../core/l10n.dart';
import '../core/platform.dart';
import '../core/theme.dart';
import '../services/account.dart';
import '../services/purchase.dart';
import 'login_screen.dart';

/// 유료 잠금 시트 — 평생 이용권 가격 + 인앱 결제 버튼(한자앱 `paywall_screen.dart` 복제, 2026-11-02).
/// 아래에서 올라오는 시트. 사거나 복원되면 닫힌다. 로그인은 선택(기기 간 공유용).
class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});
  static const lang = 'ja';
  static const referencePriceKrw = 14900; // 스토어 가격을 못 받았을 때 참고가(한자앱과 같음)

  static Future<void> show(BuildContext context) {
    Purchase.status.value = null;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.washi,
      builder: (_) => const PaywallScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: Purchase.status,
      builder: (c, st, _) {
        if (st == 'done' || st == 'restored') {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.canPop(c)) Navigator.pop(c);
          });
        }
        final busy = st == 'pending';
        return ValueListenableBuilder(
          valueListenable: Purchase.products,
          builder: (c, _, _) {
            final storePrice = Purchase.price(lang);
            final price = storePrice ?? '₩${referencePriceKrw.toString().replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]},')}';
            return SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 4, 24, 20 + bottomInset(context)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Row(children: [
                    Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: AppColors.beni.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.lock_outline, color: AppColors.beni)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(tr('유료 기능입니다'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.beni)),
                        Text(tr('평생 이용권'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.sumi)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(gradient: AppColors.wordmark, borderRadius: BorderRadius.circular(18)),
                    child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(price, style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, height: 1)),
                      const SizedBox(width: 10),
                      Expanded(child: Text(tr('한 번 결제 · 구독 아님 · 평생'), style: const TextStyle(fontSize: 12.5, color: Colors.white70, fontWeight: FontWeight.w700))),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  _row(Icons.check_circle, tr('맞춤 회화 만들기 무제한 (주제·상황·레벨을 골라 나만의 회화)')),
                  _row(Icons.check_circle, tr('앞으로 추가되는 주제·레벨·장면 그림도 추가 결제 없이')),
                  _row(Icons.check_circle, tr('로그인하면 아이폰·아이패드·안드로이드 어디서나')),
                  _row(Icons.check_circle_outline, tr('회화·단어·한자·복습은 계속 무료'), muted: true),
                  const SizedBox(height: 14),
                  if (st == 'error') Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(tr('결제를 마치지 못했습니다. 다시 시도해 주세요.'), style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700))),
                  if (st == 'nothing') Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(tr('복원할 구매가 없습니다.'), style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700))),
                  FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.beni, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(54), textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900), shape: const StadiumBorder()),
                    onPressed: busy || storePrice == null ? null : () => Purchase.buy(lang),
                    child: busy
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                        : Text(storePrice == null ? tr('스토어에 연결하는 중…') : '${tr('평생 이용권 구매')} · $price'),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(shape: const StadiumBorder(), side: const BorderSide(color: AppColors.line)),
                    onPressed: busy ? null : () => Purchase.restore(),
                    child: Text(tr('이전 구매 복원'), style: const TextStyle(color: AppColors.sumi, fontWeight: FontWeight.w700)),
                  ),
                  const SizedBox(height: 12),
                  ValueListenableBuilder(
                    valueListenable: Account.user,
                    builder: (c, u, _) => u == null
                        ? TextButton(
                            onPressed: () => LoginScreen.open(context),
                            child: Text(tr('로그인하면 다른 기기에서도 이용권이 열립니다 (선택)'), style: const TextStyle(fontSize: 12.5, color: AppColors.ai)),
                          )
                        : Text(tr('로그인됨 — 구매는 Talkverse 계정에 기록되어 다른 기기에서도 열립니다.'), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12.5, color: AppColors.muted)),
                  ),
                  Text(
                    tr('결제는 App Store / Google Play 에서 처리됩니다. 표시 가격은 스토어 가격을 따르며 세금이 포함될 수 있습니다.'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4),
                  ),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _row(IconData icon, String text, {bool muted = false}) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: muted ? AppColors.muted : AppColors.matcha),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(fontSize: 14, height: 1.35, color: muted ? AppColors.muted : AppColors.sumi, fontWeight: FontWeight.w600))),
        ]),
      );
}
