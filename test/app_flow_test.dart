import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:temani/app.dart';
import 'package:temani/app_state.dart';
import 'package:temani/data/mock_temani_api.dart';
import 'package:temani/features/pet/pet_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = false;

  testWidgets('onboarding -> story -> pet adapts, star earned', (tester) async {
    final container = ProviderContainer(overrides: [
      apiProvider.overrideWithValue(MockTemaniApi(latency: const Duration(milliseconds: 50))),
    ]);
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const TemaniApp()));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Halo, aku Temani'), findsOneWidget);
    await tester.tap(find.text('Lanjut'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Lanjut'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Saya mengerti dan setuju'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));

    await tester.enterText(find.byType(TextField), 'aku sedih banget hari ini');
    await tester.tap(find.byIcon(Icons.send_rounded));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));

    expect(container.read(chatProvider).pet, PetState.gentle);
    expect(container.read(progressProvider).jar.stars.length, 1);
    expect(container.read(progressProvider).streak.current, 1);

    // Leave the widget tree so repeating animations/timers stop.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 7));
  });
}
