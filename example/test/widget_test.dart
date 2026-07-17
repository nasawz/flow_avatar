import 'package:flow_avatar_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the avatar gallery', (tester) async {
    await tester.pumpWidget(const FlowAvatarExample());

    expect(find.text('One identity. Always alive.'), findsOneWidget);
    expect(find.text('aurora'), findsOneWidget);
    expect(find.byTooltip('Switch to light background'), findsOneWidget);

    await tester.tap(find.byTooltip('Switch to light background'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byTooltip('Switch to dark background'), findsOneWidget);
  });
}
