import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'avatar_model.dart';
import 'avatar_state.dart';

final class FlowAvatarPainter extends CustomPainter {
  FlowAvatarPainter({
    required this.model,
    required this.animation,
    required this.state,
    required this.intensity,
    required this.edgeDarkness,
    required this.audioAmplitude,
  }) : super(repaint: animation);

  final FlowAvatarModel model;
  final Animation<double> animation;
  final FlowAvatarState state;
  final double intensity;
  final double edgeDarkness;
  final double audioAmplitude;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shortestSide = size.shortestSide;
    final theta = animation.value * math.pi * 2;
    final style = _MotionStyle.forState(state, audioAmplitude);

    canvas.drawRect(rect, Paint()..color = model.background);

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
            style.contraction * (0.5 + 0.5 * math.sin(theta * 2));
        x += (0.5 - x) * contraction;
        y += (0.5 - y) * contraction;
      }

      final pulse =
          1 +
          math.sin(theta * spot.harmonicX + spot.phase) * 0.055 * intensity +
          style.pulse;
      final center = Offset(x * size.width, y * size.height);
      final radius = spot.radius * shortestSide * pulse;
      final color = Color.lerp(spot.color, style.tint, style.tintAmount)!;
      final shader = ui.Gradient.radial(
        center,
        radius,
        [
          color.withValues(alpha: 0.96),
          color.withValues(alpha: 0.78),
          color.withValues(alpha: 0.34),
          color.withValues(alpha: 0),
        ],
        const [0, 0.34, 0.7, 1],
      );
      canvas.drawRect(rect, Paint()..shader = shader);
    }

    final highlightCenter = Offset(
      model.highlightPosition.dx * size.width +
          math.sin(theta) * shortestSide * 0.045,
      model.highlightPosition.dy * size.height +
          math.cos(theta) * shortestSide * 0.032,
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(highlightCenter, shortestSide * 0.58, [
          Colors.white.withValues(alpha: 0.30 + style.glow),
          Colors.transparent,
        ]),
    );

    // A layered vignette rolls the color field into a darker physical edge.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(rect.center.dx, rect.center.dy - shortestSide * 0.04),
          shortestSide * 0.72,
          [
            Colors.transparent,
            Colors.black.withValues(alpha: edgeDarkness * 0.28),
            Colors.black.withValues(alpha: edgeDarkness),
          ],
          const [0.48, 0.76, 1],
        ),
    );

    // A narrow rim keeps the silhouette crisp on white surfaces.
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.radial(
          rect.center,
          shortestSide * 0.70,
          [
            Colors.transparent,
            Colors.black.withValues(alpha: edgeDarkness * 0.55),
          ],
          const [0.88, 1],
        ),
    );
  }

  @override
  bool shouldRepaint(covariant FlowAvatarPainter oldDelegate) {
    return oldDelegate.model.seed != model.seed ||
        oldDelegate.state != state ||
        oldDelegate.intensity != intensity ||
        oldDelegate.edgeDarkness != edgeDarkness ||
        oldDelegate.audioAmplitude != audioAmplitude;
  }
}

final class _MotionStyle {
  const _MotionStyle({
    this.motion = 1,
    this.rotation = 0,
    this.contraction = 0,
    this.pulse = 0,
    this.glow = 0,
    this.tint = Colors.transparent,
    this.tintAmount = 0,
  });

  factory _MotionStyle.forState(FlowAvatarState state, double audioAmplitude) {
    return switch (state) {
      FlowAvatarState.idle => const _MotionStyle(),
      FlowAvatarState.listening => const _MotionStyle(
        motion: 0.7,
        contraction: 0.055,
        glow: 0.03,
      ),
      FlowAvatarState.thinking => const _MotionStyle(
        motion: 1.25,
        rotation: 1,
        glow: 0.04,
      ),
      FlowAvatarState.speaking => _MotionStyle(
        motion: 1.1,
        pulse: audioAmplitude * 0.11,
        glow: audioAmplitude * 0.12,
      ),
      FlowAvatarState.success => const _MotionStyle(
        motion: 0.75,
        pulse: 0.025,
        glow: 0.10,
        tint: Color(0xff54f29a),
        tintAmount: 0.08,
      ),
      FlowAvatarState.error => const _MotionStyle(
        motion: 0.55,
        tint: Color(0xffff4f64),
        tintAmount: 0.14,
      ),
    };
  }

  final double motion;
  final double rotation;
  final double contraction;
  final double pulse;
  final double glow;
  final Color tint;
  final double tintAmount;
}
