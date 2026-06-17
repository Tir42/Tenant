import 'package:flutter/material.dart';
import 'package:tenantsnap/features/inspection/screens/report_review_screen.dart';

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
