import 'package:flow_avatar/flow_avatar.dart';
import 'package:flutter/painting.dart';
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

  test('baseColor anchors palette while keeping layout from identity', () {
    const blue = Color(0xFF3498DB);
    const red = Color(0xFFE74C3C);

    final plain = FlowAvatarModel.fromIdentity('assistant');
    final blueModel = FlowAvatarModel.fromIdentity(
      'assistant',
      baseColor: blue,
    );
    final blueAgain = FlowAvatarModel.fromIdentity(
      'assistant',
      baseColor: blue,
    );
    final redModel = FlowAvatarModel.fromIdentity('assistant', baseColor: red);

    expect(blueModel.colors, blueAgain.colors);
    expect(blueModel.spots.length, plain.spots.length);
    for (var i = 0; i < plain.spots.length; i++) {
      expect(blueModel.spots[i].position, plain.spots[i].position);
      expect(blueModel.spots[i].radius, plain.spots[i].radius);
      expect(blueModel.spots[i].phase, plain.spots[i].phase);
      expect(blueModel.spots[i].amplitude, plain.spots[i].amplitude);
      expect(redModel.spots[i].position, plain.spots[i].position);
    }

    expect(blueModel.colors, isNot(equals(plain.colors)));
    expect(redModel.colors, isNot(equals(blueModel.colors)));

    final blueHue = HSLColor.fromColor(blueModel.colors.first).hue;
    final seedHue = HSLColor.fromColor(blue).hue;
    final hueDelta = (blueHue - seedHue).abs();
    expect(hueDelta < 20 || hueDelta > 340, isTrue);
  });

  test('baseColor palettes stay luminous even for dark primaries', () {
    const darkNavy = Color(0xFF1A237E);
    const brown = Color(0xFF5D4037);

    for (final color in [darkNavy, brown]) {
      final model = FlowAvatarModel.fromIdentity('assistant', baseColor: color);
      for (final swatch in model.colors) {
        final hsl = HSLColor.fromColor(swatch);
        expect(hsl.lightness, greaterThanOrEqualTo(0.52));
        expect(hsl.saturation, lessThanOrEqualTo(0.86));
      }
      expect(
        HSLColor.fromColor(model.background).lightness,
        greaterThanOrEqualTo(0.45),
      );
    }
  });

  test('monochrome mode keeps all palette hues on one hue', () {
    const amber = Color(0xFFFFB300);
    final model = FlowAvatarModel.fromIdentity(
      'community-ai-xiaomai',
      baseColor: amber,
      colorMode: FlowAvatarColorMode.monochrome,
    );
    final targetHue = HSLColor.fromColor(amber).hue;
    for (final swatch in model.colors) {
      final hue = HSLColor.fromColor(swatch).hue;
      final delta = (hue - targetHue).abs();
      expect(delta < 1.5 || delta > 358.5, isTrue);
    }
    // Spots only sample the mono palette.
    for (final spot in model.spots) {
      final hue = HSLColor.fromColor(spot.color).hue;
      final delta = (hue - targetHue).abs();
      expect(delta < 1.5 || delta > 358.5, isTrue);
    }
  });

  test('harmonic mode may introduce companion hues away from base', () {
    const violet = Color(0xFF651FFF);
    // Try a few identities until the seeded relationship is multi-hue.
    var foundSpread = false;
    for (final id in ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j']) {
      final model = FlowAvatarModel.fromIdentity(id, baseColor: violet);
      final targetHue = HSLColor.fromColor(violet).hue;
      for (final swatch in model.colors) {
        final delta = (HSLColor.fromColor(swatch).hue - targetHue).abs();
        final wrapped = delta > 180 ? 360 - delta : delta;
        if (wrapped > 25) {
          foundSpread = true;
          break;
        }
      }
      if (foundSpread) break;
    }
    expect(foundSpread, isTrue);
  });
}
