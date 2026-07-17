import 'package:flow_avatar/flow_avatar.dart';
import 'package:flutter/material.dart';

void main() => runApp(const FlowAvatarExample());

class FlowAvatarExample extends StatefulWidget {
  const FlowAvatarExample({super.key});

  @override
  State<FlowAvatarExample> createState() => _FlowAvatarExampleState();
}

class _FlowAvatarExampleState extends State<FlowAvatarExample> {
  bool _darkMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flow Avatar',
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: AvatarGallery(
        darkMode: _darkMode,
        onThemeChanged: (darkMode) => setState(() => _darkMode = darkMode),
      ),
    );
  }

  ThemeData _theme(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xff7567e8),
      brightness: brightness,
    );
    return ThemeData(
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark
          ? const Color(0xff0d0d12)
          : const Color(0xfff8f8fb),
      switchTheme: SwitchThemeData(
        trackOutlineColor: WidgetStatePropertyAll(scheme.outlineVariant),
      ),
    );
  }
}

class AvatarGallery extends StatefulWidget {
  const AvatarGallery({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<AvatarGallery> createState() => _AvatarGalleryState();
}

class _AvatarGalleryState extends State<AvatarGallery> {
  FlowAvatarState _state = FlowAvatarState.idle;
  FlowAvatarShape _shape = FlowAvatarShape.circle;
  double _intensity = 1;
  double _speed = 1;
  double _edgeDarkness = 0.24;
  double _audioAmplitude = 0.55;
  bool _animated = true;
  bool _shadow = true;

  static const identities = [
    'aurora',
    'atlas',
    'lumen',
    'mira',
    'nova',
    'orion',
    'sol',
    'vesper',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 8),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'FLOW AVATAR',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3.2,
                              color: colors.primary,
                            ),
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: widget.darkMode
                              ? 'Switch to light background'
                              : 'Switch to dark background',
                          onPressed: () =>
                              widget.onThemeChanged(!widget.darkMode),
                          icon: Icon(
                            widget.darkMode
                                ? Icons.light_mode_outlined
                                : Icons.dark_mode_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'One identity. Always alive.',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Deterministic color fields with visible, state-aware motion.',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverGrid.builder(
                itemCount: identities.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 160,
                  mainAxisSpacing: 24,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  final identity = identities[index];
                  return Column(
                    children: [
                      FlowAvatar(
                        seed: identity,
                        size: 104,
                        state: _state,
                        shape: _shape,
                        speed: _speed,
                        intensity: _intensity,
                        edgeDarkness: _edgeDarkness,
                        shadow: _shadow,
                        audioAmplitude: _audioAmplitude,
                        animated: _animated,
                        semanticLabel: '$identity avatar',
                      ),
                      const SizedBox(height: 10),
                      Text(
                        identity,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  );
                },
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
              sliver: SliverToBoxAdapter(child: _controls(colors)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _controls(ColorScheme colors) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(24),
        boxShadow: widget.darkMode
            ? null
            : const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Motion lab',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const Text('Animate'),
                const SizedBox(width: 6),
                Switch(
                  value: _animated,
                  onChanged: (value) => setState(() => _animated = value),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: FlowAvatarState.values.map((state) {
                return ChoiceChip(
                  label: Text(state.name),
                  selected: state == _state,
                  onSelected: (_) => setState(() => _state = state),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            SegmentedButton<FlowAvatarShape>(
              segments: FlowAvatarShape.values
                  .map(
                    (shape) =>
                        ButtonSegment(value: shape, label: Text(shape.name)),
                  )
                  .toList(),
              selected: {_shape},
              onSelectionChanged: (value) =>
                  setState(() => _shape = value.first),
            ),
            const SizedBox(height: 18),
            Text('Speed · ${_speed.toStringAsFixed(1)}×'),
            Slider(
              value: _speed,
              min: 0.5,
              max: 2.5,
              divisions: 20,
              label: '${_speed.toStringAsFixed(1)}×',
              onChanged: (value) => setState(() => _speed = value),
            ),
            Text('Motion intensity · ${_intensity.toStringAsFixed(1)}'),
            Slider(
              value: _intensity,
              min: 0,
              max: 2,
              divisions: 20,
              label: _intensity.toStringAsFixed(1),
              onChanged: (value) => setState(() => _intensity = value),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Edge depth · ${_edgeDarkness.toStringAsFixed(2)}',
                  ),
                ),
                const Text('Shadow'),
                const SizedBox(width: 6),
                Switch(
                  value: _shadow,
                  onChanged: (value) => setState(() => _shadow = value),
                ),
              ],
            ),
            Slider(
              value: _edgeDarkness,
              min: 0,
              max: 0.5,
              divisions: 20,
              label: _edgeDarkness.toStringAsFixed(2),
              onChanged: (value) => setState(() => _edgeDarkness = value),
            ),
            if (_state == FlowAvatarState.speaking) ...[
              Text('Audio amplitude · ${_audioAmplitude.toStringAsFixed(2)}'),
              Slider(
                value: _audioAmplitude,
                label: _audioAmplitude.toStringAsFixed(2),
                onChanged: (value) => setState(() => _audioAmplitude = value),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
