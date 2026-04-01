import 'dart:math' as math;

import 'package:flutter/material.dart';

class AppIslamicBackground extends StatelessWidget {
  const AppIslamicBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return IgnorePointer(
      child: CustomPaint(
        painter: _AppIslamicPatternPainter(isDark: isDark),
        size: Size.infinite,
      ),
    );
  }
}

class AppBarIslamicOrnament extends StatelessWidget {
  const AppBarIslamicOrnament({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        painter: const _AppBarIslamicOrnamentPainter(),
        size: Size.infinite,
      ),
    );
  }
}

class _AppIslamicPatternPainter extends CustomPainter {
  final bool isDark;

  const _AppIslamicPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..color = (isDark ? const Color(0xFFC9A27A) : const Color(0xFFB2875D))
          .withValues(alpha: isDark ? 0.09 : 0.15);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = (isDark ? const Color(0xFFDEC2A4) : const Color(0xFFC9A27A))
          .withValues(alpha: isDark ? 0.08 : 0.12);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = (isDark ? const Color(0xFFF6E8D6) : const Color(0xFF7A5233))
          .withValues(alpha: isDark ? 0.08 : 0.12);

    final spacing = size.width < 700 ? 118.0 : 150.0;

    for (double y = 36; y < size.height + spacing; y += spacing) {
      final rowOffset = ((y / spacing).floor().isEven) ? 0.0 : spacing / 2;
      for (double x = 20 + rowOffset; x < size.width + spacing; x += spacing) {
        final center = Offset(x, y);
        _drawEightPointStar(canvas, center, 20, 9, starPaint);
        canvas.drawCircle(center, 27, ringPaint);
        canvas.drawCircle(center, 1.9, dotPaint);
      }
    }
  }

  void _drawEightPointStar(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 8);
      final radius = i.isEven ? outerRadius : innerRadius;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AppIslamicPatternPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _AppBarIslamicOrnamentPainter extends CustomPainter {
  const _AppBarIslamicOrnamentPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFE8D2BC).withValues(alpha: 0.24);

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFFF5E7D9).withValues(alpha: 0.22);

    final spacing = size.width < 700 ? 74.0 : 88.0;
    final y = size.height * 0.62;

    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      final center = Offset(x + (spacing / 2), y);
      _drawEightPointStar(canvas, center, 13, 6, linePaint);
      canvas.drawCircle(center, 17, linePaint);
      canvas.drawCircle(center, 1.6, dotPaint);
    }

    final borderPath = Path()
      ..moveTo(0, size.height - 1)
      ..lineTo(size.width, size.height - 1);
    canvas.drawPath(
      borderPath,
      Paint()
        ..color = const Color(0xFFF3E4D4).withValues(alpha: 0.28)
        ..strokeWidth = 1,
    );
  }

  void _drawEightPointStar(
    Canvas canvas,
    Offset center,
    double outerRadius,
    double innerRadius,
    Paint paint,
  ) {
    final path = Path();
    for (int i = 0; i < 16; i++) {
      final angle = -math.pi / 2 + (i * math.pi / 8);
      final radius = i.isEven ? outerRadius : innerRadius;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
