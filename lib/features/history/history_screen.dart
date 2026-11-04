import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_state.dart';
import '../../core/format.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(progressProvider).history;
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat cerita')),
      body: items.isEmpty
          ? const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Belum ada cerita tersimpan. Tidak apa-apa, kapan pun kamu siap.', textAlign: TextAlign.center)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final e = items[i];
                return Card(
                  child: ListTile(
                    title: Text(e.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                    subtitle: Text(formatDate(e.at)),
                    trailing: IconButton(
                      tooltip: 'Hapus cerita ini',
                      icon: const Icon(Icons.delete_outline_rounded),
                      onPressed: () => ref.read(progressProvider.notifier).removeHistory(e),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
