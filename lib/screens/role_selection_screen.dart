import 'package:flutter/material.dart';
import '../theme.dart';
import 'tenant_dashboard_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> with SingleTickerProviderStateMixin {
  String selectedRole = 'tenant'; // 'tenant' or 'landlord'
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AntigravityColors.bgGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              height: size.height - 80,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // --- TOP SECTION: NEON LOGO & HEADER ---
                  Column(
                    children: [
                      const SizedBox(height: 20),
                      // Custom Vector Neo-Futuristic Logo
                      CustomPaint(
                        size: const Size(90, 80),
                        painter: LogoPainter(
                          primaryColor: selectedRole == 'tenant' 
                              ? AntigravityColors.roleTenant 
                              : AntigravityColors.roleLandlord,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'TenantSnap',
                        style: AntigravityTextStyles.headingLarge(AntigravityColors.textMain),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Effortless Home Documentation',
                        style: AntigravityTextStyles.bodyMedium(AntigravityColors.textMuted).copyWith(
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  // --- MIDDLE SECTION: GLOWING ROLE SELECTORS ---
                  Column(
                    children: [
                      Text(
                        'CHOOSE YOUR INTERFACE PERSPECTIVE',
                        style: AntigravityTextStyles.headingSmall(AntigravityColors.textMuted).copyWith(
                          fontSize: 12,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tenant Sphere Button
                          _buildRoleButton(
                            role: 'tenant',
                            title: 'TENANT',
                            subtitle: 'Inspect & Log',
                            glowColor: AntigravityColors.roleTenant,
                            icon: Icons.vpn_key_outlined,
                            gradientColors: [const Color(0xFF005C8A), AntigravityColors.roleTenant],
                          ),
                          const SizedBox(width: 32),
                          // Landlord Sphere Button
                          _buildRoleButton(
                            role: 'landlord',
                            title: 'LANDLORD',
                            subtitle: 'Verify & Sign',
                            glowColor: AntigravityColors.roleLandlord,
                            icon: Icons.roofing_outlined,
                            gradientColors: [const Color(0xFF8A3000), AntigravityColors.roleLandlord],
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Explanatory Text Box
                      AntigravityCard(
                        glowColor: selectedRole == 'tenant' 
                            ? AntigravityColors.roleTenant 
                            : AntigravityColors.roleLandlord,
                        glowOpacity: 0.15,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          selectedRole == 'tenant'
                              ? 'Gain full tenant utility. Log spatial data, add timestamped photographic evidence directly from the checklist, and generate secure condition reports.'
                              : 'Verify submitted spatial condition checklists. Overlay timeline comparisons, trace photographic logs, and approve lease sign-offs immediately.',
                          textAlign: TextAlign.center,
                          style: AntigravityTextStyles.bodyMedium(AntigravityColors.textMain).copyWith(
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // --- BOTTOM SECTION: ACTIONS ---
                  Column(
                    children: [
                      // Sign In Button
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final Color activeColor = selectedRole == 'tenant'
                              ? AntigravityColors.roleTenant
                              : AntigravityColors.roleLandlord;
                          
                          return Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(27),
                              gradient: LinearGradient(
                                colors: [
                                  activeColor.withOpacity(0.8),
                                  activeColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withOpacity(0.4 + (_pulseController.value * 0.2)),
                                  blurRadius: 12 + (_pulseController.value * 8),
                                  spreadRadius: 1 + (_pulseController.value * 2),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const TenantDashboardScreen(),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(27),
                                ),
                              ),
                              child: Text(
                                'Sign In to Workspace',
                                style: AntigravityTextStyles.headingSmall(AntigravityColors.primaryDb).copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Register Button (Outlined glassmorphic style)
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white.withOpacity(0.04),
                          border: Border.all(
                            color: AntigravityColors.textMuted.withOpacity(0.3),
                            width: 1.0,
                          ),
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            // Mock Registration Info
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AntigravityColors.primaryDb,
                                content: Text(
                                  'Initializing Neo-Registration Node...',
                                  style: AntigravityTextStyles.bodyMedium(AntigravityColors.accentTeal),
                                ),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Request New Registration',
                            style: AntigravityTextStyles.bodyLarge(AntigravityColors.textMain).copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String role,
    required String title,
    required String subtitle,
    required Color glowColor,
    required IconData icon,
    required List<Color> gradientColors,
  }) {
    final bool isSelected = selectedRole == role;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRole = role;
        });
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isSelected
                    ? [gradientColors[1].withOpacity(0.8), gradientColors[0]]
                    : [gradientColors[1].withOpacity(0.2), Colors.black.withOpacity(0.6)],
                center: const Alignment(-0.3, -0.3),
                radius: 0.85,
              ),
              border: Border.all(
                color: isSelected ? glowColor : glowColor.withOpacity(0.3),
                width: isSelected ? 2.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: isSelected ? glowColor.withOpacity(0.5) : glowColor.withOpacity(0.1),
                  blurRadius: isSelected ? 24 : 8,
                  spreadRadius: isSelected ? 3 : -2,
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 40,
              color: isSelected ? AntigravityColors.textMain : AntigravityColors.textMuted,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AntigravityTextStyles.headingSmall(
              isSelected ? AntigravityColors.textMain : AntigravityColors.textMuted,
            ).copyWith(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for a glorious neon vector logo (a house intersecting with a lens/aperture)
class LogoPainter extends CustomPainter {
  final Color primaryColor;

  LogoPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    // Draw neon outer glow layer
    final Paint glowPaint = Paint()
      ..color = primaryColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0);

    // Draw sharp neon outline layer
    final Paint sharpPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;



    // Build the house structure outline path
    final Path housePath = Path()
      ..moveTo(w * 0.1, h * 0.55)
      ..lineTo(w * 0.1, h * 0.9)
      ..lineTo(w * 0.9, h * 0.9)
      ..lineTo(w * 0.9, h * 0.55)
      ..moveTo(w * 0.05, h * 0.55)
      ..lineTo(w * 0.5, h * 0.15)
      ..lineTo(w * 0.95, h * 0.55);

    // Draw house outline
    canvas.drawPath(housePath, glowPaint);
    canvas.drawPath(housePath, sharpPaint);

    // Draw the green checklist hook (representing snap)
    final Path checkPath = Path()
      ..moveTo(w * 0.72, h * 0.2)
      ..lineTo(w * 0.8, h * 0.28)
      ..lineTo(w * 0.95, h * 0.1);
    
    final Paint checkPaint = Paint()
      ..color = const Color(0xFF00FF66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(checkPath, checkPaint);

    // Draw the inner circular camera lens representing the 'Snap' aspect
    final center = Offset(w * 0.5, h * 0.65);
    final radius = w * 0.18;

    canvas.drawCircle(center, radius, glowPaint);
    canvas.drawCircle(center, radius, sharpPaint);
    canvas.drawCircle(center, w * 0.07, Paint()..color = AntigravityColors.accentTeal);
    canvas.drawCircle(center + const Offset(4, -4), w * 0.02, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant LogoPainter oldDelegate) {
    return oldDelegate.primaryColor != primaryColor;
  }
}
