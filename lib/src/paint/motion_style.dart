import 'package:flutter/material.dart';

import '../avatar_state.dart';

/// Per-state motion and tint parameters shared by all paint engines.
final class AvatarMotionStyle {
  /// Creates a motion style bundle.
  const AvatarMotionStyle({
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

  /// Builds style constants for a conversational [state].
  factory AvatarMotionStyle.forState(
    FlowAvatarState state,
    double audioAmplitude,
  ) {
    final amp = audioAmplitude.clamp(0.0, 1.0);
    // Speaking stays lively even with zero TTS level (text-only chat).
    final syntheticSpeak = 0.45 + amp * 0.55;

    return switch (state) {
      FlowAvatarState.idle => const AvatarMotionStyle(
        motion: 1,
        rotation: 0.18,
        pulseScale: 0.85,
        glow: 0.04,
        highlightTravel: 0.85,
      ),
      FlowAvatarState.listening => const AvatarMotionStyle(
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
      FlowAvatarState.thinking => const AvatarMotionStyle(
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
      FlowAvatarState.speaking => AvatarMotionStyle(
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
      FlowAvatarState.success => const AvatarMotionStyle(
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
      FlowAvatarState.error => const AvatarMotionStyle(
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

  /// Base motion amplitude multiplier.
  final double motion;

  /// Phase rotation contribution (mesh spots / dither axis).
  final double rotation;

  /// Pull-toward-center strength (listening / error).
  final double contraction;

  /// Extra orbital offset (thinking / speaking).
  final double orbit;

  /// Additive radius / field pulse.
  final double pulse;

  /// Multiplier on oscillatory pulse.
  final double pulseScale;

  /// Soft white highlight strength (mesh).
  final double glow;

  /// How far the highlight travels.
  final double highlightTravel;

  /// Highlight orbit speed multiplier.
  final double highlightSpin;

  /// State tint color blended into field colors.
  final Color tint;

  /// How strongly [tint] mixes into palette samples.
  final double tintAmount;

  /// Full-rect wash alpha for small-size state readability.
  final double washAmount;
}
