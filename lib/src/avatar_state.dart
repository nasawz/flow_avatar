/// The conversational state represented by the avatar's motion.
enum FlowAvatarState {
  /// Gentle ambient motion when nothing special is happening.
  idle,

  /// Slightly contracted field while waiting for user input.
  listening,

  /// Stronger rotation while the assistant is reasoning.
  thinking,

  /// Audio-reactive pulse while the assistant is speaking.
  speaking,

  /// Soft green tint for a successful outcome.
  success,

  /// Soft red tint for a failed outcome.
  error,
}

/// Built-in loop-speed multiplier for each conversational state.
///
/// Combined with [FlowAvatar.speed]. Thinking is deliberately fast so motion
/// stays obvious at small sizes (e.g. 36–48 logical pixels).
double flowAvatarStateSpeed(FlowAvatarState state) {
  return switch (state) {
    FlowAvatarState.idle => 1,
    FlowAvatarState.listening => 0.7,
    FlowAvatarState.thinking => 2.4,
    FlowAvatarState.speaking => 1.55,
    FlowAvatarState.success => 1.15,
    FlowAvatarState.error => 0.55,
  };
}

/// The clipping shape of a [FlowAvatar].
enum FlowAvatarShape {
  /// Circular clip (default).
  circle,

  /// Rounded rectangle with a 24% corner radius by default.
  roundedSquare,

  /// Hard-edged square with no clipping radius.
  square,
}
