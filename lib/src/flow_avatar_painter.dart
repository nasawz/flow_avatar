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

    // Broad wash so success/error read clearly at tiny FAB/header sizes.
    if (style.washAmount > 0) {
      canvas.drawRect(
        rect,
        Paint()..color = style.tint.withValues(alpha: style.washAmount),
      );
    }

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
      final color = Color.lerp(spot.color, style.tint, style.tintAmount)!;
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
            Colors.white.withValues(
              alpha: (0.28 + style.glow).clamp(0.0, 0.72),
            ),
            Colors.transparent,
          ],
        ),
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
    this.orbit = 0,
    this.pulse = 0,
    this.pulseScale = 1,
    this.glow = 0,
    this.highlightTravel = 1,
    this.highlightSpin = 1,
    this.tint = Colors.transparent,
    this.tintAmount = 0,
    this.washAmount = 0,
  });

  factory _MotionStyle.forState(FlowAvatarState state, double audioAmplitude) {
    final amp = audioAmplitude.clamp(0.0, 1.0);
    // Speaking stays lively even with zero TTS level (text-only chat).
    final syntheticSpeak = 0.45 + amp * 0.55;

    return switch (state) {
      FlowAvatarState.idle => const _MotionStyle(
        motion: 1,
        rotation: 0.18,
        pulseScale: 0.85,
        glow: 0.04,
        highlightTravel: 0.85,
      ),
      FlowAvatarState.listening => const _MotionStyle(
        motion: 0.45,
        rotation: 0.08,
        contraction: 0.22,
        pulseScale: 0.5,
        glow: 0.10,
        highlightTravel: 0.4,
        tint: Color(0xff8ec5ff),
        tintAmount: 0.16,
        washAmount: 0.08,
      ),
      FlowAvatarState.thinking => const _MotionStyle(
        motion: 1.85,
        rotation: 2.6,
        orbit: 0.07,
        pulse: 0.07,
        pulseScale: 1.35,
        glow: 0.20,
        highlightTravel: 1.6,
        highlightSpin: 2.2,
        tint: Color(0xffb48cff),
        tintAmount: 0.22,
        washAmount: 0.10,
      ),
      FlowAvatarState.speaking => _MotionStyle(
        motion: 1.35,
        rotation: 0.55,
        orbit: 0.035,
        pulse: 0.09 + syntheticSpeak * 0.12,
        pulseScale: 1.2,
        glow: 0.18 + syntheticSpeak * 0.16,
        highlightTravel: 1.3,
        highlightSpin: 1.6,
        tint: const Color(0xff5fd0ff),
        tintAmount: 0.18 + amp * 0.12,
        washAmount: 0.10 + amp * 0.06,
      ),
      FlowAvatarState.success => const _MotionStyle(
        motion: 0.95,
        rotation: 0.35,
        pulse: 0.09,
        pulseScale: 1.15,
        glow: 0.28,
        highlightTravel: 1.1,
        tint: Color(0xff3dff9a),
        tintAmount: 0.42,
        washAmount: 0.22,
      ),
      FlowAvatarState.error => const _MotionStyle(
        motion: 0.35,
        rotation: 0.12,
        contraction: 0.12,
        pulse: 0.02,
        pulseScale: 0.7,
        glow: 0.06,
        highlightTravel: 0.35,
        tint: Color(0xffff3b55),
        tintAmount: 0.48,
        washAmount: 0.26,
      ),
    };
  }

  final double motion;
  final double rotation;
  final double contraction;
  final double orbit;
  final double pulse;
  final double pulseScale;
  final double glow;
  final double highlightTravel;
  final double highlightSpin;
  final Color tint;
  final double tintAmount;
  final double washAmount;
}
