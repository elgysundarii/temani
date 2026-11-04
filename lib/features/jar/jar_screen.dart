import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_state.dart';
import '../../core/format.dart';
import '../../core/game_config.dart';
import '../../widgets/components.dart';
import '../../widgets/energy_jar.dart';

class JarScreen extends ConsumerWidget {
  const JarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(progressProvider);
    final chat = ref.watch(chatProvider);
    final reduce = ref.watch(settingsProvider).reduceMotion;
    final now = ref.watch(clockProvider)();
    return Scaffold(
      appBar: AppBar(title: const Text('Toples Energi Bahagia')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        EnergyJar(
          stars: progress.jar.stars,
          dropStarId: chat.lastStarId,
          reduceMotion: reduce,
          onStarTap: (s) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Bintang dari ${formatDate(s.earnedAt)}${s.note != null ? '\nMomen kecil: ${s.note}' : ''}'),
          )),
        ),
        Center(child: Text('${progress.jar.stars.length} dari ${GameConfig.jarCapacity} bintang', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
        const SizedBox(height: 4),
        Center(child: Text('Koleksi toples penuh: ${progress.jar.jarsCompleted}', style: const TextStyle(color: Color(0xFF6B5738)))),
        const SizedBox(height: 4),
        const Center(child: Text('Bintang datang karena kamu bercerita, apa pun perasaanmu.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B5738)))),
        const SizedBox(height: 16),
        StreakCard(state: progress.streak, now: now),
      ]),
    );
  }
}
