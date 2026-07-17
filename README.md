# Flow Avatar

[![pub package](https://img.shields.io/pub/v/flow_avatar.svg)](https://pub.dev/packages/flow_avatar)

Deterministic, animated gradient avatars for Flutter. The identity controls the
palette and composition; time and conversational state control the motion.

No image assets, network calls, WebView, or native platform code are required.

## Features

- Stable visual identity generated from any string seed
- Smooth `CustomPainter` animation without rebuilding layout each frame
- `idle`, `listening`, `thinking`, `speaking`, `success`, and `error` states
- Circle, rounded-square, and square clipping
- TTS/audio-reactive speaking pulse
- Honors the platform's reduced-motion setting
- UTF-16 seed hashing for JavaScript-compatible string iteration semantics

## Install

```yaml
dependencies:
  flow_avatar: ^0.2.0
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

When `baseColor` is set, the palette keeps that color's **hue family** but
lifts lightness into a luminous jelly range (Material primaries are often too
dark to use raw). Spot geometry still comes only from `seed`, so switching
theme colors recolors the avatar without reshaping it.

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

At the default `speed: 1`, one seamless animation loop takes 8 seconds. Use
`speed: 1.5` or `speed: 2` for a more energetic assistant.

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

## Roadmap

The painter implementation is the portable baseline. A future shader renderer
can add liquid UV distortion while keeping the same seed/model API.
