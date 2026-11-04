import 'package:flutter/material.dart';
import 'pet_stage.dart';
import 'pet_state.dart';

class PetDebugScreen extends StatefulWidget {
  const PetDebugScreen({super.key});

  @override
  State<PetDebugScreen> createState() => _PetDebugScreenState();
}

class _PetDebugScreenState extends State<PetDebugScreen> {
  PetState _state = PetState.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coba semua state pet')),
      body: Column(children: [
        PetStage(state: _state, height: 320),
        Wrap(
          spacing: 8,
          children: [
            for (final s in PetState.values)
              ChoiceChip(
                label: Text(s.name),
                selected: s == _state,
                onSelected: (_) => setState(() => _state = s),
              ),
          ],
        ),
      ]),
    );
  }
}
