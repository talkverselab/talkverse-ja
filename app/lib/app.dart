import 'package:flutter/material.dart';
import 'theme.dart';
import 'router.dart';

class JapaneseUniverseApp extends StatelessWidget {
  const JapaneseUniverseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '일본어유니버스',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
