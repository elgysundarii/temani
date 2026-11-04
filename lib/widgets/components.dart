import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_colors.dart';
import '../features/streak/streak_logic.dart';

/// Primary button: ink text on yellow, small press-scale, light haptic.
class TemaniButton extends StatefulWidget {
  const TemaniButton({super.key, required this.label, required this.onPressed, this.secondary = false});
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;

  @override
  State<TemaniButton> createState() => _TemaniButtonState();
}

class _TemaniButtonState extends State<TemaniButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: enabled
            ? () {
                HapticFeedback.lightImpact();
                widget.onPressed!();
              }
            : null,
        child: AnimatedScale(
          scale: _down ? 0.96 : 1,
          duration: const Duration(milliseconds: 90),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52, minWidth: 120),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.secondary ? AppColors.yellow100 : (enabled ? AppColors.primary : AppColors.yellow200),
              borderRadius: BorderRadius.circular(26),
              border: widget.secondary ? Border.all(color: AppColors.yellow600) : null,
            ),
            child: Text(widget.label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ),
      ),
    );
  }
}

class StoryInputCard extends StatelessWidget {
  const StoryInputCard({super.key, required this.controller, required this.onSend, this.onChanged, this.enabled = true, this.hint = 'Ceritakan harimu...'});
  final TextEditingController controller;
  final VoidCallback onSend;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              minLines: 1,
              maxLines: 4,
              onChanged: onChanged,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(hintText: hint, border: InputBorder.none, filled: false),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            tooltip: 'Kirim cerita',
            style: IconButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.ink),
            onPressed: enabled ? onSend : null,
            icon: const Icon(Icons.send_rounded),
          ),
        ]),
      ),
    );
  }
}

class ChatBubble extends StatefulWidget {
  const ChatBubble({super.key, required this.text, required this.fromUser, this.typewriter = false, this.reduceMotion = false});
  final String text;
  final bool fromUser;
  final bool typewriter;
  final bool reduceMotion;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: (widget.text.length * 28).clamp(300, 3000)),
  );
  late final bool _animate = widget.typewriter && !widget.reduceMotion;

  @override
  void initState() {
    super.initState();
    if (_animate) {
      _c.forward();
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.fromUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: GestureDetector(
        onTap: () => _c.value = 1, // tap to skip typing
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
          decoration: BoxDecoration(
            color: user ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(22),
              topRight: const Radius.circular(22),
              bottomLeft: Radius.circular(user ? 22 : 6),
              bottomRight: Radius.circular(user ? 6 : 22),
            ),
            boxShadow: [BoxShadow(color: AppColors.ink.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, _) {
              final n = (widget.text.length * _c.value).round();
              return Semantics(
                label: widget.text,
                child: ExcludeSemantics(
                  child: Text(widget.text.substring(0, n), style: const TextStyle(color: AppColors.ink, fontSize: 16, height: 1.4)),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class StarWidget extends StatelessWidget {
  const StarWidget({super.key, this.size = 24, this.color = AppColors.yellow500});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Icon(Icons.star_rounded, size: size, color: color);
}

Future<bool?> showSoftDialog(BuildContext context, {required String title, required String body, required String confirm, String cancel = 'Batal'}) {
  return showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppColors.yellow50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
      content: Text(body),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(cancel, style: const TextStyle(color: AppColors.ink))),
        TemaniButton(label: confirm, onPressed: () => Navigator.pop(context, true)),
      ],
    ),
  );
}

class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.state, required this.now, this.compact = false});
  final StreakState state;
  final DateTime now;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final marks = StreakLogic.weekMarks(state, now);
    return Card(
      color: AppColors.yellow100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.pets_rounded, color: AppColors.yellow600, size: 32),
            const SizedBox(width: 10),
            Text('${state.current}', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900)),
            const SizedBox(width: 10),
            const Expanded(child: Text('hari bercerita berturut-turut', style: TextStyle(fontSize: 15))),
          ]),
          if (!compact) ...[
            const SizedBox(height: 4),
            Text('Rekor terpanjang: ${state.longest} hari', style: const TextStyle(color: AppColors.inkSoft)),
          ],
          const SizedBox(height: 10),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            for (final m in marks)
              Semantics(
                label: switch (m.status) {
                  DayStatus.story => 'Ada cerita',
                  DayStatus.rest => 'Hari istirahat',
                  DayStatus.none => 'Belum ada cerita',
                },
                child: Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: m.status == DayStatus.none ? AppColors.yellow50 : AppColors.yellow200,
                  ),
                  child: switch (m.status) {
                    DayStatus.story => const StarWidget(size: 18),
                    DayStatus.rest => const Icon(Icons.nightlight_round, size: 16, color: AppColors.inkSoft),
                    DayStatus.none => null,
                  },
                ),
              ),
          ]),
        ]),
      ),
    );
  }
}

/// Deterministic slot for star #i inside the jar (0..1 coordinates).
Offset starSlot(int i) {
  final row = i ~/ 3;
  final col = i % 3;
  final x = 0.25 + col * 0.25 + (row.isOdd ? 0.06 : -0.02);
  final y = 0.85 - row * 0.14;
  return Offset(x.clamp(0.2, 0.8), y);
}

double jarWobble(double t) => sin(t * pi * 6) * (1 - t) * 0.06;
