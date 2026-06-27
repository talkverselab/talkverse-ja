import 'package:go_router/go_router.dart';
import 'screens/home_dashboard.dart';
import 'screens/deck_list.dart';
import 'screens/card_session.dart';
import 'screens/srs_progress.dart';
import 'screens/kana_chart.dart';
import 'screens/settings.dart';
import 'screens/profile.dart';
import 'screens/about_app.dart';
import 'screens/onboarding.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const HomeDashboardScreen()),
    GoRoute(path: '/onboarding', builder: (c, s) => const OnboardingScreen()),
    GoRoute(path: '/decks', builder: (c, s) => const DeckListScreen()),
    GoRoute(
      path: '/session/:deckId',
      builder: (c, s) => CardSessionScreen(deckId: s.pathParameters['deckId']!),
    ),
    GoRoute(path: '/progress', builder: (c, s) => const SrsProgressScreen()),
    GoRoute(path: '/kana', builder: (c, s) => const KanaChartScreen()),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
    GoRoute(path: '/profile', builder: (c, s) => const ProfileScreen()),
    GoRoute(path: '/about', builder: (c, s) => const AboutAppScreen()),
  ],
);
