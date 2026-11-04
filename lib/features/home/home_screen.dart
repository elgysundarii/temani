import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../core/game_config.dart';
import '../../widgets/components.dart';
import '../pet/pet_stage.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _send() {
    final err = ref.read(chatProvider.notifier).validate(_text.text);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(err == 'message_empty' ? 'Tulis sedikit dulu ya, pelan-pelan saja.' : 'Ceritanya agak panjang. Bisa dipotong jadi beberapa bagian?'),
      ));
      return;
    }
    final text = _text.text;
    _text.clear();
    context.push('/chat', extra: text);
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final progress = ref.watch(progressProvider);
    final settings = ref.watch(settingsProvider);
    final now = ref.watch(clockProvider)();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Temani'),
        actions: [
          IconButton(tooltip: 'Riwayat', onPressed: () => context.push('/history'), icon: const Icon(Icons.menu_book_rounded)),
          IconButton(tooltip: 'Pengaturan', onPressed: () => context.push('/settings'), icon: const Icon(Icons.settings_rounded)),
        ],
      ),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), children: [
        PetStage(state: chat.pet, reduceMotion: settings.reduceMotion, height: 300),
        StoryInputCard(
          controller: _text,
          onSend: _send,
          onChanged: (v) => ref.read(chatProvider.notifier).typing(v.isNotEmpty),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => context.push('/jar'),
          child: Semantics(
            button: true,
            label: 'Buka toples dan streak',
            child: Row(children: [
              Expanded(child: StreakCard(state: progress.streak, now: now, compact: true)),
              const SizedBox(width: 12),
              Card(
                color: const Color(0xFFFFF3C4),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    const StarWidget(size: 32),
                    Text('${progress.jar.stars.length}/${GameConfig.jarCapacity}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                    const Text('toples', style: TextStyle(fontSize: 13)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
