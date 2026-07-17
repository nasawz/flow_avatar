/// Render engine for [FlowAvatar].
///
/// All patterns share the same seed-derived palette identity. Only the paint
/// language changes. Default is [mesh] for backward compatibility.
enum FlowAvatarPattern {
  /// Soft radial mesh gradient (original look).
  mesh,

  /// Ordered Bayer dither of the palette — crisp, retro pixels.
  dither,

  /// Multi-sine interference color field — fluid plasma motion.
  plasma,

  /// Scrolling diagonal / curved color ribbons.
  ribbon,

  /// Soft procedural noise / marble drift.
  noise,
}
