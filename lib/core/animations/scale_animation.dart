import 'package:flutter/material.dart';

class ScaleAnimation extends StatelessWidget {
  final double delay;
  final Widget child;
  final Duration duration;
  final Curve curve;

  const ScaleAnimation({
    Key? key,
    required this.delay,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds: (duration.inMilliseconds * delay).round(),
      ),
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}