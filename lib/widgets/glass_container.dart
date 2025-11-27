// lib/widgets/glass_container.dart
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double blur;
  final double borderRadius;

  const GlassContainer({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.borderRadius = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    // Tema parlaklığına göre cam rengini ve gradient'ı ayarla
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Sizin istediğiniz mor-mavi gradient
    final gradient = LinearGradient(
      colors: [
        Theme.of(context).colorScheme.secondary.withOpacity(isDark ? 0.3 : 0.4), // Mavi
        Theme.of(context).colorScheme.primary.withOpacity(isDark ? 0.2 : 0.3), // Mor
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}