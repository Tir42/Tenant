import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart'; // <-- Import package
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/features/auth/screens/login_screen.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';

void main() {
  // 1. Initialize WidgetsBinding
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Preserve native splash screen
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize GetX controller
  Get.put(InspectionController());

  runApp(const TenantSnapApp());
}

class TenantSnapApp extends StatefulWidget {
  const TenantSnapApp({super.key});

  @override
  State<TenantSnapApp> createState() => _TenantSnapAppState();
}

class _TenantSnapAppState extends State<TenantSnapApp> {
  @override
  void initState() {
    super.initState();
    _initialization();
  }

  void _initialization() async {
    // 3. Keep splash screen for 2 seconds (or load your settings/APIs here)
    await Future.delayed(const Duration(seconds: 2));
    
    // 4. Remove splash screen and transition to LoginScreen
    FlutterNativeSplash.remove();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TenantSnap',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AntigravityColors.primaryDb,
        primaryColor: AntigravityColors.accentTeal,
        colorScheme: const ColorScheme.dark(
          primary: AntigravityColors.accentTeal,
          secondary: AntigravityColors.accentTeal,
          background: AntigravityColors.primaryDb,
          surface: AntigravityColors.primaryCard,
        ),
        fontFamily: 'Montserrat',
      ),
      home: const LoginScreen(),
    );
  }
}
