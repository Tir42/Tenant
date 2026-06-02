import 'dart:ui';
import 'package:flutter/material.dart';

// --- Neo-Futuristic Antigravity Theme Constants ---

class AntigravityColors {
  static const Color primaryDb = Color(0xFFE5EEF5);      // Soft sky-blue start
  static const Color secondaryDb = Color(0xFFC6DBED);    // Deeper pale sky-blue end
  
  static const Color primaryCard = Color(0xFFFFFFFF);    // Pure White Card Background
  static const Color accentTeal = Color(0xFF007BFF);     // Brand Blue Accent (Clean & cohesive)
  static const Color roleTenant = Color(0xFF007BFF);     // Cool brand blue for Tenant
  static const Color roleLandlord = Color(0xFFFF9100);   // Warm amber/orange for Landlord
  
  static const Color textMain = Color(0xFF2C3E50);       // High contrast dark-slate text
  static const Color textMuted = Color(0xFF7F8C8D);      // Muted silver-grey text

  static const Gradient bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFE5EEF5), // Soft sky-blue start
      Color(0xFFC6DBED), // Deeper pale sky-blue end
    ],
  );
}

// Geometric Sans-Serif Futuristic Text Style
class AntigravityTextStyles {
  static TextStyle headingLarge(Color color) => TextStyle(
    color: color,
    fontSize: 28,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.5,
    fontFamily: 'Montserrat',
  );

  static TextStyle headingMedium(Color color) => TextStyle(
    color: color,
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    fontFamily: 'Montserrat',
  );

  static TextStyle headingSmall(Color color) => TextStyle(
    color: color,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.0,
    fontFamily: 'Montserrat',
  );

  static TextStyle bodyLarge(Color color) => TextStyle(
    color: color,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    fontFamily: 'Montserrat',
  );

  static TextStyle bodyMedium(Color color) => TextStyle(
    color: color,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    fontFamily: 'Montserrat',
  );

  static TextStyle bodySmall(Color color) => TextStyle(
    color: color,
    fontSize: 11,
    fontWeight: FontWeight.w300,
    letterSpacing: 0.1,
    fontFamily: 'Montserrat',
  );
}

// --- Reusable Premium Widget: AntigravityCard ---

class AntigravityCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final Color glowColor;
  final double glowOpacity;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool hasActiveGlow;

  const AntigravityCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.glowColor = AntigravityColors.accentTeal,
    this.glowOpacity = 0.08,
    this.borderRadius = 18.0,
    this.onTap,
    this.hasActiveGlow = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardBody = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AntigravityColors.primaryCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: hasActiveGlow
              ? glowColor.withOpacity(0.35)
              : const Color(0xFFBDC3C7).withOpacity(0.2),
          width: hasActiveGlow ? 1.5 : 1.0,
        ),
        boxShadow: [
          // Subtle elegant soft glow or soft card drop shadow
          BoxShadow(
            color: hasActiveGlow 
                ? glowColor.withOpacity(0.12)
                : const Color(0xFF2C3E50).withOpacity(0.06),
            blurRadius: hasActiveGlow ? 16 : 10,
            spreadRadius: hasActiveGlow ? 1 : 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: cardBody,
        ),
      );
    }
    return cardBody;
  }
}

// --- Reusable Premium Widget: NeonCircularProgress ---

class NeonCircularProgress extends StatelessWidget {
  final double percentage; // 0.0 to 100.0
  final double size;
  final double strokeWidth;
  final Color activeColor;
  final Color inactiveColor;
  final String? centerText;
  final Color textColor;

  const NeonCircularProgress({
    super.key,
    required this.percentage,
    this.size = 50,
    this.strokeWidth = 4.0,
    this.activeColor = AntigravityColors.accentTeal,
    this.inactiveColor = const Color(0x1AFFFFFF),
    this.centerText,
    this.textColor = const Color(0xFF2C3E50),
  });

  @override
  Widget build(BuildContext context) {
    final double boundedPercent = percentage.clamp(0.0, 100.0);
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _NeonProgressPainter(
              percentage: boundedPercent,
              strokeWidth: strokeWidth,
              activeColor: activeColor,
              inactiveColor: inactiveColor,
            ),
          ),
          Text(
            centerText ?? '${boundedPercent.toInt()}%',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: size * 0.24,
              fontFamily: 'Montserrat',
            ),
          ),
        ],
      ),
    );
  }
}

class _NeonProgressPainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color activeColor;
  final Color inactiveColor;

  _NeonProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth * 2) / 2;

    // 1. Draw Inactive Track
    final Paint trackPaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, trackPaint);

    if (percentage <= 0) return;

    // 2. Draw Ambient Neon Shadow Glow (Larger blurred paint)
    final double sweepAngle = 2 * 3.1415926535 * (percentage / 100.0);
    
    final Paint glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 2.0
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          activeColor.withOpacity(0.01),
          activeColor.withOpacity(0.6),
          activeColor,
        ],
        stops: const [0.0, 0.5, 1.0],
        transform: const GradientRotation(-1.5707963), // Start from top (-90 degrees)
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963, // -90 degrees (top)
      sweepAngle,
      false,
      glowPaint,
    );

    // 3. Draw Sharp Active Progress Arc
    final Paint activePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [
          activeColor.withOpacity(0.4),
          activeColor,
        ],
        stops: const [0.0, 1.0],
        transform: const GradientRotation(-1.5707963),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5707963,
      sweepAngle,
      false,
      activePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _NeonProgressPainter oldDelegate) {
    return oldDelegate.percentage != percentage ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor;
  }
}
