import 'package:flutter/material.dart';
import '../theme.dart';
import 'inspection_flow_list_screen.dart';

class TenantDashboardScreen extends StatefulWidget {
  const TenantDashboardScreen({super.key});

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
                      Text(
                        'WORKSPACE NODE PANELS',
                        style: AntigravityTextStyles.headingSmall(AntigravityColors.textMuted).copyWith(
                          fontSize: 11,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AntigravityColors.accentTeal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AntigravityColors.accentTeal.withOpacity(0.3), width: 0.5),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF00FF66),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'SYNCED',
                              style: AntigravityTextStyles.bodySmall(AntigravityColors.accentTeal).copyWith(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Liam's Avatar + Greeting Info
        Row(
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
                      color: AntigravityColors.accentTeal,
                      width: 1.5,
                    ),
                    gradient: const RadialGradient(
                      colors: [Color(0xFF1B072B), Color(0xFF0D122C)],
                      radius: 0.85,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AntigravityColors.accentTeal.withOpacity(0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'L',
                      style: AntigravityTextStyles.headingMedium(AntigravityColors.accentTeal).copyWith(
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
                    color: const Color(0xFF00FF66),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AntigravityColors.primaryDb,
                      width: 2.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0xFF00FF66),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Greetings details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WELCOME BACK,',
                  style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted).copyWith(
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Liam Carter',
                  style: AntigravityTextStyles.headingMedium(AntigravityColors.textMain).copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Glowing Notification Bell
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AntigravityColors.primaryDb,
                content: Text(
                  'Loading cosmic notification logs...',
                  style: AntigravityTextStyles.bodyMedium(AntigravityColors.accentTeal),
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
                  color: Colors.white.withOpacity(0.04),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AntigravityColors.textMuted.withOpacity(0.2),
                    width: 1.0,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_none_outlined,
                  color: AntigravityColors.textMain,
                  size: 24,
                ),
              ),
              // Bell Notification Badge Glow
              Container(
                padding: const EdgeInsets.all(5),
                decoration: const BoxDecoration(
                  color: AntigravityColors.accentTeal,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AntigravityColors.accentTeal,
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Text(
                  '2',
                  style: TextStyle(
                    color: Colors.black,
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
    return AntigravityCard(
      glowColor: AntigravityColors.accentTeal,
      glowOpacity: 0.2,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AntigravityColors.accentTeal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.assignment_late_outlined,
                  color: AntigravityColors.accentTeal,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UPCOMING INSPECTION ALERT',
                      style: AntigravityTextStyles.headingSmall(AntigravityColors.accentTeal).copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Unit 402 - Urban Loft',
                      style: AntigravityTextStyles.bodyMedium(AntigravityColors.textMain).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0x1EFFFFFF), height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SCHEDULED TIMESTAMP',
                    style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'June 5, 2026 • 14:00',
                    style: AntigravityTextStyles.bodyLarge(AntigravityColors.textMain).copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              // Neon Status countdown badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AntigravityColors.textMuted.withOpacity(0.2),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'IN 3 DAYS',
                  style: AntigravityTextStyles.bodySmall(AntigravityColors.accentTeal).copyWith(
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
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: [
        // Card 1: Start New (Active Cyan-Glowing Interactive Card)
        AntigravityCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const InspectionFlowListScreen(),
              ),
            );
          },
          hasActiveGlow: true,
          glowColor: AntigravityColors.accentTeal,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AntigravityColors.accentTeal.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      color: AntigravityColors.accentTeal,
                      size: 24,
                    ),
                  ),
                  const NeonCircularProgress(
                    percentage: 0.0,
                    size: 32,
                    strokeWidth: 2.5,
                    centerText: '+',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'START NEW',
                    style: AntigravityTextStyles.headingSmall(AntigravityColors.textMain).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Initialize new inspection grid',
                    style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Card 2: Active Inspections (Progress: 85%)
        AntigravityCard(
          onTap: () {
            // Tapping this goes straight to the room checklist flow!
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const InspectionFlowListScreen(),
              ),
            );
          },
          glowColor: AntigravityColors.roleTenant,
          glowOpacity: 0.12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AntigravityColors.roleTenant.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.insights_outlined,
                      color: AntigravityColors.roleTenant,
                      size: 24,
                    ),
                  ),
                  NeonCircularProgress(
                    percentage: activeInspectionsProgress.toDouble(),
                    size: 38,
                    strokeWidth: 3.0,
                    activeColor: AntigravityColors.roleTenant,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACTIVE INSPECTIONS',
                    style: AntigravityTextStyles.headingSmall(AntigravityColors.textMain).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '1 Pending submission',
                    style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Card 3: History & Reports (Progress: 100%)
        AntigravityCard(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AntigravityColors.primaryDb,
                content: Text(
                  'Retrieving compiled spatial report nodes...',
                  style: AntigravityTextStyles.bodyMedium(AntigravityColors.accentTeal),
                ),
              ),
            );
          },
          glowColor: const Color(0xFF00FF66), // Green glow for complete
          glowOpacity: 0.12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF66).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.folder_shared_outlined,
                      color: Color(0xFF00FF66),
                      size: 24,
                    ),
                  ),
                  NeonCircularProgress(
                    percentage: historyReportsProgress.toDouble(),
                    size: 38,
                    strokeWidth: 3.0,
                    activeColor: const Color(0xFF00FF66),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HISTORY & REPORTS',
                    style: AntigravityTextStyles.headingSmall(AntigravityColors.textMain).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '4 Saved PDF structures',
                    style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Card 4: Profile & Support (Progress: 95%)
        AntigravityCard(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: AntigravityColors.primaryDb,
                content: Text(
                  'Connecting telemetry interface to support terminal...',
                  style: AntigravityTextStyles.bodyMedium(AntigravityColors.accentTeal),
                ),
              ),
            );
          },
          glowColor: AntigravityColors.roleLandlord,
          glowOpacity: 0.12,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AntigravityColors.roleLandlord.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.support_agent_outlined,
                      color: AntigravityColors.roleLandlord,
                      size: 24,
                    ),
                  ),
                  NeonCircularProgress(
                    percentage: profileSupportProgress.toDouble(),
                    size: 38,
                    strokeWidth: 3.0,
                    activeColor: AntigravityColors.roleLandlord,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROFILE & SUPPORT',
                    style: AntigravityTextStyles.headingSmall(AntigravityColors.textMain).copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'All security certificates valid',
                    style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
