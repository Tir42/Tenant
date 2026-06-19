import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';
import 'package:tenantsnap/features/auth/login/screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Background aurora controllers
  late final AnimationController _auroraController;
  late final Animation<double> _blob1AnimX;
  late final Animation<double> _blob1AnimY;
  late final Animation<double> _blob2AnimX;
  late final Animation<double> _blob2AnimY;

  // Main loading progress & logo animations
  late final AnimationController _progressController;
  late final Animation<double> _progressAnimation;

  
  // Float animation for logo bobbing
  late final AnimationController _floatController;
  late final Animation<double> _logoFloatAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Slow, organic background blob drift
    _auroraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);

    _blob1AnimX = Tween<double>(begin: -150, end: -50).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOutQuad),
    );
    _blob1AnimY = Tween<double>(begin: -150, end: -80).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOutSine),
    );
    _blob2AnimX = Tween<double>(begin: -120, end: -40).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOutSine),
    );
    _blob2AnimY = Tween<double>(begin: -120, end: -60).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOutQuad),
    );

    // 2. Progress and logo controllers
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOutCubic),
    );

    // Subtle breathing float animation for logo
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _logoFloatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // Start progress
    _progressController.forward();

    // Trigger navigation after loading finishes + small visual pause
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Get.off(
              () => const LoginScreen(),
              transition: Transition.fade,
              duration: const Duration(milliseconds: 800),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _auroraController.dispose();
    _progressController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  String _getLoadingText(double progress) {
    if (progress < 0.25) {
      return 'SYSTEM_BOOT_INITIALIZING...';
    } else if (progress < 0.50) {
      return 'ESTABLISHING_SECURE_GATEWAY...';
    } else if (progress < 0.75) {
      return 'DECRYPTING_TENANT_PROFILE...';
    } else if (progress < 0.95) {
      return 'LOADING_ASSETS_AND_RESOURCES...';
    } else {
      return 'READY_REDIRECTING...';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Deep dynamic background (Antigravity gradient)
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: AntigravityColors.bgGradient,
            ),
          ),
          
          // Floating Violet Blob (Top-left)
          AnimatedBuilder(
            animation: _auroraController,
            builder: (context, child) {
              return Positioned(
                top: _blob1AnimY.value,
                left: _blob1AnimX.value,
                child: Container(
                  width: 350,
                  height: 350,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  ),
                ),
              );
            },
          ),
          
          // Floating Blue-Teal Blob (Bottom-right)
          AnimatedBuilder(
            animation: _auroraController,
            builder: (context, child) {
              return Positioned(
                bottom: _blob2AnimY.value,
                right: _blob2AnimX.value,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF06B6D4).withValues(alpha: 0.12),
                  ),
                ),
              );
            },
          ),
          
          // Gaussian Blur Overlay for Liquid Glass effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          // 2. Main Content
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),
                    
                    // Logo Container with floating & scaling logo image
                    AnimatedBuilder(
                      animation: Listenable.merge([_progressController, _logoFloatAnimation]),
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _logoFloatAnimation.value),
                          child: Transform.scale(
                            scale: _progressAnimation.value,
                            child: Image.asset(
                              'assets/app_icon.png',
                              width: 90.0.w,
                              height: 80.0.h,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 28),
                    
                    // Shimmering Brand Title
                    const GradientShimmerText(
                      text: 'TenantSnap',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Tagline
                    const Text(
                      'Effortless Home Documentation',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Loading Logs & Progress Bar at bottom
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        final progressVal = _progressAnimation.value;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Micro log updates
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _getLoadingText(progressVal),
                                  style: const TextStyle(
                                    color: Color(0xFF7F8C8D),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                                Text(
                                  '${(progressVal * 100).toInt()}%',
                                  style: const TextStyle(
                                    color: Color(0xFF007BFF),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Progress track
                            Container(
                              width: double.infinity,
                              height: 5,
                              decoration: BoxDecoration(
                                color: const Color(0xFFBDC3C7).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(2.5),
                              ),
                              child: Stack(
                                children: [
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: progressVal,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF007BFF),
                                            Color(0xFF2ECC71),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF007BFF).withValues(alpha: 0.4),
                                            blurRadius: 6,
                                            offset: const Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// Sliding sweep gradient shimmer text
class GradientShimmerText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const GradientShimmerText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<GradientShimmerText> createState() => _GradientShimmerTextState();
}

class _GradientShimmerTextState extends State<GradientShimmerText> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: const [
                Color(0xFF2C3E50), // Main dark slate
                Color(0xFF2ECC71), // Brand Green
                Color(0xFF007BFF), // Brand Blue
                Color(0xFF2C3E50), // Main dark slate
              ],
              stops: const [0.15, 0.45, 0.55, 0.85],
              transform: GradientRotation(_shimmerController.value * 2 * 3.14159),
            ).createShader(bounds);
          },
          child: Text(
            widget.text,
            style: widget.style.copyWith(color: Colors.white),
          ),
        );
      },
    );
  }
}
