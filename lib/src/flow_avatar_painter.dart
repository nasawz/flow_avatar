import 'package:flutter/material.dart';

import 'avatar_model.dart';
import 'avatar_pattern.dart';
import 'avatar_state.dart';
import 'paint/dither_paint.dart';
import 'paint/mesh_paint.dart';
import 'paint/motion_style.dart';
import 'paint/noise_paint.dart';
import 'paint/plasma_paint.dart';
import 'paint/ribbon_paint.dart';

final class FlowAvatarPainter extends CustomPainter {
  FlowAvatarPainter({
    required this.model,
    required this.phase,
    required this.state,
    required this.pattern,
    required this.intensity,
    required this.edgeDarkness,
    required this.audioAmplitude,
  }) : super(repaint: phase);

  final FlowAvatarModel model;

  /// Continuous phase in radians (not a 0→1 loop fraction).
  final ValueNotifier<double> phase;
  final FlowAvatarState state;
  final FlowAvatarPattern pattern;
  final double intensity;
  final double edgeDarkness;
  final double audioAmplitude;

  @override
  void paint(Canvas canvas, Size size) {
    // θ is already accumulated in radians; do not wrap a modular loop here.
    final theta = phase.value;
    final style = AvatarMotionStyle.forState(state, audioAmplitude);

    switch (pattern) {
      case FlowAvatarPattern.mesh:
        paintFlowAvatarMesh(
          canvas,
          size,
          model: model,
          theta: theta,
          style: style,
          intensity: intensity,
          edgeDarkness: edgeDarkness,
        );
      case FlowAvatarPattern.dither:
        paintFlowAvatarDither(
          canvas,
          size,
          model: model,
          theta: theta,
          style: style,
          intensity: intensity,
          edgeDarkness: edgeDarkness,
        );
      case FlowAvatarPattern.plasma:
        paintFlowAvatarPlasma(
          canvas,
          size,
          model: model,
          theta: theta,
          style: style,
          intensity: intensity,
          edgeDarkness: edgeDarkness,
        );
      case FlowAvatarPattern.ribbon:
        paintFlowAvatarRibbon(
          canvas,
          size,
          model: model,
          theta: theta,
          style: style,
          intensity: intensity,
          edgeDarkness: edgeDarkness,
        );
      case FlowAvatarPattern.noise:
        paintFlowAvatarNoise(
          canvas,
          size,
          model: model,
          theta: theta,
          style: style,
          intensity: intensity,
          edgeDarkness: edgeDarkness,
        );
    }
  }

  @override
  bool shouldRepaint(covariant FlowAvatarPainter oldDelegate) {
    return oldDelegate.model.seed != model.seed ||
        oldDelegate.state != state ||
        oldDelegate.pattern != pattern ||
        oldDelegate.intensity != intensity ||
        oldDelegate.edgeDarkness != edgeDarkness ||
        oldDelegate.audioAmplitude != audioAmplitude;
  }
}
