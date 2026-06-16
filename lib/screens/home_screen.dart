import 'package:flutter/material.dart';
import 'dart:async';
import 'property_details_screen.dart';
import 'report_review_screen.dart';
import 'login_screen.dart';

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
  String _activeRole = 'tenant';
  String _userName = 'Liam Carter';
  final PageController _carouselController = PageController();
  int _currentCarouselPage = 0;
  Timer? _carouselTimer;

  final List<Map<String, String>> _carouselItems = [
    {
      'title': 'Condition Snapshots',
      'description': 'Capture high-resolution spatial photos of every room corner.',
      'image': 'assets/photo_inspect.png',
    },
    {
      'title': 'Easy Documentation',
      'description': 'Seamlessly log structural status and comments dynamically.',
      'image': 'assets/room_doc.png',
    },
    {
      'title': 'Verified Sign-Offs',
      'description': 'Get official digitally signed PDF reports approved instantly.',
      'image': 'assets/signed_report.png',
    },
  ];

  @override
  void initState() {
    super.initState();
    _activeRole = widget.role;
    _userName = widget.userName ?? (widget.role == 'tenant' ? 'Liam Carter' : 'Victoria Sterling');
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_carouselController.hasClients) {
        int nextPage = _currentCarouselPage + 1;
        if (nextPage >= _carouselItems.length) {
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildDashboardTab(),
      ),
    );
  }

  // ==========================================
  // 1. DASHBOARD TAB
  // ==========================================
  // ==========================================
  // 1. DASHBOARD TAB
  // ==========================================
  Widget _buildDashboardTab() {
    final Color activeColor = _activeRole == 'tenant' ? const Color(0xFF007BFF) : const Color(0xFF2ECC71);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- HEADER & WELCOME ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 20),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                    );
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _activeRole == 'tenant' ? 'WELCOME BACK,' : 'PORTAL ACTIVE,',
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Theme(
                data: Theme.of(context).copyWith(
                  cardColor: Colors.white,
                ),
                child: PopupMenuButton<String>(
                  offset: const Offset(0, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.0),
                  ),
                  color: Colors.white,
                  elevation: 6,
                  icon: null,
                  tooltip: 'Profile & Settings',
                  onSelected: (value) {
                    if (value == 'profile') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileDetailsScreen(
                            role: _activeRole,
                            userName: _userName,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    } else if (value == 'history') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => HistoryScreen(
                            role: _activeRole,
                            userName: _userName,
                          ),
                        ),
                      );
                    } else if (value == 'settings') {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(
                            role: _activeRole,
                            userName: _userName,
                          ),
                        ),
                      ).then((_) => setState(() {}));
                    } else if (value == 'logout') {
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'profile',
                      child: Row(
                        children: [
                          Icon(Icons.person_outline_rounded, color: activeColor, size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'My Profile',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem<String>(
                      value: 'history',
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, color: activeColor, size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'Inspection History',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem<String>(
                      value: 'settings',
                      child: Row(
                        children: [
                          Icon(Icons.settings_outlined, color: activeColor, size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'Settings',
                            style: TextStyle(
                              color: Color(0xFF2C3E50),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(height: 1),
                    PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          const Icon(Icons.logout_rounded, color: Color(0xFFE74C3C), size: 20),
                          const SizedBox(width: 12),
                          const Text(
                            'Log Out',
                            style: TextStyle(
                              color: Color(0xFFE74C3C),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
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
                              color: activeColor.withOpacity(0.12),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                            style: TextStyle(
                              color: activeColor,
                              fontFamily: 'Montserrat',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 1.5,
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
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- PERSPECTIVE SWAP SEGMENT ---
          Container(
            width: double.infinity,
            height: 48,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9), // Flat, subtle light background
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _activeRole = 'tenant';
                        _userName = widget.userName ?? 'Liam Carter';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _activeRole == 'tenant' ? const Color(0xFF007BFF) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Tenant Mode',
                          style: TextStyle(
                            color: _activeRole == 'tenant' ? Colors.white : const Color(0xFF7F8C8D),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
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
                      setState(() {
                        _activeRole = 'landlord';
                        _userName = widget.userName ?? 'Victoria Sterling';
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _activeRole == 'landlord' ? const Color(0xFF2ECC71) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'Landlord Mode',
                          style: TextStyle(
                            color: _activeRole == 'landlord' ? Colors.white : const Color(0xFF7F8C8D),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
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
          const SizedBox(height: 24),

          // --- CORE OPERATION PANEL ---
          const Text(
            'QUICK PROTOCOL ACTIONS',
            style: TextStyle(
              color: Color(0xFF7F8C8D),
              fontFamily: 'Montserrat',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // Action 1: Register New Home Details
          _buildActionButton(
            title: 'Tell Us About Your New Home',
            description: 'Define property address, ID codes, and contract details.',
            icon: Icons.home_work_outlined,
            color: activeColor,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PropertyDetailsScreen(role: _activeRole, userName: _userName),
                ),
              );
            },
          ),
          const SizedBox(height: 28),

          // --- FEATURED HIGHLIGHTS CAROUSEL ---
          _buildImageCarousel(activeColor),
          const SizedBox(height: 28),

          // --- SUBSCRIPTION & SUBMISSIONS CONSOLE ---
          _buildSubscriptionConsole(activeColor),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFBDC3C7),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCarousel(Color activeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FEATURED HIGHLIGHTS',
          style: TextStyle(
            color: Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 160,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activeColor.withOpacity(0.15),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: activeColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(19),
            child: Stack(
              children: [
                // 1. PageView for Images wrapped with gesture tracking listener
                NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification notification) {
                    if (notification is ScrollStartNotification) {
                      _carouselTimer?.cancel();
                    } else if (notification is ScrollEndNotification) {
                      _carouselTimer?.cancel();
                      _startCarouselTimer();
                    }
                    return false;
                  },
                  child: PageView.builder(
                    controller: _carouselController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentCarouselPage = index;
                      });
                    },
                    itemCount: _carouselItems.length,
                    itemBuilder: (context, index) {
                      final item = _carouselItems[index];
                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background image
                          Image.asset(
                            item['image']!,
                            fit: BoxFit.cover,
                          ),
                          // Dark Gradient Overlay for text readability
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.75),
                                ],
                                stops: const [0.3, 1.0],
                              ),
                            ),
                          ),
                          // Text Content
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(right: 64.0), // space for dots
                                  child: Text(
                                    item['description']!,
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.85),
                                      fontFamily: 'Montserrat',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
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
                ),
                // 2. Dots Indicator inside the card (bottom center-right to avoid description overlap)
                Positioned(
                  bottom: 24,
                  right: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _carouselItems.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentCarouselPage == index ? 14 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentCarouselPage == index
                              ? activeColor
                              : Colors.white.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubscriptionConsole(Color activeColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. SUBSCRIPTION HEADER ---
        const Text(
          'SUBSCRIPTION STATUS',
          style: TextStyle(
            color: Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),

        // --- 2. PREMIUM SUBSCRIPTION CARD ---
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C3E50).withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: activeColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.verified_user_rounded,
                  color: activeColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TenantSnap Premium Pro',
                      style: TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Verification limit quota: Unlimited reports',
                      style: TextStyle(
                        color: const Color(0xFF7F8C8D),
                        fontFamily: 'Montserrat',
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF2ECC71).withOpacity(0.2),
                    width: 0.8,
                  ),
                ),
                child: const Text(
                  'ACTIVE',
                  style: TextStyle(
                    color: Color(0xFF2ECC71),
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
        const SizedBox(height: 28),

        // --- 3. SUBMISSIONS HEADER ---
        const Text(
          'RECENT SUBMISSIONS',
          style: TextStyle(
            color: Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),

        // --- 4. RECENT SUBMISSIONS PREVIEW LIST ---
        _buildSubmissionPreviewItem(
          title: 'Unit 402 - Urban Loft',
          date: 'June 2, 2026',
          status: 'VERIFIED',
          statusColor: const Color(0xFF2ECC71),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReportReviewScreen(
                  tenantName: _activeRole == 'tenant' ? _userName : 'Liam Carter',
                  landlordName: _activeRole == 'landlord' ? _userName : 'Victoria Sterling',
                  propertyAddress: 'Unit 402 - Urban Loft, San Francisco, CA 94107',
                  inspectionDate: 'June 2, 2026',
                ),
              ),
            );
          },
        ),
        const Divider(color: Color(0xFFE2E8F0), height: 1),
        _buildSubmissionPreviewItem(
          title: 'Villa 10 - Sunset Blvd',
          date: 'May 14, 2026',
          status: 'PENDING SIGNATURE',
          statusColor: activeColor,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ReportReviewScreen(
                  tenantName: 'Liam Carter',
                  landlordName: 'Victoria Sterling',
                  propertyAddress: 'Villa 10 - Sunset Blvd, Los Angeles, CA 90028',
                  inspectionDate: 'May 14, 2026',
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmissionPreviewItem({
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: statusColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.2), width: 0.8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontFamily: 'Montserrat',
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFBDC3C7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // 2. PROFILE & SETTINGS SCREEN
  // ==========================================
}

class ProfileDetailsScreen extends StatefulWidget {
  final String role;
  final String userName;

  const ProfileDetailsScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  State<ProfileDetailsScreen> createState() => _ProfileDetailsScreenState();
}

class _ProfileDetailsScreenState extends State<ProfileDetailsScreen> {
  late String _activeRole;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _activeRole = widget.role;
    _userName = widget.userName;
  }

  @override
  Widget build(BuildContext context) {
    final Color activeColor = _activeRole == 'tenant' ? const Color(0xFF007BFF) : const Color(0xFF2ECC71);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'MY PROFILE',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Color(0xFFE2E8F0),
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: activeColor, width: 2.0),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE5EEF5), Color(0xFFC6DBED)],
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _userName.isNotEmpty ? _userName[0].toUpperCase() : 'U',
                              style: TextStyle(
                                color: activeColor,
                                fontFamily: 'Montserrat',
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ECC71),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _userName,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _activeRole == 'tenant' ? 'Liam.Carter@snapnode.io' : 'Victoria.Sterling@snapnode.io',
                      style: const TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontFamily: 'Montserrat',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: activeColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: activeColor.withOpacity(0.2), width: 0.8),
                      ),
                      child: Text(
                        _activeRole == 'tenant' ? 'SECURE TENANT NODE' : 'VERIFIED LANDLORD PORTAL',
                        style: TextStyle(
                          color: activeColor,
                          fontFamily: 'Montserrat',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'USER CREDENTIAL NODE DETAILS',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              _buildTelemetryRow('Device ID Token', 'TS-9482-AD7X'),
              const Divider(color: Color(0xFFE2E8F0), height: 24),
              _buildTelemetryRow('Workspace Node ID', 'WSN-0294-SF82'),
              const Divider(color: Color(0xFFE2E8F0), height: 24),
              _buildTelemetryRow('Last Synced Stamp', 'June 16, 2026 • 17:30'),
              const Divider(color: Color(0xFFE2E8F0), height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTelemetryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF7F8C8D),
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final String role;
  final String userName;

  const HistoryScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'INSPECTION HISTORY',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Color(0xFFE2E8F0),
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SAVED INSPECTION ARCHIVE',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              _buildHistoryItem(
                context: context,
                title: 'Unit 402 - Urban Loft',
                date: 'June 2, 2026',
                status: 'VERIFIED',
                statusColor: const Color(0xFF2ECC71),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportReviewScreen(
                        tenantName: role == 'tenant' ? userName : 'Liam Carter',
                        landlordName: role == 'landlord' ? userName : 'Victoria Sterling',
                        propertyAddress: 'Unit 402 - Urban Loft, San Francisco, CA 94107',
                        inspectionDate: 'June 2, 2026',
                      ),
                    ),
                  );
                },
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              _buildHistoryItem(
                context: context,
                title: 'Villa 10 - Sunset Blvd',
                date: 'May 14, 2026',
                status: 'PENDING SIGNATURE',
                statusColor: const Color(0xFF2ECC71),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportReviewScreen(
                        tenantName: 'Liam Carter',
                        landlordName: 'Victoria Sterling',
                        propertyAddress: 'Villa 10 - Sunset Blvd, Los Angeles, CA 90028',
                        inspectionDate: 'May 14, 2026',
                      ),
                    ),
                  );
                },
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              _buildHistoryItem(
                context: context,
                title: 'Apartment 3C - Skyline Towers',
                date: 'April 20, 2026',
                status: 'COMPLETED ARCHIVE',
                statusColor: const Color(0xFF7F8C8D),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ReportReviewScreen(
                        tenantName: 'Liam Carter',
                        landlordName: 'Victoria Sterling',
                        propertyAddress: 'Apt 3C - Skyline Towers, New York, NY 10001',
                        inspectionDate: 'April 20, 2026',
                      ),
                    ),
                  );
                },
              ),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required BuildContext context,
    required String title,
    required String date,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: statusColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: const TextStyle(
                        color: Color(0xFF8F9CA9),
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.2), width: 0.8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontFamily: 'Montserrat',
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFBDC3C7),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final String role;
  final String userName;

  const SettingsScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C3E50), size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'SETTINGS',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 1.5,
          ),
        ),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1.0),
          child: Divider(
            color: Color(0xFFE2E8F0),
            height: 1.0,
            thickness: 1.0,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INTEGRATION PREFERENCES',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.notifications_none_rounded,
                    title: 'Push Notifications',
                    subtitle: 'Configure inspection alert alerts.',
                    onTap: () {},
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.fingerprint_rounded,
                    title: 'Biometric Access',
                    subtitle: 'Secure profile nodes biometric check.',
                    onTap: () {},
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  _buildSettingsTile(
                    context: context,
                    icon: Icons.cleaning_services_rounded,
                    title: 'Clear Cache',
                    subtitle: 'Erase cached document photo logs.',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Cache data erased successfully.')),
                      );
                    },
                  ),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                ],
              ),
              const SizedBox(height: 36),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded, color: Color(0xFFE74C3C), size: 20),
                        const SizedBox(width: 10),
                        Text(
                          'Log Out Portal Connection',
                          style: TextStyle(
                            color: const Color(0xFFE74C3C),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Color(0xFFF2F4F7),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xFF2C3E50),
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF2C3E50),
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w800,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xFF7F8C8D),
          fontFamily: 'Montserrat',
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFBDC3C7),
        size: 20,
      ),
    );
  }
}
