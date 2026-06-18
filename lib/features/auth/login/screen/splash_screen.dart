import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/features/auth/login/screen/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;
  double _scale = 0.8;

  @override
  void initState() {
    super.initState();
    // Trigger logo animation shortly after entry
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0;
          _scale = 1.0;
        });
      }
    });

    // Auto-navigate to login screen after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      Get.off(
        () => const LoginScreen(),
        transition: Transition.fade,
        duration: const Duration(milliseconds: 800),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F27),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOutCubic,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutBack,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 280,
                minWidth: 200,
              ),
              child: Image.asset(
                'assets/splash.png',
                width: MediaQuery.of(context).size.width * 0.7,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

