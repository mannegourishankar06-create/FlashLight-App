import 'package:flutter/material.dart';

/// Uses the whole display as a lamp. Tap to change colour, back button to exit.
class ScreenLightScreen extends StatefulWidget {
  const ScreenLightScreen({super.key});

  @override
  State<ScreenLightScreen> createState() => _ScreenLightScreenState();
}

class _ScreenLightScreenState extends State<ScreenLightScreen> {
  static const List<Color> _colors = [
    Colors.white,
    Color(0xFFFFE0B2), // warm
    Colors.redAccent,
    Colors.lightGreenAccent,
    Colors.lightBlueAccent,
  ];

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final color = _colors[_index];
    final fg = ThemeData.estimateBrightnessForColor(color) == Brightness.light
        ? Colors.black54
        : Colors.white70;

    return Scaffold(
      backgroundColor: color,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _index = (_index + 1) % _colors.length),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 8,
                left: 8,
                child: IconButton(
                  icon: Icon(Icons.arrow_back, color: fg),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Center(
                child: Text(
                  'Tap to change colour',
                  style: TextStyle(color: fg, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
