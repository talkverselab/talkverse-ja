import 'package:flutter/material.dart';

/// 두 화면(넓은 화면)의 오른쪽 칸 — 왼쪽 탭 목록·메뉴에서 연 화면이 여기에 열린다.
/// 폰(한 화면)에는 이 위젯이 없어서 openPane 이 보통 push 로 동작한다. 한자유니버스 lib/core/pane.dart 와 같은 구조.
class Pane extends InheritedWidget {
  final GlobalKey<NavigatorState> navKey;

  /// 레일(맨 왼쪽 탭 메뉴)만 남기고 목록 칸 + 오른쪽 칸을 함께 덮는 넓은 칸 — 회화처럼 가로로 넓게 써야 하는 화면용.
  final GlobalKey<NavigatorState>? wideKey;
  const Pane({super.key, required this.navKey, this.wideKey, required super.child});

  static Pane? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Pane>();

  @override
  bool updateShouldNotify(Pane oldWidget) => oldWidget.navKey != navKey || oldWidget.wideKey != wideKey;
}

/// 화면 열기. 넓은 화면이면 오른쪽 칸에 — 왼쪽(메뉴·목록)에서 열면 오른쪽 칸을 통째로 바꾸고,
/// 오른쪽 칸 안에서 열면 그 위에 쌓는다. 넓은 칸(openWide) 안에서 열면 그 넓은 칸 위에 쌓는다. 한 화면이면 그냥 push.
Future<T?> openPane<T>(BuildContext context, WidgetBuilder builder) {
  final pane = Pane.maybeOf(context);
  final nav = pane?.navKey.currentState;
  if (nav == null) return Navigator.push<T>(context, MaterialPageRoute(builder: builder));
  final here = Navigator.of(context);
  if (here == nav) return nav.push<T>(MaterialPageRoute(builder: builder));
  final wide = pane?.wideKey?.currentState;
  if (wide != null && here == wide) return wide.push<T>(MaterialPageRoute(builder: builder));
  return nav.pushAndRemoveUntil<T>(MaterialPageRoute(builder: builder), (r) => false);
}

/// 넓은 칸에 열기 — 넓은 화면에서는 맨 왼쪽 레일은 남기고 목록 칸 + 오른쪽 칸 자리에 연다(사용자 지시 2026-11-10 회화 화면).
/// 한 화면(폰)이면 그냥 push.
Future<T?> openWide<T>(BuildContext context, WidgetBuilder builder) {
  final wide = Pane.maybeOf(context)?.wideKey?.currentState;
  if (wide == null) return Navigator.push<T>(context, MaterialPageRoute(builder: builder));
  return wide.push<T>(MaterialPageRoute(builder: builder));
}

/// 학습(에피소드·플래시카드 세션·퀴즈)은 넓은 화면에서도 왼쪽 목록을 감추고 **전체 화면**으로 연다.
Future<T?> openFull<T>(BuildContext context, WidgetBuilder builder) =>
    Navigator.of(context, rootNavigator: true).push<T>(MaterialPageRoute(builder: builder));
