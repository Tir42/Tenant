import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/features/auth/login/screen/splash_screen.dart';
import 'package:tenantsnap/core/services/rest_client.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize GetX controllers
  Get.put(RestClient());
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
          surface: AntigravityColors.primaryCard,
        ),
        fontFamily: 'Montserrat',
      ),
      home: const SplashScreen(),
    );
  }
}

