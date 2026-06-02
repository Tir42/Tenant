import 'package:flutter/material.dart';
import '../theme.dart';
import '../models/inspection_model.dart';
import 'room_detail_screen.dart';

class InspectionFlowListScreen extends StatefulWidget {
  const InspectionFlowListScreen({super.key});

  @override
  State<InspectionFlowListScreen> createState() => _InspectionFlowListScreenState();
}

class _InspectionFlowListScreenState extends State<InspectionFlowListScreen> {
  // Local state for the dynamic inspection rooms list
  late List<RoomInspection> _roomsList;

  @override
  void initState() {
    super.initState();
    _roomsList = getMockInspectionData();
  }

  // Handle callback updates from detail screen
  void _updateRoomState(RoomInspection updatedRoom) {
    setState(() {
      int index = _roomsList.indexWhere((r) => r.id == updatedRoom.id);
      if (index != -1) {
        _roomsList[index] = updatedRoom;
        _roomsList[index].recalculateProgress();
      }
    });
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
              // --- 1. HEADER SECTION ---
              _buildHeaderSection(context),
              
              // --- 2. HEXAGONAL PROGRESS BAR ---
              _buildProgressionBar(),
              
              const SizedBox(height: 16),
              
              // --- LIST VIEW HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RESIDENTIAL SPATIAL ROOMS',
                      style: AntigravityTextStyles.headingSmall(AntigravityColors.textMuted).copyWith(
                        fontSize: 11,
                        letterSpacing: 2.0,
                      ),
                    ),
                    Text(
                      '${_roomsList.length} SPACES DETECTED',
                      style: AntigravityTextStyles.bodySmall(AntigravityColors.accentTeal).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // --- 3. DYNAMIC LIST OF ROOMS ---
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                  itemCount: _roomsList.length,
                  itemBuilder: (context, index) {
                    final RoomInspection room = _roomsList[index];
                    // Specifically highlight Kitchen (ID: 5) as the active room as requested,
                    // or let it be whichever room the user clicks on that needs attention.
                    final bool isActive = room.name == "Kitchen";
                    
                    return _buildRoomTile(context, room, isActive);
                  },
                ),
              ),

              // --- 4. BOTTOM ACTION FOOTER BUTTONS ---
              _buildBottomActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
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
            'START INSPECTION FLOW',
            style: AntigravityTextStyles.headingMedium(AntigravityColors.textMain).copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AntigravityColors.accentTeal.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AntigravityColors.accentTeal.withOpacity(0.2)),
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: AntigravityColors.accentTeal,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressionBar() {
    // Elegant progression bar mapping steps:
    // Step 1: Info (Check) -> Step 2: Role (Check) -> Step 3: Space Checklist (Active Hexagon) -> Step 4: Add Photos -> Step 5: Generate
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AntigravityColors.primaryCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AntigravityColors.textMuted.withOpacity(0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildHexagonStep(1, "Init", true, false),
            _buildStepConnector(true),
            _buildHexagonStep(2, "Role", true, false),
            _buildStepConnector(true),
            _buildHexagonStep(3, "Spaces", false, true), // Active Step
            _buildStepConnector(false),
            _buildHexagonStep(4, "Capture", false, false),
            _buildStepConnector(false),
            _buildHexagonStep(5, "Compile", false, false),
          ],
        ),
      ),
    );
  }

  Widget _buildHexagonStep(int number, String label, bool isCompleted, bool isActive) {
    Color ringColor = AntigravityColors.textMuted.withOpacity(0.4);
    Color fillColor = Colors.transparent;
    Color textColor = AntigravityColors.textMuted;
    
    if (isCompleted) {
      ringColor = const Color(0xFF00FF66);
      fillColor = const Color(0xFF00FF66).withOpacity(0.1);
      textColor = const Color(0xFF00FF66);
    } else if (isActive) {
      ringColor = AntigravityColors.accentTeal;
      fillColor = AntigravityColors.accentTeal.withOpacity(0.15);
      textColor = AntigravityColors.accentTeal;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          size: const Size(26, 26),
          painter: HexagonPainter(
            color: ringColor,
            fillColor: fillColor,
            isActive: isActive,
          ),
          child: SizedBox(
            width: 26,
            height: 26,
            child: Center(
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: Color(0xFF00FF66))
                  : Text(
                      '$number',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Expanded(
      child: Container(
        height: 1,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isActive
                ? [const Color(0xFF00FF66), AntigravityColors.accentTeal]
                : [AntigravityColors.textMuted.withOpacity(0.2), AntigravityColors.textMuted.withOpacity(0.1)],
          ),
        ),
      ),
    );
  }

  Widget _buildRoomTile(BuildContext context, RoomInspection room, bool isActive) {
    // Dynamic progress parameters
    Color progressColor = AntigravityColors.roleTenant;
    if (room.progress == 100.0) {
      progressColor = const Color(0xFF00FF66);
    } else if (isActive) {
      progressColor = AntigravityColors.accentTeal;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: AntigravityCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => RoomDetailScreen(
                room: room,
                onUpdated: _updateRoomState,
              ),
            ),
          );
        },
        hasActiveGlow: isActive,
        glowColor: isActive ? AntigravityColors.accentTeal : AntigravityColors.textMuted,
        glowOpacity: isActive ? 0.25 : 0.04,
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Room Icon sphere
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: isActive
                      ? [AntigravityColors.accentTeal.withOpacity(0.2), AntigravityColors.primaryCard]
                      : [Colors.white.withOpacity(0.02), Colors.black.withOpacity(0.2)],
                  radius: 0.85,
                ),
                border: Border.all(
                  color: isActive ? AntigravityColors.accentTeal : AntigravityColors.textMuted.withOpacity(0.2),
                  width: isActive ? 1.5 : 1.0,
                ),
              ),
              child: Icon(
                room.icon,
                color: isActive ? AntigravityColors.accentTeal : AntigravityColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Name and Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${room.number}. ${room.name}',
                        style: AntigravityTextStyles.headingSmall(AntigravityColors.textMain).copyWith(
                          fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                          color: isActive ? AntigravityColors.accentTeal : AntigravityColors.textMain,
                        ),
                      ),
                      if (isActive) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AntigravityColors.accentTeal.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AntigravityColors.accentTeal.withOpacity(0.4), width: 0.5),
                          ),
                          child: const Text(
                            'ACTIVE NODE',
                            style: TextStyle(
                              color: AntigravityColors.accentTeal,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: AntigravityColors.textMuted.withOpacity(0.7),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${room.checklist.where((item) => item.status != RoomItemStatus.neutral).length} of ${room.checklist.length} Elements Audited',
                        style: AntigravityTextStyles.bodySmall(AntigravityColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Progress ring
            NeonCircularProgress(
              percentage: room.progress,
              size: 44,
              strokeWidth: 3.5,
              activeColor: progressColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: AntigravityColors.primaryDb.withOpacity(0.6),
        border: Border(
          top: BorderSide(color: AntigravityColors.textMuted.withOpacity(0.15), width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Back Outline Button
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AntigravityColors.textMuted.withOpacity(0.3)),
              ),
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Dashboard',
                  style: AntigravityTextStyles.bodyLarge(AntigravityColors.textMuted).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Next Step Solid Glowing Button
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    AntigravityColors.accentTeal,
                    Color(0xFF00C6FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AntigravityColors.accentTeal.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // Compile final and generate report notification
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AntigravityColors.primaryDb,
                      content: Text(
                        'Compiling checklist nodes. Navigate to Room 5 for final verification.',
                        style: AntigravityTextStyles.bodyMedium(AntigravityColors.accentTeal),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Next Step',
                  style: AntigravityTextStyles.bodyLarge(AntigravityColors.primaryDb).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Hexagon Painter for geometric progression indicator steps
class HexagonPainter extends CustomPainter {
  final Color color;
  final Color fillColor;
  final bool isActive;

  HexagonPainter({
    required this.color,
    required this.fillColor,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    
    final Path path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.25)
      ..lineTo(w, h * 0.75)
      ..lineTo(w * 0.5, h)
      ..lineTo(0, h * 0.75)
      ..lineTo(0, h * 0.25)
      ..close();

    if (isActive) {
      final Paint glowPaint = Paint()
        ..color = color.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0);
      canvas.drawPath(path, glowPaint);
    }

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    final Paint borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = isActive ? 1.8 : 1.0;
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant HexagonPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.isActive != isActive;
  }
}
