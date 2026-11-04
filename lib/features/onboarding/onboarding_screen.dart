import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../widgets/components.dart';
import '../pet/pet_stage.dart';
import '../pet/pet_state.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _page = PageController();
  int _i = 0;

  static const _pages = [
    ('Halo, aku Temani', 'Aku kucing teman bercerita. Kamu tidak perlu merawatku. Aku yang menyesuaikan diri denganmu.', PetState.cheerful),
    ('Yang perlu kamu tahu', 'Temani adalah teman bercerita virtual, bukan alat diagnosis atau pengganti psikolog. Kalau kamu butuh bantuan profesional, hubungi tenaga yang berwenang di dekatmu.', PetState.gentle),
    ('Soal datamu', 'Teks ceritamu dikirim ke server pemrosesan untuk dianalisis. Data streak dan toples hanya tersimpan di perangkatmu. Kamu bisa menghapus semuanya kapan saja di Pengaturan.', PetState.normal),
  ];

  @override
  Widget build(BuildContext context) {
    final last = _i == _pages.length - 1;
    final reduce = ref.watch(settingsProvider).reduceMotion;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(children: [
            Expanded(
              child: PageView.builder(
                controller: _page,
                itemCount: _pages.length,
                onPageChanged: (v) => setState(() => _i = v),
                itemBuilder: (_, i) => SingleChildScrollView(
                  child: Column(children: [
                    PetStage(state: _pages[i].$3, reduceMotion: reduce, height: 280),
                    const SizedBox(height: 8),
                    Text(_pages[i].$1, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
                    const SizedBox(height: 12),
                    Text(_pages[i].$2, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, height: 1.5)),
                  ]),
                ),
              ),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              for (var i = 0; i < _pages.length; i++)
                Container(
                  margin: const EdgeInsets.all(4),
                  width: i == _i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(color: i == _i ? const Color(0xFFB26A03) : const Color(0xFFFFE58A), borderRadius: BorderRadius.circular(4)),
                ),
            ]),
            const SizedBox(height: 12),
            TemaniButton(
              label: last ? 'Saya mengerti dan setuju' : 'Lanjut',
              onPressed: () {
                if (last) {
                  ref.read(settingsProvider.notifier).update((s) => s.copyWith(onboarded: true));
                  context.go('/');
                } else {
                  _page.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeOut);
                }
              },
            ),
          ]),
        ),
      ),
    );
  }
}
