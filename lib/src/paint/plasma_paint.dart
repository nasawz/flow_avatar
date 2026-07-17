import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../avatar_model.dart';
import 'motion_style.dart';
import 'paint_common.dart';

/// Paints a multi-sine plasma field mapped through the model palette.
void paintFlowAvatarPlasma(
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

  canvas.drawRect(rect, Paint()..color = model.background);

  final seedAngle = flowAvatarSeedAngle(model.seed);
  final freqBoost = 1.0 + style.orbit * 8 + style.rotation * 0.15;
  final motion = style.motion * intensity.clamp(0.15, 2.0);
  final contrastPulse = 1.0 + style.pulse * 1.4;

  // Seed-stable frequency offsets so identities differ.
  final f1 = 2.2 + (model.seed % 5) * 0.35;
  final f2 = 1.7 + ((model.seed ~/ 7) % 5) * 0.28;
  final f3 = 2.8 + ((model.seed ~/ 13) % 4) * 0.4;

  final paint = Paint()..style = PaintingStyle.fill;

  for (var gy = 0; gy < n; gy++) {
    for (var gx = 0; gx < n; gx++) {
      final x = (gx + 0.5) / n;
      final y = (gy + 0.5) / n;

      // Mild contraction for listening / error.
      var px = x;
      var py = y;
      if (style.contraction != 0) {
        final c = style.contraction * (0.5 + 0.5 * math.sin(theta * 2.4));
        px += (0.5 - px) * c;
        py += (0.5 - py) * c;
      }

      final rx = px - 0.5;
      final ry = py - 0.5;
      final r = math.sqrt(rx * rx + ry * ry);

      final t = theta * motion;
      var field =
          math.sin(px * f1 * freqBoost * math.pi + t + seedAngle) +
          math.sin(py * f2 * freqBoost * math.pi - t * 0.73) +
          math.sin((px + py) * f3 * math.pi + t * 1.15) +
          math.sin(r * 6.5 * freqBoost - t * 0.9 + seedAngle * 0.5);

      // Normalize roughly from [-4, 4] → [0, 1], then apply contrast pulse.
      var v = (field / 4.0) * 0.5 + 0.5;
      v = ((v - 0.5) * contrastPulse) + 0.5;
      v = v.clamp(0.0, 1.0);

      paint.color = flowAvatarSamplePalette(colors, v);
      canvas.drawRect(
        Rect.fromLTWH(gx * cell, gy * cell, cell + 0.5, cell + 0.5),
        paint,
      );
    }
  }

  paintFlowAvatarWash(canvas, rect, style);
  paintFlowAvatarVignette(
    canvas,
    rect,
    edgeDarkness: edgeDarkness,
    strength: 0.85,
  );
}
