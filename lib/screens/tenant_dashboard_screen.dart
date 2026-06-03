import 'package:flutter/material.dart';
import 'package:tenantsnap/screens/theme.dart';

import 'inspection_flow_list_screen.dart';
import 'report_review_screen.dart';

class TenantDashboardScreen extends StatefulWidget {
  final String role; // 'tenant' or 'landlord'
  final String? userName;

  const TenantDashboardScreen({
    super.key,
    this.role = 'tenant',
    this.userName,
  });

  @override
  State<TenantDashboardScreen> createState() => _TenantDashboardScreenState();
}

class _TenantDashboardScreenState extends State<TenantDashboardScreen> {
  // Dummy data state for dashboard metrics
  final int activeInspectionsProgress = 85;
  final int historyReportsProgress = 100;
  final int profileSupportProgress = 95;

  @override
  Widget build(BuildContext context) {
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. PROFILE HEADER ---
                  _buildProfileHeader(context),
                  const SizedBox(height: 24),

                  // --- 2. UPCOMING INSPECTION NOTIFICATION BAR ---
                  _buildUpcomingInspectionNotification(context),
                  const SizedBox(height: 28),

                  // --- GRID TITLE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'WORKSPACE NODE PANELS',
                        style: TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF007BFF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF007BFF).withOpacity(0.3), width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2ECC71), // Clean emerald green
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'SYNCED',
                              style: TextStyle(
                                color: Color(0xFF007BFF),
                                fontFamily: 'Montserrat',
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- 3. 2x2 INTERACTIVE ACTIONS GRID ---
                  _buildActionCardsGrid(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    final bool isTenant = widget.role == 'tenant';
    final Color activeColor = isTenant ? const Color(0xFF007BFF) : const Color(0xFFFF9100);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Avatar + Greeting Info (Expanded to prevent horizontal wiggles)
        Expanded(
          child: Row(
            children: [
              // User Avatar Container
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: activeColor,
                        width: 1.5,
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE5EEF5), Color(0xFFC6DBED)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(0.15),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.userName != null && widget.userName!.isNotEmpty
                            ? widget.userName![0].toUpperCase()
                            : (isTenant ? 'L' : 'V'),
                        style: TextStyle(
                          color: activeColor,
                          fontFamily: 'Montserrat',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  // Glowing Neon Online Indicator Badge
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ECC71), // Clean high contrast green
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2.0,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF2ECC71),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 14),
              // Greetings details (Expanded to scale cleanly with narrow widths)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTenant ? 'WELCOME BACK,' : 'PORTAL ACTIVE,',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.userName != null && widget.userName!.isNotEmpty
                          ? widget.userName!
                          : (isTenant ? 'Liam Carter' : 'Victoria Sterling'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),

        // Glowing Notification Bell
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF2C3E50),
                content: Text(
                  'Loading cosmic notification logs...',
                  style: TextStyle(
                    color: activeColor,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFBDC3C7).withOpacity(0.4),
                    width: 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF2C3E50),
                  size: 24,
                ),
              ),
              // Bell Notification Badge Glow
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: activeColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: activeColor.withOpacity(0.4),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingInspectionNotification(BuildContext context) {
    final bool isTenant = widget.role == 'tenant';
    final Color activeColor = isTenant ? const Color(0xFF007BFF) : const Color(0xFFFF9100);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: activeColor.withOpacity(0.15),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withOpacity(0.06),
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isTenant ? Icons.assignment_late_outlined : Icons.rate_review_outlined,
                  color: activeColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTenant ? 'UPCOMING INSPECTION ALERT' : 'VERIFICATION TELEMETRY REQUEST',
                      style: TextStyle(
                        color: activeColor,
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isTenant ? 'Unit 402 - Urban Loft' : 'Review Request: Unit 402',
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE2E8F0), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTenant ? 'SCHEDULED TIMESTAMP' : 'SUBMITTED BY TENANT',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isTenant ? 'June 5, 2026 • 14:00' : 'Liam Carter • 2 Hours Ago',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFBDC3C7).withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  isTenant ? 'IN 3 DAYS' : 'PENDING REVIEW',
                  style: TextStyle(
                    color: activeColor,
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCardsGrid(BuildContext context) {
    final bool isTenant = widget.role == 'tenant';
    final Color roleColor = isTenant ? const Color(0xFF007BFF) : const Color(0xFFFF9100);

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        // Card 1: Action (Cyan-Glowing for tenant, Landlord role color for landlord)
        _buildDashboardGridItem(
          onTap: () {
            if (isTenant) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InspectionFlowListScreen(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF2C3E50),
                  content: Text(
                    'Opening verification queue for pending tenant submissions...',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }
          },
          hasActiveGlow: true,
          glowColor: roleColor,
          icon: isTenant ? Icons.add_a_photo_outlined : Icons.rate_review_outlined,
          title: isTenant ? 'START NEW' : 'VERIFY CHECKS',
          subtitle: isTenant ? 'Initialize new inspection grid' : '2 pending tenant checklists',
          progressPercent: isTenant ? 0.0 : 100.0,
          progressText: isTenant ? '+' : '2',
        ),

        // Card 2: Active / Managed
        _buildDashboardGridItem(
          onTap: () {
            if (isTenant) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InspectionFlowListScreen(),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Color(0xFF2C3E50),
                  content: Text(
                    'Loading property portfolios and telemetry nodes...',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }
          },
          hasActiveGlow: false,
          glowColor: roleColor,
          icon: isTenant ? Icons.insights_outlined : Icons.domain_outlined,
          title: isTenant ? 'ACTIVE INSPECTIONS' : 'PORTFOLIO',
          subtitle: isTenant ? '1 Pending submission' : '3 Managed active properties',
          progressPercent: isTenant ? activeInspectionsProgress.toDouble() : 100.0,
          progressText: isTenant ? null : '3',
        ),

        // Card 3: History & Reports
        _buildDashboardGridItem(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ReportReviewScreen(
                  roomName: 'Bedroom 1 (Archive)',
                  tenantName: 'Liam Carter',
                  landlordName: 'Victoria Sterling',
                  inspectionDate: 'May 14, 2026',
                ),
              ),
            );
          },
          hasActiveGlow: false,
          glowColor: const Color(0xFF2ECC71), // Green highlight
          icon: Icons.folder_shared_outlined,
          title: isTenant ? 'HISTORY & REPORTS' : 'VERIFIED ARCHIVE',
          subtitle: isTenant ? '4 Saved PDF structures' : '12 Spatial sign-offs',
          progressPercent: historyReportsProgress.toDouble(),
        ),

        // Card 4: Settings / Profile
        _buildDashboardGridItem(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: const Color(0xFF2C3E50),
                content: Text(
                  isTenant 
                      ? 'Connecting telemetry interface to support terminal...' 
                      : 'Loading landlord portal console & preferences...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          },
          hasActiveGlow: false,
          glowColor: const Color(0xFFFF9100), // Amber highlight
          icon: isTenant ? Icons.support_agent_outlined : Icons.settings_outlined,
          title: isTenant ? 'PROFILE & SUPPORT' : 'PORTAL SETTINGS',
          subtitle: isTenant ? 'All security certificates valid' : 'Integration telemetry active',
          progressPercent: profileSupportProgress.toDouble(),
        ),
      ],
    );
  }

  Widget _buildDashboardGridItem({
    required VoidCallback onTap,
    required bool hasActiveGlow,
    required Color glowColor,
    required IconData icon,
    required String title,
    required String subtitle,
    required double progressPercent,
    String? progressText,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: hasActiveGlow ? glowColor.withOpacity(0.35) : const Color(0xFFBDC3C7).withOpacity(0.2),
              width: hasActiveGlow ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: hasActiveGlow 
                    ? glowColor.withOpacity(0.12)
                    : const Color(0xFF2C3E50).withOpacity(0.04),
                blurRadius: hasActiveGlow ? 16 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: glowColor.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: glowColor,
                      size: 22,
                    ),
                  ),
                  NeonCircularProgress(
                    percentage: progressPercent,
                    size: 36,
                    strokeWidth: 2.8,
                    activeColor: glowColor,
                    inactiveColor: const Color(0xFFE2E8F0),
                    centerText: progressText,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
