import 'package:flutter/material.dart';

/// A simple page route that fades and slightly scales the page when pushed.
class FadeScaleRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  FadeScaleRoute({required this.page})
      : super(
          pageBuilder: (_, __, ___) => page,
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (_, animation, __, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
            return FadeTransition(
              opacity: curved,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.9, end: 1).animate(curved),
                child: child,
              ),
            );
          },
        );
}