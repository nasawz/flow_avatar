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

  testWidgets('updates identity and state without throwing', (tester) async {
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

  testWidgets('continuous phase advances across multi-second spans', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FlowAvatar(
          seed: 'loop-seam',
          animated: true,
          speed: 1,
          state: FlowAvatarState.idle,
        ),
      ),
    );

    // Advance well past the old 8s modular loop boundary; continuous phase
    // must not throw or leave a stuck ticker.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 8));
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(FlowAvatar), findsOneWidget);
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

  test('default pattern is mesh', () {
    const avatar = FlowAvatar(seed: 'default-pattern');
    expect(avatar.pattern, FlowAvatarPattern.mesh);
  });

  testWidgets('each pattern paints without throwing', (tester) async {
    for (final pattern in FlowAvatarPattern.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: FlowAvatar(
            seed: 'pattern-$pattern',
            size: 64,
            pattern: pattern,
            animated: false,
            state: FlowAvatarState.thinking,
          ),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'pattern $pattern');
    }
  });

  testWidgets('switching pattern live does not throw', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FlowAvatar(
          seed: 'switch',
          pattern: FlowAvatarPattern.mesh,
          animated: false,
        ),
      ),
    );
    await tester.pumpWidget(
      const MaterialApp(
        home: FlowAvatar(
          seed: 'switch',
          pattern: FlowAvatarPattern.dither,
          animated: true,
          state: FlowAvatarState.speaking,
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 50));
    expect(tester.takeException(), isNull);
  });
}
