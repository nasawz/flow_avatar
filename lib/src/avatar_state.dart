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

/// The clipping shape of a [FlowAvatar].
enum FlowAvatarShape {
  /// Circular clip (default).
  circle,

  /// Rounded rectangle with a 24% corner radius by default.
  roundedSquare,

  /// Hard-edged square with no clipping radius.
  square,
}
