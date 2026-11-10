import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanese_universe/core/pane.dart';

/// 넓은 칸(openWide): 레일은 남고 목록 칸 + 오른쪽 칸을 덮는다. 그 안에서 openPane 은 넓은 칸 위에 쌓인다.
void main() {
  testWidgets('openWide covers list+pane, keeps rail, stacks openPane inside', (tester) async {
    final pane = GlobalKey<NavigatorState>(), wide = GlobalKey<NavigatorState>();
    await tester.pumpWidget(MaterialApp(
      home: Pane(
        navKey: pane,
        wideKey: wide,
        child: Scaffold(
          body: Row(children: [
            const SizedBox(width: 80, child: Text('RAIL')),
            Expanded(
              child: Stack(fit: StackFit.expand, children: [
                Row(children: [
                  SizedBox(width: 300, child: Builder(builder: (c) => TextButton(onPressed: () => openWide(c, (_) => Scaffold(body: Builder(builder: (c2) => TextButton(onPressed: () => openPane(c2, (_) => const Scaffold(body: Text('INNER'))), child: const Text('WIDE'))))), child: const Text('LIST')))),
                  Expanded(child: Navigator(key: pane, onGenerateInitialRoutes: (_, _) => [MaterialPageRoute(builder: (_) => const Text('PANE'))])),
                ]),
                Navigator(key: wide, onGenerateInitialRoutes: (_, _) => [PageRouteBuilder(opaque: false, pageBuilder: (_, _, _) => const SizedBox.shrink())]),
              ]),
            ),
          ]),
        ),
      ),
    ));
    wide.currentState!.push(MaterialPageRoute(builder: (_) => Scaffold(body: Builder(builder: (c2) => TextButton(onPressed: () => openPane(c2, (_) => const Scaffold(body: Text('INNER'))), child: const Text('WIDE'))))));
    await tester.pumpAndSettle();
    expect(find.text('RAIL'), findsOneWidget);
    expect(find.text('WIDE'), findsOneWidget);
    expect(tester.getSize(find.byType(Scaffold).last).width, 720); // 800 - 레일 80
    await tester.tap(find.text('WIDE'));
    await tester.pumpAndSettle();
    expect(find.text('INNER'), findsOneWidget);
    expect(wide.currentState!.canPop(), isTrue);
    expect(pane.currentState!.canPop(), isFalse); // 오른쪽 칸은 건드리지 않았다
  });
}
