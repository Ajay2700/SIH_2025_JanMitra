import 'package:flutter/material.dart';

class AnimationUtils {
  // Standard durations
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);

  // Fade in animation
  static Widget fadeIn({
    required Widget child,
    Duration duration = medium,
    Curve curve = Curves.easeInOut,
    Key? key,
  }) {
    return AnimatedOpacity(
      key: key,
      opacity: 1.0,
      duration: duration,
      curve: curve,
      child: child,
    );
  }

  // Slide in animation from bottom
  static Widget slideInFromBottom({
    required Widget child,
    Duration duration = medium,
    Curve curve = Curves.easeOut,
    double offset = 100.0,
    Key? key,
  }) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween<double>(begin: offset, end: 0.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.translate(offset: Offset(0, value), child: child);
      },
      child: child,
    );
  }

  // Scale animation
  static Widget scale({
    required Widget child,
    Duration duration = medium,
    Curve curve = Curves.easeOut,
    double begin = 0.8,
    double end = 1.0,
    Key? key,
  }) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween<double>(begin: begin, end: end),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Transform.scale(scale: value, child: child);
      },
      child: child,
    );
  }

  // Combined fade and slide animation
  static Widget fadeSlideIn({
    required Widget child,
    Duration duration = medium,
    Curve curve = Curves.easeOut,
    double offset = 50.0,
    Key? key,
  }) {
    return TweenAnimationBuilder<double>(
      key: key,
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * offset),
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  // Staggered list animation
  static List<Widget> staggeredList({
    required List<Widget> children,
    Duration initialDelay = Duration.zero,
    Duration staggerDuration = const Duration(milliseconds: 50),
    Duration animationDuration = medium,
    Curve curve = Curves.easeOut,
    bool fadeIn = true,
    bool slideIn = true,
    double slideOffset = 50.0,
  }) {
    List<Widget> animatedChildren = [];

    for (int i = 0; i < children.length; i++) {
      final delay = initialDelay + (staggerDuration * i);

      Widget animatedChild = children[i];

      if (fadeIn && slideIn) {
        animatedChild = TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: animationDuration,
          curve: curve,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * slideOffset),
                child: child,
              ),
            );
          },
          child: animatedChild,
        );
      } else if (fadeIn) {
        animatedChild = AnimatedOpacity(
          opacity: 1.0,
          duration: animationDuration,
          curve: curve,
          child: animatedChild,
        );
      } else if (slideIn) {
        animatedChild = TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: slideOffset, end: 0.0),
          duration: animationDuration,
          curve: curve,
          builder: (context, value, child) {
            return Transform.translate(offset: Offset(0, value), child: child);
          },
          child: animatedChild,
        );
      }

      // Use FutureBuilder directly without AnimatedBuilder
      animatedChildren.add(
        FutureBuilder(
          future: Future.delayed(delay),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return animatedChild;
            }
            return Opacity(opacity: 0, child: animatedChild);
          },
        ),
      );
    }

    return animatedChildren;
  }
}

// Page route transitions
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  FadePageRoute({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      );
}

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final SlideDirection direction;

  SlidePageRoute({required this.page, this.direction = SlideDirection.right})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          Offset begin;

          switch (direction) {
            case SlideDirection.right:
              begin = const Offset(1.0, 0.0);
              break;
            case SlideDirection.left:
              begin = const Offset(-1.0, 0.0);
              break;
            case SlideDirection.up:
              begin = const Offset(0.0, 1.0);
              break;
            case SlideDirection.down:
              begin = const Offset(0.0, -1.0);
              break;
          }

          return SlideTransition(
            position: Tween<Offset>(begin: begin, end: Offset.zero).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      );
}

enum SlideDirection { right, left, up, down }
