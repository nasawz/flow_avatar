import 'dart:math' as math;

import 'package:flutter/painting.dart';

import 'avatar_seed.dart';

/// Immutable, deterministic visual identity used by [FlowAvatar].
final class FlowAvatarModel {
  /// Creates a model from precomputed visual fields.
  const FlowAvatarModel({
    required this.seed,
    required this.colors,
    required this.background,
    required this.spots,
    required this.highlightPosition,
  });

  /// Builds the same model for the same [identity] on every invocation.
  ///
  /// When [baseColor] is provided, the palette is anchored to that color's
  /// **hue** while layout remains driven by [identity]. Lightness is lifted
  /// into a luminous band so theme primaries (often mid/dark) do not muddy
  /// the avatar. The same [identity] + [baseColor] pair always yields the
  /// same model. Changing only [baseColor] recolors the avatar without
  /// reshaping spot geometry.
  factory FlowAvatarModel.fromIdentity(String identity, {Color? baseColor}) {
    final seed = flowAvatarSeed(identity);
    final random = SeededRandom(seed);
    final colors = _createPalette(seed, random, baseColor: baseColor);
    final spotCount = 9 + random.nextInt(4);
    final spots = List.generate(spotCount, (index) {
      final angle = random.between(0, math.pi * 2);
      final distance = random.between(0.08, 0.48);
      final center = Offset(
        0.5 + math.cos(angle) * distance,
        0.5 + math.sin(angle) * distance,
      );
      return FlowAvatarSpot(
        position: center,
        radius: random.between(0.32, 0.72),
        color: colors[(index + random.nextInt(colors.length)) % colors.length],
        phase: random.between(0, math.pi * 2),
        harmonicX: 1 + random.nextInt(2),
        harmonicY: 1 + random.nextInt(2),
        amplitude: Offset(
          random.between(0.06, 0.15),
          random.between(0.06, 0.15),
        ),
      );
    })..sort((a, b) => b.radius.compareTo(a.radius));

    // Theme-anchored palettes already sit bright; only gently deepen the bed.
    // Seed-only palettes keep a richer dark underpainting.
    final backgroundShift = baseColor == null ? -0.16 : -0.05;

    return FlowAvatarModel(
      seed: seed,
      colors: List.unmodifiable(colors),
      background: _shiftLightness(colors.first, backgroundShift),
      spots: List.unmodifiable(spots),
      highlightPosition: Offset(
        random.between(0.18, 0.38),
        random.between(0.14, 0.34),
      ),
    );
  }

  /// Stable numeric seed derived from the identity string.
  final int seed;

  /// Five-color palette used by spots and the background.
  final List<Color> colors;

  /// Darkened base color painted under the spots.
  final Color background;

  /// Ordered radial color fields, largest first.
  final List<FlowAvatarSpot> spots;

  /// Normalized position of the soft white highlight.
  final Offset highlightPosition;
}

/// One normalized radial color field in a [FlowAvatarModel].
final class FlowAvatarSpot {
  /// Creates a single animated color spot.
  const FlowAvatarSpot({
    required this.position,
    required this.radius,
    required this.color,
    required this.phase,
    required this.harmonicX,
    required this.harmonicY,
    required this.amplitude,
  });

  /// Center of the spot in normalized 0–1 coordinates.
  final Offset position;

  /// Radius as a fraction of the avatar's shortest side.
  final double radius;

  /// Base color before state tinting.
  final Color color;

  /// Phase offset for the motion wave.
  final double phase;

  /// Horizontal harmonic frequency multiplier.
  final int harmonicX;

  /// Vertical harmonic frequency multiplier.
  final int harmonicY;

  /// Motion amplitude in normalized coordinates.
  final Offset amplitude;
}

List<Color> _createPalette(int seed, SeededRandom random, {Color? baseColor}) {
  const goldenAngle = 137.507764;
  const relationships = <List<double>>[
    [0, 28, -32, 58, -62],
    [0, 120, 240, 38, 202],
    [0, 150, 210, 32, 182],
    [0, 90, 180, 270, 45],
    [0, 180, 26, -28, 152],
  ];
  final baseHsl = baseColor == null ? null : HSLColor.fromColor(baseColor);
  final baseHue = baseHsl?.hue ?? ((seed * goldenAngle) % 360);
  final relationship = relationships[random.nextInt(relationships.length)];

  return [
    for (var i = 0; i < relationship.length; i++)
      _paletteColor(
        baseHue: baseHue,
        hueOffset: relationship[i],
        random: random,
        baseHsl: baseHsl,
        isPrimarySlot: i == 0,
      ),
  ];
}

Color _paletteColor({
  required double baseHue,
  required double hueOffset,
  required SeededRandom random,
  required HSLColor? baseHsl,
  required bool isPrimarySlot,
}) {
  final hue = _normalizeHue(baseHue + hueOffset + random.between(-7, 7));

  late final double saturation;
  late final double lightness;
  if (baseHsl == null) {
    saturation = random.between(0.62, 0.91);
    lightness = random.between(0.48, 0.67);
  } else {
    // Anchor hue only. Lift sat/light into a candy-jelly band so Material
    // primaries (often mid-dark and heavy) read as luminous fields.
    final softSat = (baseHsl.saturation * 0.72 + 0.18).clamp(0.52, 0.84);
    final liftedLight = _liftLightness(baseHsl.lightness);
    if (isPrimarySlot) {
      saturation = (softSat + random.between(-0.03, 0.05)).clamp(0.50, 0.86);
      lightness = (liftedLight + random.between(-0.02, 0.06)).clamp(0.56, 0.78);
    } else {
      saturation = (softSat + random.between(-0.10, 0.08)).clamp(0.46, 0.84);
      lightness = (liftedLight + random.between(-0.04, 0.10)).clamp(0.52, 0.80);
    }
  }

  return HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
}

/// Pushes theme lightness into a bright band without erasing hue family.
///
/// Dark primaries (L ~ 0.25–0.40) lift strongly; already-light seeds only
/// nudge slightly so yellows/cyans do not wash out.
double _liftLightness(double sourceLightness) {
  const target = 0.64;
  const minLift = 0.54;
  // Blend toward target: dark colors move more (weight 0.75+).
  final weight = (1.0 - sourceLightness).clamp(0.45, 0.85);
  final lifted = sourceLightness * (1 - weight) + target * weight;
  return lifted < minLift ? minLift : lifted;
}

double _normalizeHue(double hue) {
  final mod = hue % 360;
  return mod < 0 ? mod + 360 : mod;
}

Color _shiftLightness(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness + amount).clamp(0.08, 0.92))
      .toColor();
}
