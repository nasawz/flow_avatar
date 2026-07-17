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
  factory FlowAvatarModel.fromIdentity(String identity) {
    final seed = flowAvatarSeed(identity);
    final random = SeededRandom(seed);
    final colors = _createPalette(seed, random);
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

    return FlowAvatarModel(
      seed: seed,
      colors: List.unmodifiable(colors),
      background: _shiftLightness(colors.first, -0.16),
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

List<Color> _createPalette(int seed, SeededRandom random) {
  const goldenAngle = 137.507764;
  const relationships = <List<double>>[
    [0, 28, -32, 58, -62],
    [0, 120, 240, 38, 202],
    [0, 150, 210, 32, 182],
    [0, 90, 180, 270, 45],
    [0, 180, 26, -28, 152],
  ];
  final baseHue = (seed * goldenAngle) % 360;
  final relationship = relationships[random.nextInt(relationships.length)];
  return relationship
      .map((offset) {
        final hue = (baseHue + offset + random.between(-7, 7)) % 360;
        final saturation = random.between(0.62, 0.91);
        final lightness = random.between(0.48, 0.67);
        return HSLColor.fromAHSL(1, hue, saturation, lightness).toColor();
      })
      .toList(growable: false);
}

Color _shiftLightness(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness + amount).clamp(0.08, 0.92))
      .toColor();
}
