import 'package:flutter/material.dart';

/// Gradient theme enum for predefined color schemes
enum GradientTheme {
  green,
  blue,
  purple,
  orange,
  teal,
}

/// An animated gradient background widget
class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;
  final List<Color>? colors;
  final GradientTheme? theme;
  final Duration duration;
  final AlignmentGeometry begin;
  final AlignmentGeometry end;

  const AnimatedGradientBackground({
    super.key,
    required this.child,
    this.colors,
    this.theme,
    this.duration = const Duration(seconds: 3),
    this.begin = Alignment.topLeft,
    this.end = Alignment.bottomRight,
  });
  
  List<Color> get effectiveColors {
    if (colors != null) return colors!;
    switch (theme ?? GradientTheme.green) {
      case GradientTheme.green:
        return GradientThemes.greenTheme;
      case GradientTheme.blue:
        return GradientThemes.blueTheme;
      case GradientTheme.purple:
        return GradientThemes.purpleTheme;
      case GradientTheme.orange:
        return GradientThemes.orangeTheme;
      case GradientTheme.teal:
        return GradientThemes.tealTheme;
    }
  }

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState
    extends State<AnimatedGradientBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = widget.effectiveColors;
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: widget.begin,
              end: widget.end,
              colors: [
                Color.lerp(
                  colors[0],
                  colors[1],
                  _animation.value,
                )!,
                Color.lerp(
                  colors[1],
                  colors[2],
                  _animation.value,
                )!,
                Color.lerp(
                  colors[2],
                  colors[3],
                  _animation.value,
                )!,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Predefined gradient themes
class GradientThemes {
  static const List<Color> greenTheme = [
    Color(0xFF4CAF50),
    Color(0xFF45B649),
    Color(0xFF66BB6A),
    Color(0xFF81C784),
  ];

  static const List<Color> blueTheme = [
    Color(0xFF2196F3),
    Color(0xFF1E88E5),
    Color(0xFF42A5F5),
    Color(0xFF64B5F6),
  ];

  static const List<Color> purpleTheme = [
    Color(0xFF9C27B0),
    Color(0xFF8E24AA),
    Color(0xFFAB47BC),
    Color(0xFFBA68C8),
  ];

  static const List<Color> orangeTheme = [
    Color(0xFFFF9800),
    Color(0xFFFB8C00),
    Color(0xFFFFB74D),
    Color(0xFFFFCC80),
  ];

  static const List<Color> tealTheme = [
    Color(0xFF009688),
    Color(0xFF00897B),
    Color(0xFF26A69A),
    Color(0xFF4DB6AC),
  ];
}
