import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

void main() {
  runApp(const TenantSnapApp());
}

class TenantSnapApp extends StatelessWidget {
  const TenantSnapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TenantSnap',
      debugShowCheckedModeBanner: false,
      
      // Neo-Futuristic Dark Theme Mapping
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
        dividerTheme: const DividerThemeData(
          color: Color(0x15FFFFFF),
          space: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AntigravityColors.primaryDb,
          contentTextStyle: AntigravityTextStyles.bodyMedium(AntigravityColors.accentTeal),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AntigravityColors.accentTeal.withOpacity(0.3), width: 0.5),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      
      home: const LoginScreen(),
    );
  }
}
