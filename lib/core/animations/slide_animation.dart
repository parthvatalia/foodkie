import 'package:flutter/material.dart';

enum SlideDirection { fromLeft, fromRight, fromTop, fromBottom }

class SlideAnimation extends StatelessWidget {
  final int position;
  final int itemCount;
  final Widget child;
  final SlideDirection direction;
  final double animationDuration;
  final double delay;

  const SlideAnimation({
    Key? key,
    required this.position,
    required this.itemCount,
    required this.child,
    this.direction = SlideDirection.fromBottom,
    this.animationDuration = 0.5,
    this.delay = 0.2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemDelay = position * delay;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: (animationDuration * 1000).round()),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        final delay = itemDelay < 1.0 ? itemDelay : 1.0;
        final calculatedValue = delay < value ? value : value * delay;

        double offset = (1 - calculatedValue) * 100;
        var translation = Offset(0, 0);

        switch (direction) {
          case SlideDirection.fromLeft:
            translation = Offset(-offset, 0);
            break;
          case SlideDirection.fromRight:
            translation = Offset(offset, 0);
            break;
          case SlideDirection.fromTop:
            translation = Offset(0, -offset);
            break;
          case SlideDirection.fromBottom:
            translation = Offset(0, offset);
            break;
        }

        return Opacity(
          opacity: calculatedValue,
          child: Transform.translate(offset: translation, child: child),
        );
      },
      child: child,
    );
  }
}