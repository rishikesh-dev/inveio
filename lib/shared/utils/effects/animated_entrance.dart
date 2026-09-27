import 'package:flutter/material.dart';

/// Extension on [Widget] to add a fade-in and slide-up entrance animation.
extension AnimatedEntranceExtension on Widget {
  /// Wraps this widget with a fade-in and slide-up entrance animation.
  ///
  /// [delay] specifies how long to wait before the animation starts.
  /// [offset] controls the vertical slide distance in pixels.
  Widget toAnimatedEntrance({
    Duration delay = Duration.zero,
    double offset = 18,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delay.inMilliseconds),
      curve: Curves.easeOutCubic,
      child: this,
      builder: (context, value, child) {
        final delayed = delay == Duration.zero
            ? value
            : ((value * (420 + delay.inMilliseconds) - delay.inMilliseconds) /
                      420)
                  .clamp(0.0, 1.0);

        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, (1 - delayed) * offset),
            child: child,
          ),
        );
      },
    );
  }
}
