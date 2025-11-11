import 'package:flutter/material.dart';

class ModernPageTransitions {
  static PageRouteBuilder<T> fadeTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  static PageRouteBuilder<T> slideUpTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 1.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  static PageRouteBuilder<T> scaleTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 350),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }

  static PageRouteBuilder<T> slideFromRightTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOutCubic;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
      transitionDuration: duration,
    );
  }

  static PageRouteBuilder<T> zoomInTransition<T>({
    required Widget page,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      transitionDuration: duration,
    );
  }
}

// Extension pour faciliter l'utilisation des transitions
extension ModernNavigation on BuildContext {
  Future<T?> pushWithFade<T>(Widget page) {
    return Navigator.push(
      this,
      ModernPageTransitions.fadeTransition(page: page),
    );
  }

  Future<T?> pushWithSlideUp<T>(Widget page) {
    return Navigator.push(
      this,
      ModernPageTransitions.slideUpTransition(page: page),
    );
  }

  Future<T?> pushWithScale<T>(Widget page) {
    return Navigator.push(
      this,
      ModernPageTransitions.scaleTransition(page: page),
    );
  }

  Future<T?> pushWithSlideRight<T>(Widget page) {
    return Navigator.push(
      this,
      ModernPageTransitions.slideFromRightTransition(page: page),
    );
  }

  Future<T?> pushWithZoom<T>(Widget page) {
    return Navigator.push(
      this,
      ModernPageTransitions.zoomInTransition(page: page),
    );
  }
}