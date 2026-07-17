# Flow Avatar

[![pub package](https://img.shields.io/pub/v/flow_avatar.svg)](https://pub.dev/packages/flow_avatar)

Deterministic, animated multi-pattern avatars for Flutter. The identity controls
the palette; time, conversational state, and a chosen **pattern** control the
look and motion.

No image assets, network calls, WebView, or native platform code are required.

## Features

- Stable visual identity generated from any string seed
- Five paint patterns: `mesh`, `dither`, `plasma`, `ribbon`, `noise`
- Smooth `CustomPainter` animation without rebuilding layout each frame
- `idle`, `listening`, `thinking`, `speaking`, `success`, and `error` states
- Circle, rounded-square, and square clipping
- TTS/audio-reactive speaking pulse
- Honors the platform's reduced-motion setting
- UTF-16 seed hashing for JavaScript-compatible string iteration semantics

## Install

```yaml
dependencies:
  flow_avatar: ^0.3.0
```

```sh
flutter pub get
```

## Usage

```dart
import 'package:flow_avatar/flow_avatar.dart';

FlowAvatar(
  seed: user.id,
  size: 72,
  pattern: FlowAvatarPattern.mesh, // or dither / plasma / ribbon / noise
  state: FlowAvatarState.thinking,
  speed: 1.0,
  edgeDarkness: 0.24,
  shadow: true,
  shape: FlowAvatarShape.circle,
  intensity: 0.9,
  // Optional: recolor around an app/theme brand color.
  baseColor: Theme.of(context).colorScheme.primary,
  semanticLabel: '${user.name} avatar',
)
```

### Patterns

| Pattern | Look |
|---------|------|
| `mesh` (default) | Soft radial color-field gradient (original) |
| `dither` | Ordered Bayer dither — crisp retro pixels, **animated** bands |
| `plasma` | Multi-sine interference field |
| `ribbon` | Scrolling color ribbons / stripes |
| `noise` | Soft procedural marble / grain drift |

Same `seed` + optional `baseColor` palette across all patterns; only the paint
engine changes.

When `baseColor` is set, the palette keeps that color's **hue family** but
lifts lightness into a luminous jelly range (Material primaries are often too
dark to use raw). Spot geometry (mesh) still comes only from `seed`, so
switching theme colors recolors the avatar without reshaping it.

For a speaking assistant, pass a normalized audio level between 0 and 1:

```dart
FlowAvatar(
  seed: 'assistant',
  state: FlowAvatarState.speaking,
  audioAmplitude: currentAudioLevel,
)
```

Set `animated: false` for lists, notifications, tests, and static previews.
The same seed produces the same static frame on every invocation.

At the default `speed: 1`, idle motion advances at one full turn per **8
seconds**. Each `FlowAvatarState` multiplies angular speed further (e.g.
`thinking` ~2.4×) so busy states stay readable at small sizes. Use
`speed: 1.5` or `speed: 2` for an extra global boost.

Motion uses a **continuous phase** (`θ += Δt · ω`) rather than a modular 0→1
animation loop. Multi-frequency fields are not continuous at a loop wrap, so
a repeating controller previously produced a visible jump once per cycle.

The default inner edge and theme-aware shadow help the avatar retain depth on
light surfaces. Set `edgeDarkness: 0` or `shadow: false` for a flat treatment.

## Run the gallery

```sh
cd example
flutter run
```

## Performance notes

Use animated avatars for the active assistant or a small set of visible items.
For long lists, render `animated: false` and animate only the selected item.
Each avatar includes a `RepaintBoundary`, and animation repaints the canvas
directly rather than rebuilding the widget tree.

Grid patterns (`dither`, `plasma`, `ribbon`, `noise`) cap cell count so large
sizes stay bounded; prefer `mesh` if you need the softest look at very high
frame budgets.

## Roadmap

The painter implementation is the portable baseline. A future shader renderer
can add liquid UV distortion while keeping the same seed/model API.
