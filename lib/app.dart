import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/chat_screen.dart';
import 'features/history/history_screen.dart';
import 'features/home/home_screen.dart';
import 'features/jar/jar_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/pet/pet_debug_screen.dart';
import 'features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier(0);
  ref.listen(settingsProvider.select((s) => s.onboarded), (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);
  return GoRouter(
    refreshListenable: refresh,
    redirect: (context, state) {
      final done = ref.read(settingsProvider).onboarded;
      if (!done && state.matchedLocation != '/onboarding') return '/onboarding';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
      GoRoute(path: '/onboarding', builder: (_, _) => const OnboardingScreen()),
      GoRoute(path: '/chat', builder: (_, s) => ChatScreen(initialText: s.extra as String?)),
      GoRoute(path: '/jar', builder: (_, _) => const JarScreen()),
      GoRoute(path: '/history', builder: (_, _) => const HistoryScreen()),
      GoRoute(path: '/settings', builder: (_, _) => const SettingsScreen()),
      GoRoute(path: '/pet-debug', builder: (_, _) => const PetDebugScreen()),
    ],
  );
});

class TemaniApp extends ConsumerWidget {
  const TemaniApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Temani',
      theme: buildTemaniTheme(),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
