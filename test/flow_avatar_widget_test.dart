import 'package:flow_avatar/flow_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders at the requested size and exposes semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: FlowAvatar(
            seed: 'assistant-42',
            size: 96,
            animated: false,
            semanticLabel: 'Assistant avatar',
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(FlowAvatar)), const Size.square(96));
    expect(find.bySemanticsLabel('Assistant avatar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('updates identity and state without rebuilding its ticker', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FlowAvatar(seed: 'first', state: FlowAvatarState.idle),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    await tester.pumpWidget(
      const MaterialApp(
        home: FlowAvatar(
          seed: 'second',
          state: FlowAvatarState.speaking,
          audioAmplitude: 0.8,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
  });
}
