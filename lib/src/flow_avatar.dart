import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'avatar_model.dart';
import 'avatar_pattern.dart';
import 'avatar_state.dart';
import 'flow_avatar_painter.dart';

/// Idle baseline: one full 2π turn every 8 seconds at [FlowAvatar.speed] 1.
const double _kIdleLoopSeconds = 8;

/// Cap frame delta so backgrounding does not fling the phase.
const double _kMaxFrameDeltaSeconds = 0.05;

/// Wrap phase occasionally so float sin/cos stay precise.
const double _kPhaseWrap = math.pi * 2 * 64;

/// A deterministic, animated multi-pattern avatar with no image assets.
///
/// The same [seed] always produces the same palette and composition. Choose a
/// [pattern] (`mesh`, `dither`, `plasma`, `ribbon`, `noise`) for the paint
/// language. Motion is driven by [state], [speed], [intensity], and optional
/// [audioAmplitude].
///
/// Pass [baseColor] (for example `Theme.of(context).colorScheme.primary`) to
/// recolor the palette around an app brand or user-selected theme color while
/// keeping the geometric identity from [seed].
///
/// Motion uses a **continuous phase** clock (`θ += Δt · ω`) rather than a
/// modular 0→1 loop. Multi-frequency fields (fractional rotation, orbit,
/// contraction) are not continuous at a 0→1 wrap, which previously looked like
/// a hard jump every loop.
class FlowAvatar extends StatefulWidget {
  /// Creates a flow avatar bound to [seed].
  const FlowAvatar({
    super.key,
    required this.seed,
    this.size = 64,
    this.state = FlowAvatarState.idle,
    this.pattern = FlowAvatarPattern.mesh,
    this.shape = FlowAvatarShape.circle,
    this.borderRadius,
    this.animated = true,
    this.speed = 1,
    this.intensity = 1,
    this.edgeDarkness = 0.24,
    this.shadow = true,
    this.audioAmplitude = 0,
    this.baseColor,
    this.semanticLabel,
  }) : assert(size > 0),
       assert(speed > 0),
       assert(intensity >= 0 && intensity <= 2),
       assert(edgeDarkness >= 0 && edgeDarkness <= 0.5),
       assert(audioAmplitude >= 0 && audioAmplitude <= 1);

  /// Stable identity such as a user ID or email address.
  final String seed;

  /// Width and height of the avatar in logical pixels.
  final double size;

  /// Conversational motion style applied by the painter.
  final FlowAvatarState state;

  /// Visual paint engine. Default [FlowAvatarPattern.mesh] matches prior releases.
  ///
  /// Same [seed] / [baseColor] palette across patterns; only the render
  /// language changes (`mesh`, `dither`, `plasma`, `ribbon`, `noise`).
  final FlowAvatarPattern pattern;

  /// Clipping shape of the rendered avatar.
  final FlowAvatarShape shape;

  /// Overrides the default 24% corner radius for [FlowAvatarShape.roundedSquare].
  final BorderRadius? borderRadius;

  /// When false, freezes the avatar on a deterministic static pose (phase 0).
  final bool animated;

  /// Animation speed multiplier.
  ///
  /// At `1` with [FlowAvatarState.idle], the field advances at one full turn
  /// per 8 seconds. Must be greater than zero.
  final double speed;

  /// Motion magnitude from 0 (breathing only) to 2.
  final double intensity;

  /// Strength of the dark inner edge, from 0 to 0.5.
  final double edgeDarkness;

  /// Whether to draw theme-aware depth shadows around the avatar.
  final bool shadow;

  /// Current normalized voice level used by [FlowAvatarState.speaking].
  final double audioAmplitude;

  /// Optional brand/theme color that anchors the generated palette.
  ///
  /// When null, hues are derived only from [seed]. When set, the lead color
  /// tracks this value and companion hues stay in a related family.
  final Color? baseColor;

  /// Accessibility label exposed as an image semantic.
  final String? semanticLabel;

  @override
  State<FlowAvatar> createState() => _FlowAvatarState();
}

