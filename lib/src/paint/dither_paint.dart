import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../avatar_model.dart';
import 'bayer.dart';
import 'motion_style.dart';
import 'paint_common.dart';

/// Paints an animated ordered dither of the model palette.
///
/// Structure follows the outpace ordered-dither DNA (Bayer 8×8 along a seed
/// gradient axis). Motion rotates and scrolls the axis with continuous phase.
void paintFlowAvatarDither(
  Canvas canvas,
  Size size, {
  required FlowAvatarModel model,
  required double theta,
  required AvatarMotionStyle style,
  required double intensity,
  required double edgeDarkness,
}) {
  final rect = Offset.zero & size;
  final shortestSide = size.shortestSide;
  final grid = flowAvatarGrid(shortestSide);
  final n = grid.count;
  final cell = grid.cell;
  final colors = flowAvatarTintedPalette(model.colors, style);
  if (colors.isEmpty) {
    canvas.drawRect(rect, Paint()..color = model.background);
    return;
  }

  final baseAngle = flowAvatarSeedAngle(model.seed);
  final angle =
      baseAngle + theta * style.rotation * 0.35 * intensity.clamp(0.0, 2.0);
  final dx = math.cos(angle);
  final dy = math.sin(angle);
  final minProj = math.min(0.0, dx) + math.min(0.0, dy);
  final span = (dx.abs() + dy.abs()).clamp(1e-6, double.infinity);

  // Scroll so bands crawl; speaking/thinking boost via pulse + motion.
  final scroll =
      theta *
      (0.12 + style.motion * 0.08 + style.pulse * 0.25) *
      intensity.clamp(0.15, 2.0);

  // Listening contracts usable range toward the middle of the palette.
  final rangeScale = 1.0 - style.contraction * 0.35;
  final rangeOffset = (1.0 - rangeScale) * 0.5;

  final paint = Paint()..style = PaintingStyle.fill;

  for (var gy = 0; gy < n; gy++) {
    for (var gx = 0; gx < n; gx++) {
      final px = (gx + 0.5) / n;
      final py = (gy + 0.5) / n;
      var v = ((px * dx + py * dy - minProj) / span);
      v = rangeOffset + v * rangeScale;
      v = flowAvatarFract(v + scroll);

      final scaled = v * (colors.length - 1);
      final index = scaled.floor().clamp(0, colors.length - 1);
      final frac = scaled - index;
      final threshold = kBayer8[gy % 8][gx % 8];
      final colorIndex = frac > threshold
          ? math.min(index + 1, colors.length - 1)
          : index;

      paint.color = colors[colorIndex];
      canvas.drawRect(
        Rect.fromLTWH(gx * cell, gy * cell, cell + 0.5, cell + 0.5),
        paint,
      );
    }
  }

  paintFlowAvatarWash(canvas, rect, style);
  paintFlowAvatarCrispRim(canvas, rect, edgeDarkness: edgeDarkness);
}
