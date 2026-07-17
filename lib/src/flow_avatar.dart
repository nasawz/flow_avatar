import 'package:flutter/material.dart';

import 'avatar_model.dart';
import 'avatar_state.dart';
import 'flow_avatar_painter.dart';

/// A deterministic, animated gradient avatar with no image assets.
///
/// The same [seed] always produces the same palette and composition. Motion is
/// driven by [state], [speed], [intensity], and optional [audioAmplitude].
///
/// Pass [baseColor] (for example `Theme.of(context).colorScheme.primary`) to
/// recolor the palette around an app brand or user-selected theme color while
/// keeping the geometric identity from [seed].
class FlowAvatar extends StatefulWidget {
  /// Creates a flow avatar bound to [seed].
  const FlowAvatar({
    super.key,
    required this.seed,
    this.size = 64,
    this.state = FlowAvatarState.idle,
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

  /// Clipping shape of the rendered avatar.
  final FlowAvatarShape shape;

  /// Overrides the default 24% corner radius for [FlowAvatarShape.roundedSquare].
  final BorderRadius? borderRadius;

  /// When false, freezes the avatar on the first animation frame.
  final bool animated;

  /// Animation speed multiplier. A value of 1 completes a loop in 8 seconds.
  /// Must be greater than zero.
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
  late final AnimationController _controller;
  late FlowAvatarModel _model;

  @override
  void initState() {
    super.initState();
    _model = _buildModel();
    _controller = AnimationController(vsync: this);
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

  void _syncAnimation() {
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (!widget.animated || disableAnimations) {
      _controller.stop();
      _controller.value = 0;
      return;
    }
    final combinedSpeed = widget.speed * flowAvatarStateSpeed(widget.state);
    final duration = Duration(
      milliseconds: (8000 / combinedSpeed).round().clamp(120, 20000),
    );
    if (!_controller.isAnimating || _controller.duration != duration) {
      _controller.duration = duration;
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final painter = FlowAvatarPainter(
      model: _model,
      animation: _controller,
      state: widget.state,
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
