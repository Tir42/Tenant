import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
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
  final TextEditingController _nameController = TextEditingController();

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
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Color activeRoleColor = selectedRole == 'tenant' 
        ? const Color(0xFF007BFF) 
        : const Color(0xFFFF9100);

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
              constraints: BoxConstraints(
                minHeight: size.height - 100,
              ),
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
                          primaryColor: activeRoleColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'TenantSnap',
                        style: TextStyle(
                          color: Color(0xFF2C3E50), // Clean slate color
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Effortless Home Documentation',
                        style: TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontFamily: 'Montserrat',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),

                  // --- MIDDLE SECTION: GLOWING ROLE SELECTORS ---
                  Column(
                    children: [
                      const Text(
                        'CHOOSE YOUR INTERFACE PERSPECTIVE',
                        style: TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Dropdown Selector Container
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: activeRoleColor.withOpacity(0.08),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: activeRoleColor.withOpacity(0.2),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                        child: DropdownButtonFormField2<String>(
                          isExpanded: true,
                          value: selectedRole,

                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),

                          buttonStyleData: ButtonStyleData(
                            height: 64,
                            padding: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: Colors.transparent,
                            ),
                          ),

                          iconStyleData: IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 30,
                              color: activeRoleColor,
                            ),
                            openMenuIcon: Icon(
                              Icons.keyboard_arrow_up_rounded,
                              size: 30,
                              color: activeRoleColor,
                            ),
                          ),

                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 260,
                            elevation: 12,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              color: Colors.white, // Clean light background
                              border: Border.all(
                                color: activeRoleColor.withOpacity(0.15),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activeRoleColor.withOpacity(0.08),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: WidgetStateProperty.all(4),
                              thumbVisibility: WidgetStateProperty.all(true),
                            ),
                            offset: const Offset(0, -6),
                          ),

                          menuItemStyleData: const MenuItemStyleData(
                            height: 74,
                            padding: EdgeInsets.symmetric(horizontal: 14),
                          ),

                          selectedItemBuilder: (context) {
                            return [
                              _selectedRoleWidget(
                                icon: Icons.vpn_key_outlined,
                                title: "TENANT PERSPECTIVE",
                                color: const Color(0xFF007BFF),
                              ),
                              _selectedRoleWidget(
                                icon: Icons.roofing_outlined,
                                title: "LANDLORD PERSPECTIVE",
                                color: const Color(0xFFFF9100),
                              ),
                            ];
                          },

                          items: [
                            DropdownMenuItem<String>(
                              value: 'tenant',
                              child: _dropdownItemWidget(
                                icon: Icons.vpn_key_outlined,
                                title: "TENANT PERSPECTIVE",
                                subtitle: "Inspect & Log Spatial Data",
                                color: const Color(0xFF007BFF),
                              ),
                            ),
                            DropdownMenuItem<String>(
                              value: 'landlord',
                              child: _dropdownItemWidget(
                                icon: Icons.roofing_outlined,
                                title: "LANDLORD PERSPECTIVE",
                                subtitle: "Verify & Sign Spatial Checklists",
                                color: const Color(0xFFFF9100),
                              ),
                            ),
                          ],

                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedRole = value;
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      // Dynamic Role-Based Name Input Field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: activeRoleColor.withOpacity(0.1),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        child: TextField(
                          controller: _nameController,
                          style: const TextStyle(
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: selectedRole == 'tenant' 
                                ? 'Enter Tenant Name' 
                                : 'Enter Landlord Name',
                            hintStyle: const TextStyle(
                              color: Color(0xFF95A5A6),
                              fontFamily: 'Montserrat',
                              fontSize: 13,
                            ),
                            prefixIcon: Icon(
                              selectedRole == 'tenant' ? Icons.person_outline : Icons.business_outlined,
                              color: activeRoleColor,
                              size: 22,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Explanatory Text Box
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F4F7), // Soft background container
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFBDC3C7).withOpacity(0.2),
                            width: 1.0,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        child: Text(
                          selectedRole == 'tenant'
                              ? 'Gain full tenant utility. Log spatial data, add timestamped photographic evidence directly from the checklist, and generate secure condition reports.'
                              : 'Verify submitted spatial condition checklists. Overlay timeline comparisons, trace photographic logs, and approve lease sign-offs immediately.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF2C3E50),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
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
                          return Container(
                            width: double.infinity,
                            height: 54,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(27),
                              gradient: LinearGradient(
                                colors: [
                                  activeRoleColor.withOpacity(0.85),
                                  activeRoleColor,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: activeRoleColor.withOpacity(0.35 + (_pulseController.value * 0.15)),
                                  blurRadius: 10 + (_pulseController.value * 6),
                                  spreadRadius: 1 + (_pulseController.value * 1.5),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => TenantDashboardScreen(
                                      role: selectedRole,
                                      userName: _nameController.text,
                                    ),
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
                              child: const Text(
                                'Sign In to Workspace',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Register Button (Outlined premium light layout)
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFFBDC3C7).withOpacity(0.5),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: OutlinedButton(
                          onPressed: () {
                            // Mock Registration Info
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Color(0xFF2C3E50),
                                content: Text(
                                  'Initializing Neo-Registration Node...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w600,
                                  ),
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
                          child: const Text(
                            'Request New Registration',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
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


Widget _selectedRoleWidget({
  required IconData icon,
  required String title,
  required Color color,
}) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF2C3E50), // Legible dark slate
              fontFamily: 'Montserrat',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _dropdownItemWidget({
  required IconData icon,
  required String title,
  required String subtitle,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(
              color: color.withOpacity(0.25),
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF2C3E50), // Legible dark slate
                  fontFamily: 'Montserrat',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF7F8C8D), // Legible grey
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}