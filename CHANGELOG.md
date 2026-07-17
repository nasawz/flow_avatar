## 0.2.0

- Add optional `baseColor` on `FlowAvatar` / `FlowAvatarModel.fromIdentity` so
  the palette can track an app brand or user-selected theme color.
- Keep geometric identity (spot layout) fixed by `seed` when only `baseColor`
  changes.
- Tint the secondary depth shadow with `baseColor` when provided.
- Lift theme-anchored palettes into a brighter, softer jelly band (hue from
  `baseColor`, raised lightness / softened saturation) so mid-dark Material
  primaries do not make the avatar look muddy.

## 0.1.0

- Add deterministic UTF-16 seed hashing and generated color-field models.
- Add animated `FlowAvatar` with six conversational states.
- Add circle, rounded-square, and square shapes.
- Add audio response, reduced-motion support, example gallery, and tests.
- Tune the default loop to 8 seconds with more visible field movement.
- Add dark/light background switching and speed controls to the gallery.
- Add a configurable dark inner rim and theme-aware double depth shadow.
