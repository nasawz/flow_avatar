import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../avatar_model.dart';
import 'motion_style.dart';
import 'paint_common.dart';

/// Paints scrolling color ribbons from the model palette.
void paintFlowAvatarRibbon(
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
  final motion = style.motion * intensity.clamp(0.15, 2.0);
  final scroll = theta * (0.55 + style.rotation * 0.12) * motion;
  final twist = style.orbit * 4.0 + style.rotation * 0.08;
  final bandPulse = 1.0 + style.pulse * 1.8;

  // Three seed-stable ribbon directions / phases.
  final ribbons =
      <({double nx, double ny, double phase, double amp, int c0, int c1})>[
        (
          nx: math.cos(seedAngle),
          ny: math.sin(seedAngle),
          phase: 0.0,
          amp: 0.55,
          c0: 0,
          c1: math.min(1, colors.length - 1),
        ),
        (
          nx: math.cos(seedAngle + 2.1),
          ny: math.sin(seedAngle + 2.1),
          phase: 1.7,
          amp: 0.4,
          c0: math.min(1, colors.length - 1),
          c1: math.min(2, colors.length - 1),
        ),
        (
          nx: math.cos(seedAngle + 4.0),
          ny: math.sin(seedAngle + 4.0),
          phase: 3.3,
          amp: 0.48,
          c0: math.min(2, colors.length - 1),
          c1: math.min(3, colors.length - 1),
        ),
      ];

  final paint = Paint()..style = PaintingStyle.fill;

  for (var gy = 0; gy < n; gy++) {
    for (var gx = 0; gx < n; gx++) {
      final x = (gx + 0.5) / n;
      final y = (gy + 0.5) / n;

      var px = x;
      var py = y;
      if (style.contraction != 0) {
        final c = style.contraction * (0.5 + 0.5 * math.sin(theta * 2.4));
        px += (0.5 - px) * c;
        py += (0.5 - py) * c;
      }

      // Soft composite of ribbon fields → palette position.
      var field = 0.0;
      var weight = 0.0;
      for (var i = 0; i < ribbons.length; i++) {
        final r = ribbons[i];
        final shear = math.sin(px * 3.5 + py * 2.2 + theta * twist + r.phase);
        final ridge = math.sin(
          (px * r.nx + py * r.ny) * (5.5 + i) * bandPulse +
              scroll * (1.0 + i * 0.2) +
              r.phase +
              shear * 0.45,
        );
        // Soft band mask: high near ridge crest.
        final band = math.pow((ridge + 1) * 0.5, 1.6).toDouble();
        field += band * r.amp * (i + 1);
        weight += r.amp * (i + 1);
      }

      final v = (field / weight.clamp(1e-6, double.infinity)).clamp(0.0, 1.0);
      // Bias toward palette ends for clearer stripe identity.
      final shaped = math.pow(v, 0.85).toDouble();
      paint.color = flowAvatarSamplePalette(colors, shaped);
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
    strength: 0.8,
  );
}
