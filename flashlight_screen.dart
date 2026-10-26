import 'package:flutter/material.dart';

import '../services/torch_service.dart';
import 'screen_light_screen.dart';

enum LightMode { steady, strobe, sos }

class FlashlightScreen extends StatefulWidget {
  const FlashlightScreen({super.key});

  @override
  State<FlashlightScreen> createState() => _FlashlightScreenState();
}

class _FlashlightScreenState extends State<FlashlightScreen> {
  final TorchService _torch = TorchService();

  LightMode _mode = LightMode.steady;
  bool _active = false; // the user has switched the light on
  bool _lit = false; // the torch is physically lit right now
  bool _available = true;
  double _strobeMs = 200; // half-period of the strobe, in milliseconds

  int _runId = 0; // bumped to cancel any running blink loop

  // SOS in Morse: dot = 1 unit, dash = 3 units, gaps follow Morse timing.
  static const int _unit = 200;
  static const List<int> _sosPattern = [
    // S: . . .
    1, 1, 1, 1, 1, 3,
    // O: - - -
    3, 1, 3, 1, 3, 3,
    // S: . . .
    1, 1, 1, 1, 1, 7,
  ];

  @override
  void initState() {
    super.initState();
    _torch.isAvailable().then((ok) {
      if (mounted) setState(() => _available = ok);
    });
  }

  @override
  void dispose() {
    _runId++;
    _torch.set(false);
    super.dispose();
  }

  Future<void> _setLit(bool on) async {
    final error = await _torch.set(on);
    if (error != null) {
      _runId++;
      if (mounted) {
        setState(() {
          _active = false;
          _lit = false;
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
      }
      return;
    }
    if (mounted) setState(() => _lit = on);
  }

  Future<void> _start() async {
    final id = ++_runId;
    setState(() => _active = true);

    switch (_mode) {
      case LightMode.steady:
        await _setLit(true);
      case LightMode.strobe:
        while (id == _runId) {
          await _setLit(true);
          await Future<void>.delayed(Duration(milliseconds: _strobeMs.round()));
          if (id != _runId) break;
          await _setLit(false);
          await Future<void>.delayed(Duration(milliseconds: _strobeMs.round()));
        }
      case LightMode.sos:
        while (id == _runId) {
          for (var i = 0; i < _sosPattern.length; i++) {
            if (id != _runId) break;
            // Even indexes are "on" periods, odd indexes are gaps.
            await _setLit(i.isEven);
            await Future<void>.delayed(
              Duration(milliseconds: _sosPattern[i] * _unit),
            );
          }
          await _setLit(false);
        }
    }
  }

  Future<void> _stop() async {
    _runId++;
    setState(() => _active = false);
    await _setLit(false);
  }

  Future<void> _toggle() async {
    if (_active) {
      await _stop();
    } else {
      await _start();
    }
  }

  Future<void> _changeMode(LightMode mode) async {
    final wasActive = _active;
    if (wasActive) await _stop();
    setState(() => _mode = mode);
    if (wasActive) await _start();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glow = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashlight'),
        actions: [
          IconButton(
            tooltip: 'Screen light',
            icon: const Icon(Icons.light_mode_outlined),
            onPressed: () async {
              if (_active) await _stop();
              if (!mounted) return;
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScreenLightScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (!_available)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.warning_amber_rounded),
                    title: Text('No flashlight found on this device'),
                    subtitle: Text('Try the screen light in the top right.'),
                  ),
                ),
              const Spacer(),
              GestureDetector(
                onTap: _available ? _toggle : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 120),
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _lit ? glow : theme.colorScheme.surfaceContainerHigh,
                    boxShadow: _lit
                        ? [
                            BoxShadow(
                              color: glow.withAlpha(150),
                              blurRadius: 60,
                              spreadRadius: 16,
                            ),
                          ]
                        : const [],
                  ),
                  child: Icon(
                    Icons.power_settings_new_rounded,
                    size: 84,
                    color: _lit
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                _active ? 'ON' : 'OFF',
                style: theme.textTheme.headlineMedium
                    ?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 4),
              ),
              const Spacer(),
              SegmentedButton<LightMode>(
                segments: const [
                  ButtonSegment(
                    value: LightMode.steady,
                    label: Text('Steady'),
                    icon: Icon(Icons.flashlight_on),
                  ),
                  ButtonSegment(
                    value: LightMode.strobe,
                    label: Text('Strobe'),
                    icon: Icon(Icons.flash_on),
                  ),
                  ButtonSegment(
                    value: LightMode.sos,
                    label: Text('SOS'),
                    icon: Icon(Icons.sos),
                  ),
                ],
                selected: {_mode},
                onSelectionChanged: (s) => _changeMode(s.first),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 72,
                child: _mode == LightMode.strobe
                    ? Column(
                        children: [
                          Text(
                            'Speed: ${(1000 / (_strobeMs * 2)).toStringAsFixed(1)} flashes/sec',
                          ),
                          Slider(
                            // Left = slow (long delay), right = fast (short delay).
                            value: 1050 - _strobeMs,
                            min: 50,
                            max: 1000,
                            onChanged: (v) =>
                                setState(() => _strobeMs = 1050 - v),
                          ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
