import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app_state.dart';
import '../../widgets/components.dart';
import '../pet/pet_stage.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.initialText});
  final String? initialText;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _text = TextEditingController();
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final t = widget.initialText;
    if (t != null && t.trim().isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(chatProvider.notifier).send(t));
    }
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send() {
    final n = ref.read(chatProvider.notifier);
    final err = n.validate(_text.text);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err == 'message_empty' ? 'Tulis sedikit dulu ya.' : 'Ceritanya agak panjang. Bisa dipotong?')));
      return;
    }
    final t = _text.text;
    _text.clear();
    n.send(t);
  }

  Future<void> _smallMoment() async {
    final c = TextEditingController();
    final n = ref.read(chatProvider.notifier);
    final save = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFFFFFBEB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Satu momen kecil yang melegakan hari ini?'),
        content: TextField(controller: c, decoration: const InputDecoration(hintText: 'Boleh kosong')),
        actions: [
          TemaniButton(label: 'Lewati', secondary: true, onPressed: () => Navigator.pop(ctx, false)),
          TemaniButton(label: 'Simpan', onPressed: () => Navigator.pop(ctx, true)),
        ],
      ),
    );
    if (save == true) {
      n.saveSmallMoment(c.text.trim().isEmpty ? null : c.text.trim());
    } else {
      n.dismissSmallMoment();
    }
    c.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(chatProvider);
    final reduce = ref.watch(settingsProvider).reduceMotion;
    ref.listen(chatProvider.select((s) => s.messages.length), (_, _) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(_scroll.position.maxScrollExtent, duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
        }
      });
    });
    return PopScope(
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) Future.microtask(() => ref.read(chatProvider.notifier).endConversation());
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Bercerita')),
        body: Column(children: [
          PetStage(state: chat.pet, reduceMotion: reduce, height: 190),
          if (chat.notice != null)
            Padding(padding: const EdgeInsets.only(bottom: 4), child: Text(chat.notice!, style: const TextStyle(fontWeight: FontWeight.w700))),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: chat.messages.length,
              itemBuilder: (_, i) {
                final m = chat.messages[i];
                return ChatBubble(
                  key: ValueKey('$i${m.text}'),
                  text: m.text,
                  fromUser: m.fromUser,
                  typewriter: !m.fromUser && i == chat.messages.length - 1,
                  reduceMotion: reduce,
                );
              },
            ),
          ),
          if (chat.canOfferSmallMoment)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Expanded(child: TemaniButton(label: 'Ada momen kecil yang melegakan', secondary: true, onPressed: _smallMoment)),
                const SizedBox(width: 8),
                TemaniButton(label: 'Lewati', secondary: true, onPressed: ref.read(chatProvider.notifier).dismissSmallMoment),
              ]),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
              child: StoryInputCard(
                controller: _text,
                enabled: !chat.busy,
                hint: chat.busy ? 'Temani sedang mendengarkan...' : 'Tulis di sini...',
                onSend: _send,
                onChanged: (v) => ref.read(chatProvider.notifier).typing(v.isNotEmpty),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
