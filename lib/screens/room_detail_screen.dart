import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/inspection_model.dart';

class RoomDetailScreen extends StatefulWidget {
  final RoomInspection room;
  final Function(RoomInspection) onUpdated;

  const RoomDetailScreen({
    super.key,
    required this.room,
    required this.onUpdated,
  });

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late List<InspectionItem> _checklist;
  late TextEditingController _commentController;
  List<Map<String, String>> _photos = []; // [{path, timestamp}]

  @override
  void initState() {
    super.initState();
    _checklist = widget.room.checklist;
    _commentController = TextEditingController(text: widget.room.comment);
    
    // Seed initial dummy photos
    _photos = [
      {"path": "assets/photo1.jpg", "timestamp": "2026-06-02 10:14:22 • (GPS 45.42, -75.69)"},
      {"path": "assets/photo2.jpg", "timestamp": "2026-06-02 10:16:05 • (GPS 45.42, -75.69)"},
    ];
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // Helper to trigger callback updates
  void _triggerUpdate() {
    widget.room.comment = _commentController.text;
    widget.onUpdated(widget.room);
  }

  void _addMockPhoto() {
    final now = DateTime.now().toLocal().toString().split('.')[0];
    final mockGps = " • (GPS 45.4215, -75.6972)";
    setState(() {
      _photos.add({
        "path": "assets/captured_${_photos.length + 1}.jpg",
        "timestamp": "$now$mockGps",
      });
      // Also add mock photo to the active checklist item that is 'sad' or 'happy' to demonstrate inline preview
      final sadItems = _checklist.where((item) => item.status == RoomItemStatus.sad).toList();
      if (sadItems.isNotEmpty) {
        sadItems.first.photos.add("assets/captured_${_photos.length}.jpg");
      } else if (_checklist.isNotEmpty) {
        _checklist.first.photos.add("assets/captured_${_photos.length}.jpg");
      }
    });
    _triggerUpdate();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AntigravityColors.primaryDb,
        duration: const Duration(seconds: 2),
        content: Row(
          children: [
            const Icon(Icons.add_a_photo_outlined, color: AntigravityColors.accentTeal),
            const SizedBox(width: 10),
            Text(
              'Neo-Camera Captured (Mock image picker triggered)',
              style: AntigravityTextStyles.bodyMedium(AntigravityColors.accentTeal),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportGenerationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: AntigravityCard(
                glowColor: AntigravityColors.accentTeal,
                glowOpacity: 0.4,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AntigravityColors.accentTeal.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.rocket_launch_outlined,
                        color: AntigravityColors.accentTeal,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'REPORT COMPILED',
                      style: AntigravityTextStyles.headingMedium(AntigravityColors.textMain).copyWith(
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'TenantSnap secure condition documentation complete.',
                      textAlign: TextAlign.center,
                      style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: Color(0x1AFFFFFF), height: 1),
                    const SizedBox(height: 16),
                    // Summary metrics
                    _buildReportMetricRow("Audited Elements", "${_checklist.where((i) => i.status != RoomItemStatus.neutral).length} Items"),
                    _buildReportMetricRow("Detected Faults", "${_checklist.where((i) => i.status == RoomItemStatus.sad).length} Defects"),
                    _buildReportMetricRow("Photo Evidence Logs", "${_photos.length} Captured"),
                    _buildReportMetricRow("Cryptographic Hash", "SHA-256 Verified"),
                    const SizedBox(height: 24),
                    
                    Container(
                      width: double.infinity,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(23),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF00FF66),
                            AntigravityColors.accentTeal,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF66).withOpacity(0.3),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                          Navigator.of(context).pop(); // Go back to screen 3
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(23),
                          ),
                        ),
                        child: Text(
                          'Sync to Landlord Terminal',
                          style: AntigravityTextStyles.bodyLarge(AntigravityColors.primaryDb).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReportMetricRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AntigravityTextStyles.bodyMedium(AntigravityColors.textMuted)),
          Text(
            value,
            style: AntigravityTextStyles.bodyLarge(AntigravityColors.textMain).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

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
          child: Column(
            children: [
              // --- 1. HEADER ---
              _buildHeader(context),
              
              // --- SCROLLABLE WORKSPACE ---
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Checklist Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'AUDITABLE FEATURES',
                            style: AntigravityTextStyles.headingSmall(AntigravityColors.textMuted).copyWith(
                              fontSize: 11,
                              letterSpacing: 2.0,
                            ),
                          ),
                          Text(
                            ' 😄  😟  ➖ ',
                            style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted).copyWith(
                              letterSpacing: 4.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // --- 2. LISTVIEW OF CHECKLIST ITEMS ---
                      Container(
                        decoration: BoxDecoration(
                          color: AntigravityColors.primaryCard,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AntigravityColors.textMuted.withOpacity(0.15)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _checklist.length,
                          separatorBuilder: (context, index) => Divider(
                            color: Colors.white.withOpacity(0.04),
                            height: 1,
                          ),
                          itemBuilder: (context, index) {
                            final item = _checklist[index];
                            return _buildChecklistRow(item);
                          },
                        ),
                      ),
                      const SizedBox(height: 28),

                      // --- 3. PHOTO TIMELINE SECTION ---
                      Text(
                        'METADATA PHOTO TIMELINE FEED',
                        style: AntigravityTextStyles.headingSmall(AntigravityColors.textMuted).copyWith(
                          fontSize: 11,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildPhotoFeed(),
                      const SizedBox(height: 28),

                      // --- 4. COMMENTS INPUT FIELD ---
                      Text(
                        'ADDITIONAL SPATIAL NOTES',
                        style: AntigravityTextStyles.headingSmall(AntigravityColors.textMuted).copyWith(
                          fontSize: 11,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildCommentField(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),

              // --- 5. GENERATE REPORT ACTION FOOTER ---
              _buildFooterButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              _triggerUpdate();
              Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                shape: BoxShape.circle,
                border: Border.all(color: AntigravityColors.textMuted.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AntigravityColors.textMain,
                size: 16,
              ),
            ),
          ),
          Text(
            '${widget.room.number}. ${widget.room.name} Inspection',
            style: AntigravityTextStyles.headingMedium(AntigravityColors.textMain).copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          // Dynamic status light based on progress
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: widget.room.progress == 100.0
                  ? const Color(0xFF00FF66)
                  : AntigravityColors.accentTeal,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.room.progress == 100.0
                      ? const Color(0xFF00FF66).withOpacity(0.6)
                      : AntigravityColors.accentTeal.withOpacity(0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistRow(InspectionItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Item name & inline thumbnail previews
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AntigravityTextStyles.bodyLarge(AntigravityColors.textMain).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (item.photos.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  // Inline photo thumbnails (matches fourth screenshot)
                  Row(
                    children: item.photos.map((photoPath) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6.0),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AntigravityColors.accentTeal.withOpacity(0.5), width: 0.5),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1B072B), Color(0xFF0A0C1A)],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: AntigravityColors.accentTeal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          
          // 3-Way Smiley toggles
          Row(
            children: [
              // Happy Smile 😄
              _build3WayToggle(
                item: item,
                status: RoomItemStatus.happy,
                activeColor: const Color(0xFF00FF66),
                icon: Icons.sentiment_satisfied_alt,
              ),
              const SizedBox(width: 10),
              // Sad Smile 😟
              _build3WayToggle(
                item: item,
                status: RoomItemStatus.sad,
                activeColor: const Color(0xFFFF3B30),
                icon: Icons.sentiment_very_dissatisfied,
              ),
              const SizedBox(width: 10),
              // Neutral Line ➖
              _build3WayToggle(
                item: item,
                status: RoomItemStatus.neutral,
                activeColor: AntigravityColors.textMuted,
                icon: Icons.remove,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _build3WayToggle({
    required InspectionItem item,
    required RoomItemStatus status,
    required Color activeColor,
    required IconData icon,
  }) {
    final bool isSelected = item.status == status;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          item.status = status;
        });
        _triggerUpdate();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.12) : Colors.white.withOpacity(0.02),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? activeColor : AntigravityColors.textMuted.withOpacity(0.2),
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 6,
                  ),
                ]
              : [],
        ),
        child: Center(
          child: Icon(
            icon,
            size: 18,
            color: isSelected ? activeColor : AntigravityColors.textMuted.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoFeed() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Large Add photo circular button
        GestureDetector(
          onTap: _addMockPhoto,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AntigravityColors.primaryCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AntigravityColors.accentTeal.withOpacity(0.6),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AntigravityColors.accentTeal.withOpacity(0.15),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    color: AntigravityColors.accentTeal,
                    size: 26,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'ADD PHOTO',
                    style: TextStyle(
                      color: AntigravityColors.accentTeal,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Photo placeholders feed with overlay
        Expanded(
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AntigravityColors.primaryCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AntigravityColors.textMuted.withOpacity(0.2)),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.landscape_outlined,
                            color: AntigravityColors.textMuted,
                            size: 24,
                          ),
                        ),
                      ),
                      // Overlay Timestamp / GPS Coordinates
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                          ),
                          child: Text(
                            photo["timestamp"] ?? '',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Color(0xFF00FF66),
                              fontSize: 5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentField() {
    return Container(
      decoration: BoxDecoration(
        color: AntigravityColors.primaryCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AntigravityColors.textMuted.withOpacity(0.15),
        ),
      ),
      child: TextField(
        controller: _commentController,
        maxLines: 3,
        style: AntigravityTextStyles.bodyLarge(AntigravityColors.textMain),
        decoration: InputDecoration(
          hintText: 'Enter specific comments regarding room defects, appliance maintenance serial codes, or floor scratches...',
          hintStyle: AntigravityTextStyles.bodyMedium(AntigravityColors.textMuted).copyWith(
            height: 1.4,
          ),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
        onChanged: (text) => _triggerUpdate(),
      ),
    );
  }

  Widget _buildFooterButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AntigravityColors.primaryDb.withOpacity(0.6),
        border: Border(
          top: BorderSide(color: AntigravityColors.textMuted.withOpacity(0.15), width: 0.5),
        ),
      ),
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          gradient: const LinearGradient(
            colors: [
              AntigravityColors.accentTeal,
              Color(0xFF005C8A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AntigravityColors.accentTeal.withOpacity(0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _showReportGenerationDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(26),
            ),
          ),
          child: Text(
            'GENERATE SECURE REPORT',
            style: AntigravityTextStyles.headingSmall(AntigravityColors.primaryDb).copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
