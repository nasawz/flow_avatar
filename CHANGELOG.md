## 0.3.1

- Fix pub package contents: a minimal `.pubignore` had replaced `.gitignore`
  and accidentally shipped local `build/` artifacts. Republish a clean archive.

## 0.3.0

- Add `FlowAvatarPattern` with five paint engines sharing the same seed palette:
  `mesh` (default), `dither`, `plasma`, `ribbon`, and `noise`.
- Add optional `pattern` on `FlowAvatar` (default `mesh`, fully backward
  compatible).
- Animate ordered dither (Bayer 8×8) by rotating/scrolling the gradient axis —
  reference packages often leave dither static.
- All patterns honor continuous phase motion, conversational state washes, and
  reduced-motion / `animated: false` freezes at phase 0.
- Example gallery: live pattern switcher.

## 0.2.2

- Fix visible jump at the end of each motion cycle: drive the painter with a
  continuous phase (`θ += Δt · ω`) instead of a modular 0→1
  `AnimationController` loop. Non-integer frequencies (rotation, orbit,
  contraction) are discontinuous across a wrap.
- Keep `animated: false` / reduced-motion on a deterministic static pose
  (phase 0). Changing `speed` or `state` no longer resets the phase.

## 0.2.1

- Make conversational states visually distinct: stronger tints/washes, orbit
  and pulse for thinking/speaking, clearer success green and error red.
- Drive loop speed from state (`thinking` ~2.4×, `listening` slower).
- Speaking stays lively without `audioAmplitude` (text-chat friendly).
- Re-sync animation duration when `state` changes.

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
