import 'package:flow_avatar/flow_avatar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('same identity creates the same visual model', () {
    final first = FlowAvatarModel.fromIdentity('ada');
    final second = FlowAvatarModel.fromIdentity('ada');

    expect(first.seed, second.seed);
    expect(first.colors, second.colors);
    expect(first.background, second.background);
    expect(first.highlightPosition, second.highlightPosition);
    expect(first.spots.length, second.spots.length);

    for (var i = 0; i < first.spots.length; i++) {
      expect(first.spots[i].position, second.spots[i].position);
      expect(first.spots[i].radius, second.spots[i].radius);
      expect(first.spots[i].color, second.spots[i].color);
      expect(first.spots[i].phase, second.spots[i].phase);
      expect(first.spots[i].amplitude, second.spots[i].amplitude);
    }
  });

  test('model contains a rich but bounded composition', () {
    final model = FlowAvatarModel.fromIdentity('grace');

    expect(model.colors, hasLength(5));
    expect(model.spots.length, inInclusiveRange(9, 12));
    expect(model.spots, everyElement(isA<FlowAvatarSpot>()));
  });
}
