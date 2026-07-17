import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'motion_style.dart';

/// Max cells along the short side for grid-based patterns.
const int kFlowAvatarMaxGridCells = 64;

/// Reference divisor used by ordered dither cell sizing (matches outpace DNA).
const double kFlowAvatarDitherCellDivisor = 72;

/// Computes a bounded grid resolution for pattern painters.
///
/// Returns `(cellSize, cellCount)` where [cellCount] is clamped so large
/// avatars do not explode per-frame draw cost.
({double cell, int count}) flowAvatarGrid(double shortestSide) {
  final raw = math.max(
    2,
    (shortestSide / kFlowAvatarDitherCellDivisor).round(),
  );
  var count = math.max(1, (shortestSide / raw).ceil());
  if (count > kFlowAvatarMaxGridCells) {
    count = kFlowAvatarMaxGridCells;
  }
  final cell = shortestSide / count;
  return (cell: cell, count: count);
}

/// Fractional part in `[0, 1)`.
double flowAvatarFract(double value) {
  final f = value - value.floorToDouble();
  return f < 0 ? f + 1 : f;
}

/// Samples a multi-stop palette at [t] in `[0, 1]`.
Color flowAvatarSamplePalette(List<Color> colors, double t) {
  if (colors.isEmpty) {
    return Colors.transparent;
  }
  if (colors.length == 1) {
    return colors.first;
  }
  final clamped = t.clamp(0.0, 1.0);
  final scaled = clamped * (colors.length - 1);
  final index = scaled.floor().clamp(0, colors.length - 2);
  final frac = scaled - index;
  return Color.lerp(colors[index], colors[index + 1], frac)!;
}

/// Applies state tint to a base color.
Color flowAvatarTintedColor(Color color, AvatarMotionStyle style) {
  if (style.tintAmount <= 0) {
    return color;
  }
  return Color.lerp(color, style.tint, style.tintAmount)!;
}

/// Builds a tinted copy of the model palette.
List<Color> flowAvatarTintedPalette(
  List<Color> colors,
  AvatarMotionStyle style,
) {
  if (style.tintAmount <= 0) {
    return colors;
  }
  return [for (final color in colors) flowAvatarTintedColor(color, style)];
}

/// Broad state wash so success/error read at tiny sizes.
void paintFlowAvatarWash(Canvas canvas, Rect rect, AvatarMotionStyle style) {
  if (style.washAmount <= 0) {
    return;
  }
  canvas.drawRect(
    rect,
    Paint()..color = style.tint.withValues(alpha: style.washAmount),
  );
}

/// Soft vignette + narrow rim (mesh / plasma / ribbon / noise).
void paintFlowAvatarVignette(
  Canvas canvas,
  Rect rect, {
  required double edgeDarkness,
  double strength = 1,
}) {
  if (edgeDarkness <= 0 || strength <= 0) {
    return;
  }
  final shortestSide = rect.shortestSide;
  final edge = edgeDarkness * strength;

  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(
        Offset(rect.center.dx, rect.center.dy - shortestSide * 0.04),
        shortestSide * 0.72,
        [
          Colors.transparent,
          Colors.black.withValues(alpha: edge * 0.28),
          Colors.black.withValues(alpha: edge),
        ],
        const [0.48, 0.76, 1],
      ),
  );

  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(
        rect.center,
        shortestSide * 0.70,
        [Colors.transparent, Colors.black.withValues(alpha: edge * 0.55)],
        const [0.88, 1],
      ),
  );
}

/// Thin rim only — keeps ordered dither pixels crisp.
void paintFlowAvatarCrispRim(
  Canvas canvas,
  Rect rect, {
  required double edgeDarkness,
}) {
  if (edgeDarkness <= 0) {
    return;
  }
  final shortestSide = rect.shortestSide;
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(
        rect.center,
        shortestSide * 0.70,
        [
          Colors.transparent,
          Colors.black.withValues(alpha: edgeDarkness * 0.35),
        ],
        const [0.90, 1],
      ),
  );
}

/// Stable angle in radians from a numeric seed.
double flowAvatarSeedAngle(int seed) {
  // Mix bits so low seeds do not cluster near zero.
  final mixed = (seed * 2654435761) & 0x7fffffff;
  return (mixed / 0x7fffffff) * math.pi * 2;
}
