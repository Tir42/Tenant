import 'dart:ui';
import 'package:flutter/material.dart';

// --- Neo-Futuristic Antigravity Theme Constants ---

class AntigravityColors {
  static const Color primaryDb = Color(0xFF090B19);      // Deep Cosmic Blue (BG Darkest)
  static const Color secondaryDb = Color(0xFF1B072B);    // Deep Cosmic Purple (BG Lightest)
  
  static const Color primaryCard = Color(0x3B0D122C);    // Transparent Glass Cosmic Blue
  static const Color accentTeal = Color(0xFF00F2FE);     // Electric Teal Accent
  static const Color roleTenant = Color(0xFF00F0FF);     // Cyan for Tenant
  static const Color roleLandlord = Color(0xFFFF9100);   // Amber/Orange for Landlord
  
  static const Color textMain = Color(0xFFF0F4FF);       // Crisp Cosmic White Text
  static const Color textMuted = Color(0xFF8A99AD);      // Cosmic Dust Muted Silver-Grey

  // Premium Background Cosmic Gradient
  static const Gradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A0C1A),
      Color(0xFF0F1126),
      Color(0xFF1B0C30),
    ],
    stops: [0.0, 0.5, 1.0],
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
    shadows: [
      Shadow(
        color: AntigravityColors.accentTeal.withOpacity(0.4),
        blurRadius: 10,
      ),
    ],
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
    this.glowOpacity = 0.25,
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
              ? glowColor
              : glowColor.withOpacity(0.20),
          width: hasActiveGlow ? 1.5 : 1.0,
        ),
        boxShadow: [
          // Subtle neon ambient glow
          BoxShadow(
            color: glowColor.withOpacity(hasActiveGlow ? glowOpacity * 1.8 : glowOpacity),
            blurRadius: hasActiveGlow ? 16 : 8,
            spreadRadius: hasActiveGlow ? 2 : -2,
            offset: const Offset(0, 0),
          ),
          // Deep drop shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
          child: Padding(
            padding: padding ?? const EdgeInsets.all(16.0),
            child: child,
          ),
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

  const NeonCircularProgress({
    super.key,
    required this.percentage,
    this.size = 50,
    this.strokeWidth = 4.0,
    this.activeColor = AntigravityColors.accentTeal,
    this.inactiveColor = const Color(0x1AFFFFFF),
    this.centerText,
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
            style: AntigravityTextStyles.bodyMedium(AntigravityColors.textMain).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: size * 0.24,
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
