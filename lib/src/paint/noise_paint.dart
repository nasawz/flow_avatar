import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../avatar_model.dart';
import 'motion_style.dart';
import 'paint_common.dart';

/// Integer hash → unit float in [0, 1).
double _hash2(int x, int y, int salt) {
  var n = x * 374761393 + y * 668265263 + salt * 1442695041;
  n = (n ^ (n >> 13)) * 1274126177;
  n ^= n >> 16;
  return (n & 0x7fffffff) / 0x80000000;
}

double _smoothstep(double t) => t * t * (3 - 2 * t);

/// Value noise at continuous coordinates.
double _valueNoise(double x, double y, int salt) {
  final x0 = x.floor();
  final y0 = y.floor();
  final fx = _smoothstep(x - x0);
  final fy = _smoothstep(y - y0);

  final v00 = _hash2(x0, y0, salt);
  final v10 = _hash2(x0 + 1, y0, salt);
  final v01 = _hash2(x0, y0 + 1, salt);
  final v11 = _hash2(x0 + 1, y0 + 1, salt);

  final a = uiLerp(v00, v10, fx);
  final b = uiLerp(v01, v11, fx);
  return uiLerp(a, b, fy);
}

double uiLerp(double a, double b, double t) => a + (b - a) * t;

/// Paints soft procedural noise / marble drift through the model palette.
void paintFlowAvatarNoise(
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

  final salt = model.seed & 0x7fffffff;
  final motion = style.motion * intensity.clamp(0.15, 2.0);
  final driftSpeed = 0.35 + style.rotation * 0.08 + style.orbit * 2.0;
  final driftX = math.cos(theta * driftSpeed) * 0.55 * motion;
  final driftY = math.sin(theta * driftSpeed * 0.87) * 0.55 * motion;
  final warpPhase = theta * (0.4 + style.orbit * 3);
  final contrast = (0.85 + style.pulse * 1.2 + style.glow * 0.4).clamp(
    0.5,
    2.2,
  );
  final scale = 3.2 + (model.seed % 4) * 0.45;

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

      // Domain warp for marble veins.
      final wx =
          _valueNoise(px * scale + driftX, py * scale + driftY, salt) - 0.5;
      final wy =
          _valueNoise(
            px * scale + 17.1 + driftY,
            py * scale - 9.3 + driftX,
            salt ^ 0x55aa,
          ) -
          0.5;

      final sx = px * scale + driftX + wx * 1.4 * math.cos(warpPhase * 0.5);
      final sy = py * scale + driftY + wy * 1.4 * math.sin(warpPhase * 0.5);

      var v = _valueNoise(sx, sy, salt);
      // Second octave for finer grain.
      v = v * 0.7 + _valueNoise(sx * 2.1, sy * 2.1, salt ^ 0xabc) * 0.3;

      v = ((v - 0.5) * contrast) + 0.5;
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
    strength: 0.9,
  );
}
