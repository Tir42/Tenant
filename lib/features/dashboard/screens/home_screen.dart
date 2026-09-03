import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';
import 'package:tenantsnap/core/utils/pdf/pdf_generator.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';
import 'package:tenantsnap/features/dashboard/controllers/dashboard_controller.dart';
import 'package:tenantsnap/features/property/screens/property_details_screen.dart';
import 'profile_details_screen.dart';
import 'history_screen.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
import 'package:open_filex/open_filex.dart';
import 'package:tenantsnap/core/utils/download_helper/download_helper.dart';
import 'package:tenantsnap/core/services/rest_client.dart';

class HomeScreen extends StatefulWidget {
  final String role;
  final String? userName;

  const HomeScreen({
    super.key,
    this.role = 'tenant',
    this.userName,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dashboardController = Get.put(DashboardController());
  final PageController _carouselController = PageController();
  final PageController _subsController = PageController();
  Timer? _carouselTimer;

  final List<Map<String, String>> _faqs = const [
    {
      'question': 'What is TenantSnap?',
      'answer':
          'TenantSnap helps tenants and landlords document a property’s condition with photos, notes, checklists, and inspection reports.',
    },
    {
      'question': 'How do I start an inspection?',
      'answer':
          'Sign in, choose the property or inspection type, then work through each room’s checklist.',
    },
    {
      'question': 'Can I add photos to an inspection?',
      'answer':
          'Yes. You can take photos or choose existing images to show the condition of rooms and items.',
    },
    {
      'question': 'Can I add comments to photos or rooms?',
      'answer':
          'Yes. Add notes to explain damage, maintenance concerns, or any important details.',
    },
    {
      'question': 'How is the inspection report created?',
      'answer':
          'TenantSnap combines your completed checklist, photos, and comments into a PDF inspection report.',
    },
    {
      'question': 'Can I download or share my report?',
      'answer':
          'Yes. You can download the PDF report and share it by email or another available sharing option on your device.',
    },
    {
      'question': 'Where can I find previous reports?',
      'answer':
          'Open the History or Reports area from the dashboard to view previously saved inspections.',
    },
    {
      'question': 'Can both tenants and landlords use TenantSnap?',
      'answer':
          'Yes. TenantSnap supports both roles, helping each person review and keep a record of property condition.',
    },
    {
      'question': 'What should I include in an inspection?',
      'answer':
          'Record the condition of walls, floors, doors, windows, fixtures, appliances, and any existing damage.',
    },
    {
      'question': 'What should I do if I find damage?',
      'answer':
          'Take clear photos, add a detailed note, and mark the relevant checklist item so it appears in the final report.',
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.userName != null) {
      dashboardController.updateUserName(widget.userName!);
    }
    dashboardController.activeRole.value = widget.role;
    _startCarouselTimer();
  }


  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselController.hasClients) {
        int nextPage = dashboardController.currentCarouselPage.value + 1;
        if (nextPage >= dashboardController.carouselItems.length) {
          nextPage = 0;
        }
        _carouselController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _carouselController.dispose();
    _subsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5EEF5), // Soft sky-blue gradient base
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AntigravityColors.bgGradient,
        ),
        child: SafeArea(
          child: _buildDashboardTab(),
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return Obx(() {
      final String activeRole = dashboardController.activeRole.value;
      final String userName = dashboardController.userName.value;
      final Color activeColor = activeRole == 'tenant' ? const Color(0xFF007BFF) : const Color(0xFF2ECC71);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER: LOGO & ACTION BUTTONS ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left: Logo & App Name
                    Row(
                      children: [
                        Image.asset(
                          'assets/app_icon.png',
                          width: 32.0.w,
                          height: 28.0.h,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 8),
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Montserrat',
                            ),
                            children: [
                              TextSpan(text: 'Tenant'),
                              TextSpan(
                                text: 'Snap',
                                style: TextStyle(
                                  color: Color(0xFF2ECC71),
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    // Right: Settings Cog & Log Out buttons
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Get.to(() => ProfileDetailsScreen(
                              role: activeRole,
                              userName: userName,
                            ));
                          },
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_outline_rounded,
                                color: Color(0xFF2C3E50),
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // --- 2. WELCOME BACK PROFILE CARD ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFF007BFF), 
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF007BFF).withValues(alpha: 0.15),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                userName.isNotEmpty
                                    ? userName.split(' ').map((e) => e[0]).take(2).join().toUpperCase()
                                    : 'LC',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ECC71),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WELCOME BACK',
                              style: TextStyle(
                                color: Color(0xFF7F8C8D),
                                fontFamily: 'Montserrat',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF2C3E50),
                                fontFamily: 'Montserrat',
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 3. PERSPECTIVE TOGGLE PILL ---
                  Container(
                    width: double.infinity,
                    height: 48,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              dashboardController.toggleRole('tenant');
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: activeRole == 'tenant' ? const Color(0xFF007BFF) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Tenant Mode',
                                  style: TextStyle(
                                    color: activeRole == 'tenant' ? Colors.white : const Color(0xFF7F8C8D),
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              dashboardController.toggleRole('landlord');
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                color: activeRole == 'landlord' ? const Color(0xFF2ECC71) : Colors.transparent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  'Landlord Mode',
                                  style: TextStyle(
                                    color: activeRole == 'landlord' ? Colors.white : const Color(0xFF7F8C8D),
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- 4. HIGHLIGHTS AUTO-CAROUSEL ---
                  const Text(
                    'FEATURE HIGHLIGHTS',
                    style: TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: PageView.builder(
                        controller: _carouselController,
                        onPageChanged: (index) {
                          dashboardController.currentCarouselPage.value = index;
                        },
                        itemCount: dashboardController.carouselItems.length,
                        itemBuilder: (context, index) {
                          final item = dashboardController.carouselItems[index];
                          return Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background Image
                              item['image']!.startsWith('http')
                                  ? Image.network(
                                      item['image']!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Color(0xFF6BA4E8), Color(0xFF3B82F6)],
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Image.asset(
                                      item['image']!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [Color(0xFF6BA4E8), Color(0xFF3B82F6)],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              // Dark Gradient Overlay for text readability
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.black.withValues(alpha: 0.15),
                                      Colors.black.withValues(alpha: 0.7),
                                    ],
                                    stops: const [0.2, 1.0],
                                  ),
                                ),
                              ),
                              // Text details
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'FEATURE',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Montserrat',
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['title']!,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Montserrat',
                                        fontSize: 20,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['description']!,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'Montserrat',
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Carousel Indicators
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        dashboardController.carouselItems.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: dashboardController.currentCarouselPage.value == index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dashboardController.currentCarouselPage.value == index ? activeColor : const Color(0xFFBDC3C7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 5. 2x2 GRID ACTIONS ---
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.15,
                    children: [
                       _buildGridActionCard(
                        icon: Icons.play_arrow_rounded,
                        title: 'Start New',
                        subtitle: activeRole == 'tenant' ? 'Launch property flow' : 'Verify property checks',
                        onTap: () {
                          try {
                            Get.find<InspectionController>().clearInspectionData();
                          } catch (_) {}
                          Get.to(() => PropertyDetailsScreen(
                            role: activeRole,
                            userName: userName,
                          ));
                        },
                      ),
                      _buildGridActionCard(
                        icon: Icons.description_outlined,
                        title: 'History & Reports',
                        subtitle: activeRole == 'tenant' ? 'Open PDF reports' : 'View signed report archive',
                        onTap: () {
                          Get.to(() => HistoryScreen(
                            role: activeRole,
                            userName: userName,
                          ));
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // --- 6. SUBSCRIPTION PLANS CAROUSEL ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'SUBSCRIPTION PLANS',
                        style: TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 165,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: PageView.builder(
                      controller: _subsController,
                      onPageChanged: (index) {
                        dashboardController.currentSubsPage.value = index;
                      },
                      itemCount: activeRole == 'tenant' ? dashboardController.tenantPlans.length : dashboardController.landlordPlans.length,
                      itemBuilder: (context, index) {
                        final plan = activeRole == 'tenant'
                            ? dashboardController.tenantPlans[index]
                            : dashboardController.landlordPlans[index];
                        return _buildSubscriptionCard(plan, activeColor);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subscription Carousel Indicators
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        activeRole == 'tenant' ? dashboardController.tenantPlans.length : dashboardController.landlordPlans.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: dashboardController.currentSubsPage.value == index ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dashboardController.currentSubsPage.value == index ? activeColor : const Color(0xFFBDC3C7),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- 7. RECENT SUBMISSIONS SECTION ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Submissions',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Tap to review',
                        style: TextStyle(
                          color: const Color(0xFF7F8C8D).withValues(alpha: 0.8),
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Submissions Card Container
                  Obx(() {
                    if (dashboardController.isLoadingSubmissions.value) {
                      return Container(
                        height: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF007BFF)),
                        ),
                      );
                    }

                    if (dashboardController.recentSubmissions.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: const Center(
                          child: Text(
                            'No recent submissions',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 12,
                              color: Color(0xFF7F8C8D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: List.generate(dashboardController.recentSubmissions.length, (index) {
                          final item = dashboardController.recentSubmissions[index];
                          final String tenantVal = item['tenantName'] ?? '';
                          final String landlordVal = item['landlordName'] ?? '';
                          final String activeRole = dashboardController.activeRole.value;
                          final String title = activeRole.toLowerCase() == 'landlord'
                              ? (landlordVal.isNotEmpty && landlordVal != 'N/A' ? landlordVal : (item['title'] ?? 'Inspection Report'))
                              : (tenantVal.isNotEmpty && tenantVal != 'N/A' ? tenantVal : (item['title'] ?? 'Inspection Report'));
                          final String recordRole = (item['role'] ?? activeRole).toString().toLowerCase() == 'landlord' ? 'Landlord' : 'Tenant';
                          final String dateStr = '${item['date'] ?? ''}  •  $recordRole';
                          final String rawStatus = (item['status'] ?? 'VERIFIED').toString().toUpperCase().trim();
                          
                          Color statusBg = const Color(0xFFEBFBEE);
                          Color statusText = const Color(0xFF2B8A3E);
                          bool isCompleted = true;

                          if (rawStatus == 'PENDING SIGNATURE') {
                            statusBg = const Color(0xFFFFF4E6);
                            statusText = const Color(0xFFFD7E14);
                            isCompleted = false;
                          } else if (rawStatus == 'VERIFIED') {
                            statusBg = const Color(0xFFE6FCF5);
                            statusText = const Color(0xFF0CA678);
                            isCompleted = true;
                          } else {
                            statusBg = const Color(0xFFF1F3F5);
                            statusText = const Color(0xFF495057);
                            isCompleted = true;
                          }

                          return Column(
                            children: [
                              if (index > 0) const Divider(color: Color(0xFFE2E8F0), height: 1),
                              _buildRecentSubmissionItem(
                                context: context,
                                title: title,
                                date: dateStr,
                                status: rawStatus,
                                statusBg: statusBg,
                                statusText: statusText,
                                isCompleted: isCompleted,
                                itemData: item,
                              ),
                            ],
                          );
                        }),
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  _buildFaqSection(activeColor),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildGridActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFEBF5FF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF007BFF),
                  size: 20,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF2C3E50),
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF7F8C8D),
                      fontFamily: 'Montserrat',
                      fontSize: 10,
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

  Future<void> _downloadAndOpenPdf(Map<String, dynamic> item) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF007BFF)),
                SizedBox(height: 16),
                Text(
                  'Downloading report...',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final restClient = Get.find<RestClient>();
      final dioClient = restClient.dio;

      String rawBase = dioClient.options.baseUrl;
      if (rawBase.endsWith('/')) {
        rawBase = rawBase.substring(0, rawBase.length - 1);
      }
      final baseUrl = rawBase.endsWith('/api')
          ? rawBase.substring(0, rawBase.length - 4)
          : rawBase;

      final pdfUrl = item['pdfUrl'] ?? '';
      final String fullUrl;
      if (pdfUrl.startsWith('http://') || pdfUrl.startsWith('https://')) {
        fullUrl = pdfUrl;
      } else {
        fullUrl = '$baseUrl$pdfUrl';
      }

      debugPrint("Downloading PDF from: $fullUrl");

      final downloadDio = Dio();
      final response = await downloadDio.get<List<int>>(
        fullUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final bytes = Uint8List.fromList(response.data!);
      
      // Validate PDF signature magic bytes (%PDF)
      if (bytes.length < 4 || 
          bytes[0] != 0x25 || 
          bytes[1] != 0x50 || 
          bytes[2] != 0x44 || 
          bytes[3] != 0x46) {
        final sampleText = String.fromCharCodes(bytes.take(80));
        debugPrint("Error: Server returned non-PDF content: $sampleText");
        throw Exception("Downloaded content is not a valid PDF file. The file may be missing from the server.");
      }

      final fileName = 'TenantSnap_Report_${item['idCode'] ?? 'Archive'}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savedPath = await DownloadHelper.downloadPdf(
        bytes: bytes,
        fileName: fileName,
      );

      if (!mounted) return;
      Navigator.pop(context); // Pop loading dialog

      if (savedPath != null) {
        final result = await OpenFilex.open(savedPath);
        if (result.type != ResultType.done) {
          throw Exception(result.message);
        }
      } else {
        throw Exception('Could not write PDF to local storage.');
      }
    } catch (e) {
      final String? inspectionJson = item['inspectionData'];
      if (inspectionJson != null && inspectionJson.isNotEmpty) {
        try {
          debugPrint("Download failed. Attempting on-the-fly PDF regeneration...");
          final decoded = jsonDecode(inspectionJson);
          final List<RoomInspection> rooms;
          if (decoded is List) {
            rooms = decoded.map((r) => RoomInspection.fromJson(r as Map<String, dynamic>)).toList();
          } else if (decoded is Map && decoded['rooms'] is List) {
            rooms = (decoded['rooms'] as List).map((r) => RoomInspection.fromJson(r as Map<String, dynamic>)).toList();
          } else {
            throw Exception("Invalid inspection data structure.");
          }

          final String idCode = item['idCode'] ?? '';
          final String tenantName = item['tenantName'] ?? '';
          final String landlordName = item['landlordName'] ?? '';
          final String propertyAddress = item['propertyAddress'] ?? '';
          final String inspectionDate = item['inspectionDate'] ?? '';

          final pdfBytes = await generateInspectionReportPdf(
            idCode: idCode,
            tenantName: tenantName,
            landlordName: landlordName,
            propertyAddress: propertyAddress,
            inspectionDate: inspectionDate,
            inspectionType: 'Possession',
            inspectionPerformedBy: item['role'] ?? 'tenant',
            reportGeneratedOn: item['date'] ?? '',
            rooms: rooms,
            tenantPhone: item['tenantPhone'] ?? '',
            landlordPhone: item['landlordPhone'] ?? '',
            showPhone: true,
            agreementDate: '',
          );

          final fileName = 'TenantSnap_Report_${idCode.isNotEmpty ? idCode : 'Archive'}_${DateTime.now().millisecondsSinceEpoch}.pdf';
          final savedPath = await DownloadHelper.downloadPdf(
            bytes: pdfBytes,
            fileName: fileName,
          );

          if (!mounted) return;
          try {
            Navigator.pop(context);
          } catch (_) {}

          if (savedPath != null) {
            final result = await OpenFilex.open(savedPath);
            if (result.type != ResultType.done) {
              throw Exception(result.message);
            }
            return;
          } else {
            throw Exception('Could not write regenerated PDF to local storage.');
          }
        } catch (fallbackError) {
          debugPrint("PDF regeneration fallback failed: $fallbackError");
        }
      }

      if (!mounted) return;
      try {
        Navigator.pop(context);
      } catch (_) {}
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE74C3C),
          content: Text('Failed to open PDF: $e'),
        ),
      );
    }
  }

  Widget _buildRecentSubmissionItem({
    required BuildContext context,
    required String title,
    required String date,
    required String status,
    required Color statusBg,
    required Color statusText,
    required bool isCompleted,
    required Map<String, dynamic> itemData,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _downloadAndOpenPdf(itemData),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Row(
            children: [
              // Icon Circle (Yellow clock or green check)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isCompleted ? const Color(0xFFEBFBEE) : const Color(0xFFFFF9DB),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    isCompleted ? Icons.check_circle_outline_rounded : Icons.access_time_rounded,
                    color: isCompleted ? const Color(0xFF2B8A3E) : const Color(0xFFFAB005),
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Name and date details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF8F9CA9),
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusText,
                    fontFamily: 'Montserrat',
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getPlanIcon(String name) {
    switch (name) {
      case 'verified_user':
        return Icons.verified_user_rounded;
      case 'cloud_upload':
        return Icons.cloud_upload_rounded;
      case 'star':
        return Icons.star_rounded;
      case 'home':
        return Icons.home_rounded;
      case 'business':
        return Icons.business_center_rounded;
      case 'domain':
        return Icons.domain_rounded;
      default:
        return Icons.bookmark_outline_rounded;
    }
  }

  Widget _buildSubscriptionCard(Map<String, String> plan, Color activeColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      padding: const EdgeInsets.all(18.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon with gradient background
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dashboardController.activeRole.value == 'tenant'
                    ? [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)]
                    : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getPlanIcon(plan['icon']!),
              color: activeColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        plan['title']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF2C3E50),
                          fontFamily: 'Montserrat',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: activeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        plan['price']!,
                        style: TextStyle(
                          color: activeColor,
                          fontFamily: 'Montserrat',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  plan['description']!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7F8C8D),
                    fontFamily: 'Montserrat',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqSection(Color activeColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showFaqBottomSheet(activeColor),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: activeColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontFamily: 'Montserrat',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Tap to view all ${_faqs.length} questions and answers',
                        style: TextStyle(
                          color: const Color(0xFF7F8C8D).withValues(alpha: 0.9),
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_faqs.length} FAQs',
                    style: TextStyle(
                      color: activeColor,
                      fontFamily: 'Montserrat',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showFaqBottomSheet(Color activeColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (bottomSheetContext) {
        return _FaqBottomSheet(
          faqs: _faqs,
          activeColor: activeColor,
        );
      },
    );
  }
}

class _FaqBottomSheet extends StatefulWidget {
  final List<Map<String, String>> faqs;
  final Color activeColor;

  const _FaqBottomSheet({
    required this.faqs,
    required this.activeColor,
  });

  @override
  State<_FaqBottomSheet> createState() => _FaqBottomSheetState();
}

class _FaqBottomSheetState extends State<_FaqBottomSheet> {
  late Set<int> _expandedIndices;

  @override
  void initState() {
    super.initState();
    // By default all questions and answers are visible
    _expandedIndices = List.generate(widget.faqs.length, (i) => i).toSet();
  }

  void _toggleAll() {
    setState(() {
      if (_expandedIndices.length == widget.faqs.length) {
        _expandedIndices.clear();
      } else {
        _expandedIndices = List.generate(widget.faqs.length, (i) => i).toSet();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAllExpanded = _expandedIndices.length == widget.faqs.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag handle
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(height: 16),

          // Header with Title, Count badge, and 'X' close button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.activeColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.help_outline_rounded,
                      color: widget.activeColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontFamily: 'Montserrat',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.faqs.length} Questions & Answers',
                        style: const TextStyle(
                          color: Color(0xFF7F8C8D),
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // 'X' symbol button to close bottom sheet
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Controls row: Title & Expand/Collapse All
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'All Questions (${widget.faqs.length})',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
                TextButton(
                  onPressed: _toggleAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    isAllExpanded ? 'Collapse All' : 'Expand All',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: widget.activeColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Color(0xFFF1F5F9), height: 16, thickness: 1),

          // All Questions and Answers List
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: widget.faqs.length,
              itemBuilder: (context, index) {
                final faq = widget.faqs[index];
                final isExpanded = _expandedIndices.contains(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: isExpanded
                        ? widget.activeColor.withValues(alpha: 0.02)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isExpanded
                          ? widget.activeColor.withValues(alpha: 0.3)
                          : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (isExpanded) {
                            _expandedIndices.remove(index);
                          } else {
                            _expandedIndices.add(index);
                          }
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isExpanded
                                        ? widget.activeColor
                                        : widget.activeColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Q${index + 1}',
                                    style: TextStyle(
                                      color: isExpanded ? Colors.white : widget.activeColor,
                                      fontFamily: 'Montserrat',
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    faq['question'] ?? '',
                                    style: TextStyle(
                                      color: isExpanded ? const Color(0xFF1E293B) : const Color(0xFF2C3E50),
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                AnimatedRotation(
                                  turns: isExpanded ? 0.5 : 0.0,
                                  duration: const Duration(milliseconds: 200),
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isExpanded ? widget.activeColor : const Color(0xFF94A3B8),
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                            if (isExpanded) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFEDF2F7),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  faq['answer'] ?? '',
                                  style: const TextStyle(
                                    color: Color(0xFF475569),
                                    fontFamily: 'Montserrat',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w500,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


