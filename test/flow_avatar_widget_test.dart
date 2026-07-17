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

  test('state speed multipliers differ across conversational modes', () {
    expect(flowAvatarStateSpeed(FlowAvatarState.thinking), greaterThan(2));
    expect(
      flowAvatarStateSpeed(FlowAvatarState.thinking),
      greaterThan(flowAvatarStateSpeed(FlowAvatarState.idle)),
    );
    expect(
      flowAvatarStateSpeed(FlowAvatarState.listening),
      lessThan(flowAvatarStateSpeed(FlowAvatarState.idle)),
    );
    expect(
      flowAvatarStateSpeed(FlowAvatarState.error),
      lessThan(flowAvatarStateSpeed(FlowAvatarState.speaking)),
    );
  });

  testWidgets('rebuilds palette when baseColor changes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FlowAvatar(
          seed: 'assistant',
          animated: false,
          baseColor: Color(0xFF3498DB),
        ),
      ),
    );
    expect(find.byType(FlowAvatar), findsOneWidget);

    await tester.pumpWidget(
      const MaterialApp(
        home: FlowAvatar(
          seed: 'assistant',
          animated: false,
          baseColor: Color(0xFFE74C3C),
        ),
      ),
    );
    await tester.pump();

    final avatar = tester.widget<FlowAvatar>(find.byType(FlowAvatar));
    expect(avatar.baseColor, const Color(0xFFE74C3C));
    expect(tester.takeException(), isNull);
  });
}