class _FlowAvatarState extends State<FlowAvatar>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  late final ValueNotifier<double> _phase;
  late FlowAvatarModel _model;

  Duration _lastElapsed = Duration.zero;
  double _phaseRadians = 0;

  @override
  void initState() {
    super.initState();
    _model = _buildModel();
    _phase = ValueNotifier<double>(0);
    _ticker = createTicker(_onTick);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(covariant FlowAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.seed != widget.seed ||
        oldWidget.baseColor != widget.baseColor) {
      _model = _buildModel();
    }
    if (oldWidget.animated != widget.animated ||
        oldWidget.speed != widget.speed ||
        oldWidget.state != widget.state) {
      _syncAnimation();
    }
  }

  FlowAvatarModel _buildModel() {
    return FlowAvatarModel.fromIdentity(
      widget.seed,
      baseColor: widget.baseColor,
    );
  }

  bool get _shouldAnimate {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return widget.animated && !disableAnimations;
  }

  double get _angularSpeedRadPerSec {
    final combined = widget.speed * flowAvatarStateSpeed(widget.state);
    return (math.pi * 2 / _kIdleLoopSeconds) * combined;
  }

  void _onTick(Duration elapsed) {
    if (!_shouldAnimate) {
      return;
    }

    final rawDt =
        (elapsed - _lastElapsed).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastElapsed = elapsed;
    if (rawDt <= 0) {
      return;
    }

    final dt = rawDt.clamp(0.0, _kMaxFrameDeltaSeconds);
    _phaseRadians += dt * _angularSpeedRadPerSec;
    if (_phaseRadians.abs() > _kPhaseWrap) {
      _phaseRadians = _phaseRadians % (math.pi * 2);
    }
    _phase.value = _phaseRadians;
  }

  void _syncAnimation() {
    if (!_shouldAnimate) {
      _ticker.stop();
      _lastElapsed = Duration.zero;
      // Deterministic static pose for lists / reduced motion.
      _phaseRadians = 0;
      _phase.value = 0;
      return;
    }

    if (!_ticker.isActive) {
      _lastElapsed = Duration.zero;
      _ticker.start();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _phase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = FlowAvatarPainter(
      model: _model,
      phase: _phase,
      state: widget.state,
      pattern: widget.pattern,
      intensity: widget.intensity,
      edgeDarkness: widget.edgeDarkness,
      audioAmplitude: widget.audioAmplitude,
    );
    final content = RepaintBoundary(
      child: CustomPaint(size: Size.square(widget.size), painter: painter),
    );

    final clipped = switch (widget.shape) {
      FlowAvatarShape.circle => ClipOval(child: content),
      FlowAvatarShape.roundedSquare => ClipRRect(
        borderRadius:
            widget.borderRadius ?? BorderRadius.circular(widget.size * 0.24),
        child: content,
      ),
      FlowAvatarShape.square => content,
    };

    final brightness = Theme.of(context).brightness;
    final avatar = DecoratedBox(
      decoration: BoxDecoration(
        shape: widget.shape == FlowAvatarShape.circle
            ? BoxShape.circle
            : BoxShape.rectangle,
        borderRadius: widget.shape == FlowAvatarShape.roundedSquare
            ? widget.borderRadius ?? BorderRadius.circular(widget.size * 0.24)
            : null,
        boxShadow: widget.shadow ? _shadowsFor(brightness) : null,
      ),
      child: clipped,
    );

    return Semantics(
      image: true,
      label: widget.semanticLabel,
      child: SizedBox.square(dimension: widget.size, child: avatar),
    );
  }

  List<BoxShadow> _shadowsFor(Brightness brightness) {
    final light = brightness == Brightness.light;
    final tint = widget.baseColor ?? const Color(0xff382d69);
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: light ? 0.24 : 0.34),
        blurRadius: widget.size * (light ? 0.20 : 0.16),
        spreadRadius: -widget.size * 0.035,
        offset: Offset(0, widget.size * 0.085),
      ),
      BoxShadow(
        color: tint.withValues(alpha: light ? 0.16 : 0.24),
        blurRadius: widget.size * 0.10,
        spreadRadius: -widget.size * 0.045,
        offset: Offset(0, widget.size * 0.025),
      ),
    ];
  }
}
