import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../avatar_model.dart';
import 'motion_style.dart';
import 'paint_common.dart';

/// Paints the soft radial mesh gradient (original FlowAvatar look).
void paintFlowAvatarMesh(
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

  canvas.drawRect(rect, Paint()..color = model.background);
  paintFlowAvatarWash(canvas, rect, style);

  for (final spot in model.spots) {
    final phase = spot.phase + theta * style.rotation;
    var x =
        spot.position.dx +
        math.sin(theta * spot.harmonicX + phase) *
            spot.amplitude.dx *
            intensity *
            style.motion;
    var y =
        spot.position.dy +
        math.cos(theta * spot.harmonicY + phase) *
            spot.amplitude.dy *
            intensity *
            style.motion;

    if (style.contraction != 0) {
      final contraction =
          style.contraction * (0.5 + 0.5 * math.sin(theta * 2.4));
      x += (0.5 - x) * contraction;
      y += (0.5 - y) * contraction;
    }

    // Thinking gets an extra orbital spin so color blobs clearly rotate.
    if (style.orbit != 0) {
      final orbit = style.orbit * math.sin(theta * 1.5 + spot.phase);
      x += math.cos(theta * 2 + spot.phase) * orbit;
      y += math.sin(theta * 2 + spot.phase) * orbit;
    }

    final pulse =
        1 +
        math.sin(theta * spot.harmonicX + spot.phase) *
            0.08 *
            intensity *
            style.pulseScale +
        style.pulse;
    final center = Offset(x * size.width, y * size.height);
    final radius = spot.radius * shortestSide * pulse;
    final color = flowAvatarTintedColor(spot.color, style);
    final shader = ui.Gradient.radial(
      center,
      radius,
      [
        color.withValues(alpha: 0.98),
        color.withValues(alpha: 0.82),
        color.withValues(alpha: 0.38),
        color.withValues(alpha: 0),
      ],
      const [0, 0.32, 0.68, 1],
    );
    canvas.drawRect(rect, Paint()..shader = shader);
  }

  final highlightTravel = style.highlightTravel;
  final highlightCenter = Offset(
    model.highlightPosition.dx * size.width +
        math.sin(theta * style.highlightSpin) *
            shortestSide *
            0.05 *
            highlightTravel,
    model.highlightPosition.dy * size.height +
        math.cos(theta * style.highlightSpin) *
            shortestSide *
            0.04 *
            highlightTravel,
  );
  canvas.drawRect(
    rect,
    Paint()
      ..shader = ui.Gradient.radial(
        highlightCenter,
        shortestSide * (0.52 + style.glow * 0.35),
        [
          Colors.white.withValues(alpha: (0.28 + style.glow).clamp(0.0, 0.72)),
          Colors.transparent,
        ],
      ),
  );

  paintFlowAvatarVignette(canvas, rect, edgeDarkness: edgeDarkness);
}
