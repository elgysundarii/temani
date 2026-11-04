import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app_state.dart';
import '../../widgets/components.dart';

const aboutText =
    'Temani adalah teman bercerita virtual, bukan alat diagnosis, bukan terapi, dan bukan pengganti psikolog atau tenaga profesional. '
    'Aplikasi ini tidak mengklaim dapat memperbaiki suasana hati.\n\n'
    'Kalau kamu merasa ingin menyakiti diri sendiri, tolong hubungi orang yang kamu percaya atau tenaga profesional di dekatmu. '
    'Kamu tidak harus menghadapinya sendirian.\n\n'
    'Kontak bantuan: belum diisi. TODO-USER: kontak bantuan Indonesia yang sudah diverifikasi.';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(children: [
        SwitchListTile(
          title: const Text('Kurangi gerakan'),
          subtitle: const Text('Animasi diganti perubahan sederhana'),
          value: s.reduceMotion,
          onChanged: (v) => n.update((x) => x.copyWith(reduceMotion: v)),
        ),
        SwitchListTile(
          title: const Text('Simpan riwayat cerita'),
          subtitle: const Text('Hanya di perangkat ini'),
          value: s.saveHistory,
          onChanged: (v) => n.update((x) => x.copyWith(saveHistory: v)),
        ),
        ListTile(
          title: const Text('Informasi pemrosesan data'),
          subtitle: const Text('Hanya teks cerita yang dikirim untuk dianalisis. Streak dan toples tetap di perangkat.'),
        ),
        ListTile(
          title: const Text('Tentang dan batasan'),
          trailing: const Icon(Icons.chevron_right_rounded),
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
            builder: (_) => Scaffold(
              appBar: AppBar(title: const Text('Tentang dan batasan')),
              body: const Padding(padding: EdgeInsets.all(20), child: Text(aboutText, style: TextStyle(fontSize: 16, height: 1.5))),
            ),
          )),
        ),
        if (kDebugMode)
          ListTile(
            title: const Text('Debug: coba semua state pet'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/pet-debug'),
          ),
        const Divider(),
        ListTile(
          title: const Text('Hapus semua data', style: TextStyle(color: Color(0xFFC2410C), fontWeight: FontWeight.w700)),
          onTap: () async {
            final first = await showSoftDialog(context, title: 'Hapus semua data?', body: 'Riwayat, streak, dan toples di perangkat ini akan dihapus.', confirm: 'Lanjut');
            if (first != true || !context.mounted) return;
            final second = await showSoftDialog(context, title: 'Yakin?', body: 'Ini tidak bisa dibatalkan.', confirm: 'Ya, hapus semua');
            if (second == true) {
              ref.read(progressProvider.notifier).clearAll();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Semua data sudah dihapus.')));
            }
          },
        ),
      ]),
    );
  }
}
