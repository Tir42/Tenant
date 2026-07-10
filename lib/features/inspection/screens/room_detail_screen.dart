import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
import 'package:tenantsnap/core/utils/responsive/responsive_extension.dart';


class RoomDetailScreen extends StatefulWidget {
  final int roomId;

  const RoomDetailScreen({
    super.key,
    required this.roomId,
  });

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  final InspectionController controller = Get.find<InspectionController>();
  late TextEditingController _commentController;
  final ImagePicker _picker = ImagePicker();

  // Keeps track of the currently visible top toast so a new one can
  // replace it instead of stacking multiple toasts on screen.
  OverlayEntry? _activeToastEntry;

  @override
  void initState() {
    super.initState();
    final room = controller.roomsList.firstWhere((r) => r.id == widget.roomId);
    _commentController = TextEditingController(text: room.comment);

    _commentController.addListener(() {
      final r = controller.roomsList.firstWhere((room) => room.id == widget.roomId);
      r.comment = _commentController.text;
      controller.roomsList.refresh();
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _dismissTopToast();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Top toast overlay (replaces SnackBar)
  // ---------------------------------------------------------------------------

  void _dismissTopToast() {
    _activeToastEntry?.remove();
    _activeToastEntry = null;
  }

  void _showTopToast(
      String message, {
        String? actionLabel,
        VoidCallback? onAction,
        Duration duration = const Duration(seconds: 4),
      }) {
    // Remove any toast that's already showing so they don't stack.
    _dismissTopToast();

    final overlay = Overlay.of(context, rootOverlay: true);

    final entry = OverlayEntry(
      builder: (context) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 12.0.h,
          left: 16.0.w,
          right: 16.0.w,
          child: Material(
            color: Colors.transparent,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * -24),
                    child: child,
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.0.w, vertical: 12.0.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(18.0.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 12.0.w,
                      offset: Offset(0, 4.0.h),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.0.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt_rounded,
                        color: const Color(0xFF007BFF),
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: 12.0.w),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 12.0.sp,
                        ),
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      SizedBox(width: 8.0.w),
                      GestureDetector(
                        onTap: () {
                          _dismissTopToast();
                          onAction();
                        },
                        child: Text(
                          actionLabel,
                          style: TextStyle(
                            color: const Color(0xFF007BFF),
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w800,
                            fontSize: 12.0.sp,
                          ),
                        ),
                      ),
                    ],
                    SizedBox(width: 10.0.w),
                    GestureDetector(
                      onTap: _dismissTopToast,
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white.withValues(alpha: 0.7),
                        size: 18.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );

    _activeToastEntry = entry;
    overlay.insert(entry);

    Future.delayed(duration, () {
      if (_activeToastEntry == entry) {
        _dismissTopToast();
      }
    });
  }

  Future<void> _pickImage(ImageSource source, {required InspectionItem targetItem}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        controller.addPhotoToItem(widget.roomId, targetItem.name, pickedFile.path);

        if (!mounted) return;
        _showTopToast('Photo added to ${targetItem.name}!');
      }
    } catch (e) {
      if (!mounted) return;
      _showTopToast('Error capturing picture: $e');
    }
  }

  void _showImageSourcePicker({required InspectionItem targetItem}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.0.h, horizontal: 16.0.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Photo for ${targetItem.name}',
                  style: TextStyle(
                    color: const Color(0xFF2C3E50),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0.sp,
                  ),
                ),
                SizedBox(height: 20.0.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.camera, targetItem: targetItem);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.0.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F6),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFBDC3C7).withValues(alpha: 0.3)),
                            ),
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: const Color(0xFF007BFF),
                              size: 28.w,
                            ),
                          ),
                          SizedBox(height: 8.0.h),
                          Text(
                            'Take Photo',
                            style: TextStyle(
                              color: const Color(0xFF2C3E50),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 13.0.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery, targetItem: targetItem);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16.0.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F6),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFBDC3C7).withValues(alpha: 0.3)),
                            ),
                            child: Icon(
                              Icons.photo_library_rounded,
                              color: const Color(0xFF007BFF),
                              size: 28.w,
                            ),
                          ),
                          SizedBox(height: 8.0.h),
                          Text(
                            'From Gallery',
                            style: TextStyle(
                              color: const Color(0xFF2C3E50),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 13.0.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddFeatureDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0.w),
          ),
          title: Text(
            'Add Custom Feature',
            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 18.0.sp,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 14.0.sp,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Air Conditioning, Heater',
                  hintStyle: TextStyle(
                    color: const Color(0xFF95A5A6),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: 13.0.sp,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2F4F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0.w),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 14.0.h),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: const Color(0xFF95A5A6),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0.sp,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final String name = nameController.text.trim();
                if (name.isNotEmpty) {
                  final room = controller.roomsList.firstWhere((r) => r.id == widget.roomId);
                  if (room.name.toLowerCase() == 'utils') {
                    controller.addUtilityItem(name);
                  } else {
                    room.checklist.add(InspectionItem(name: name, status: RoomItemStatus.neutral));
                    room.recalculateProgress();
                    controller.roomsList.refresh();
                  }
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF007BFF),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0.w),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 10.0.h),
              ),
              child: Text(
                'Add Feature',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 14.0.sp,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String roomName) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6.0.w,
                  offset: Offset(0, 2.0.h),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.arrow_back_rounded,
                color: const Color(0xFF2C3E50),
                size: 20.w,
              ),
            ),
          ),
        ),
        SizedBox(width: 14.0.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$roomName Inspection',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w800,
                  fontSize: 18.0.sp,
                ),
              ),
              SizedBox(height: 2.0.h),
              Text(
                'Verify features & capture condition',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: const Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 12.0.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0.w),
        border: Border.all(
          color: const Color(0xFFBDC3C7).withValues(alpha: 0.2),
          width: 1.0.w,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.04),
            blurRadius: 8.0.w,
            offset: Offset(0, 4.0.h),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'INSPECTION NOTES',
            style: TextStyle(
              color: const Color(0xFF7F8C8D),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w700,
              fontSize: 10.0.sp,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 12.0.h),
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: TextStyle(
              color: const Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.w500,
              fontSize: 14.0.sp,
            ),
            decoration: InputDecoration(
              hintText: 'Add comments or special notes about the room condition...',
              hintStyle: TextStyle(
                color: const Color(0xFF95A5A6),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w400,
                fontSize: 13.0.sp,
              ),
              filled: true,
              fillColor: const Color(0xFFF2F4F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0.w),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0.w, vertical: 14.0.h),
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
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 16.0.h),
            child: Obx(() {
              final room = controller.roomsList.firstWhere((r) => r.id == widget.roomId);
              final checklist = room.checklist;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, room.name),
                  SizedBox(height: 24.0.h),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (room.name.toLowerCase() == 'utils') ...[
                            Text(
                              'LANDLORD PROVIDED UTILITIES',
                              style: TextStyle(
                                color: const Color(0xFF95A5A6),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 10.0.sp,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(height: 10.0.h),
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.0.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20.0.w),
                                border: Border.all(
                                  color: const Color(0xFFBDC3C7).withValues(alpha: 0.2),
                                  width: 1.0.w,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF2C3E50).withValues(alpha: 0.04),
                                    blurRadius: 8.0.w,
                                    offset: Offset(0, 4.0.h),
                                  ),
                                ],
                              ),
                              child: Wrap(
                                spacing: 8.0.w,
                                runSpacing: 8.0.h,
                                children: controller.availableUtilities.map((utility) => _buildChipItem(utility, checklist)).toList(),
                              ),
                            ),
                            SizedBox(height: 20.0.h),
                          ],
                          Text(
                            'VERIFY STATUS NODES',
                            style: TextStyle(
                              color: const Color(0xFF95A5A6),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 10.0.sp,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 12.0.h),
                          ...checklist.map((item) => _buildChecklistRow(item)),
                          SizedBox(height: 8.0.h),
                          _buildCommentCard(),
                          SizedBox(height: 20.0.h),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0.h),
                  _buildAddFeatureButton(),
                  SizedBox(height: 12.0.h),
                  _buildSaveButton(),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildChipItem(String utility, List<InspectionItem> checklist) {
    final bool isSel = checklist.any((item) => item.name == utility);
    return InkWell(
      onTap: () {
        if (isSel) {
          controller.removeUtilityItem(utility);
        } else {
          controller.addUtilityItem(utility);
        }
      },
      borderRadius: BorderRadius.circular(12.0.w),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.0.w, vertical: 8.0.h),
        decoration: BoxDecoration(
          gradient: isSel
              ? const LinearGradient(
            colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSel ? null : Colors.white,
          borderRadius: BorderRadius.circular(12.0.w),
          border: Border.all(
            color: isSel ? Colors.transparent : const Color(0xFFBDC3C7).withValues(alpha: 0.5),
            width: 1.5.w,
          ),
          boxShadow: isSel
              ? [
            BoxShadow(
              color: const Color(0xFF007BFF).withValues(alpha: 0.25),
              blurRadius: 6.0.w,
              offset: Offset(0, 2.0.h),
            ),
          ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSel) ...[
              Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 14.w,
              ),
              SizedBox(width: 6.0.w),
            ],
            Text(
              utility,
              style: TextStyle(
                color: isSel ? Colors.white : const Color(0xFF2C3E50),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 12.0.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistRow(InspectionItem item) {
    return InspectionChecklistRow(
      item: item,
      onHappyTap: () {
        controller.updateItemStatus(widget.roomId, item.name, RoomItemStatus.happy);
      },
      onSadTap: () {
        controller.updateItemStatus(widget.roomId, item.name, RoomItemStatus.sad);

        // Top toast overlay instead of a SnackBar.
        _showTopToast(
          'Add a repair photo for "${item.name}" to keep strong evidence.',
          actionLabel: 'ADD',
          onAction: () => _showImageSourcePicker(targetItem: item),
        );
      },
      onNeutralTap: () {
        if (controller.roomsList.firstWhere((r) => r.id == widget.roomId).name.toLowerCase() == 'utils') {
          controller.removeUtilityItem(item.name);
        } else {
          final room = controller.roomsList.firstWhere((r) => r.id == widget.roomId);
          room.checklist.remove(item);
          room.recalculateProgress();
          controller.roomsList.refresh();
        }
      },
      onCameraTap: () => _showImageSourcePicker(targetItem: item),
      thumbnailBuilder: _buildPhotoThumbnail,
    );
  }

  void _showPhotoPreviewDialog(InspectionItem item, String photoPath) {
    final bool isRealFile = !photoPath.startsWith('assets/');

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 40.0.h),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28.0.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 24.0.w,
                  offset: Offset(0, 10.0.h),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.topRight,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28.0.w),
                        topRight: Radius.circular(28.0.w),
                      ),
                      child: Container(
                        constraints: BoxConstraints(maxHeight: 320.0.h),
                        width: double.infinity,
                        color: const Color(0xFFF2F4F7),
                        child: isRealFile && File(photoPath).existsSync()
                            ? Image.file(
                          File(photoPath),
                          fit: BoxFit.cover,
                        )
                            : Image.network(
                          photoPath.contains("door")
                              ? (photoPath.contains("1")
                              ? "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=600"
                              : "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=600")
                              : (photoPath.contains("1")
                              ? "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600"
                              : "https://images.unsplash.com/photo-1558211583-d26f62177b97?w=600"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        margin: EdgeInsets.all(16.0.w),
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.4),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 20.w,
                        ),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0.w, vertical: 20.0.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${item.name} Evidence Capture',
                        style: TextStyle(
                          color: const Color(0xFF2C3E50),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0.sp,
                        ),
                      ),
                      SizedBox(height: 4.0.h),
                      Text(
                        'GPS Active • Verified Condition Record',
                        style: TextStyle(
                          color: const Color(0xFF7F8C8D),
                          fontFamily: 'Montserrat',
                          fontSize: 12.0.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 24.0.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: const Color(0xFFBDC3C7), width: 1.0.w),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0.w),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.0.h),
                              ),
                              child: Text(
                                'Close',
                                style: TextStyle(
                                  color: const Color(0xFF7F8C8D),
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14.0.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.0.w),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                final room = controller.roomsList.firstWhere((r) => r.id == widget.roomId);
                                item.photos.remove(photoPath);
                                room.recalculateProgress();
                                controller.roomsList.refresh();
                                Navigator.pop(context);
                                _showTopToast('Photo evidence deleted successfully.');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE74C3C),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0.w),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 14.0.h),
                              ),
                              icon: Icon(Icons.delete_outline, color: Colors.white, size: 18.w),
                              label: Text(
                                'Delete',
                                style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 14.0.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhotoThumbnail(InspectionItem item, String photoPath) {
    final bool isRealFile = !photoPath.startsWith('assets/');

    Widget imageWidget;
    if (isRealFile) {
      if (File(photoPath).existsSync()) {
        imageWidget = Image.file(
          File(photoPath),
          fit: BoxFit.cover,
        );
      } else {
        imageWidget = Center(
          child: Icon(
            Icons.image_outlined,
            size: 24.w,
            color: const Color(0xFF7F8C8D),
          ),
        );
      }
    } else {
      String imageUrl = "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=300";
      if (photoPath.contains("door")) {
        imageUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=300"
            : "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=300";
      } else if (photoPath.contains("outlet")) {
        imageUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=300"
            : "https://images.unsplash.com/photo-1558211583-d26f62177b97?w=300";
      }

      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.image_outlined,
              size: 24.w,
              color: const Color(0xFF7F8C8D),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => _showPhotoPreviewDialog(item, photoPath),
      child: Container(
        width: 72.w,
        height: 72.h,
        margin: EdgeInsets.only(right: 10.0.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0.w),
          color: const Color(0xFFEEF2F6),
          border: Border.all(color: const Color(0xFFBDC3C7).withValues(alpha: 0.4), width: 1.0.w),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11.0.w),
          child: imageWidget,
        ),
      ),
    );
  }

  Widget _buildAddFeatureButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showAddFeatureDialog,
        borderRadius: BorderRadius.circular(25.0.w),
        child: Container(
          height: 50.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(25.0.w),
            border: Border.all(
              color: const Color(0xFF007BFF),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007BFF).withValues(alpha: 0.05),
                blurRadius: 8.0.w,
                offset: Offset(0, 3.0.h),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(4.0.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF007BFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 12.w,
                ),
              ),
              SizedBox(width: 10.0.w),
              Text(
                'Add Custom Feature',
                style: TextStyle(
                  color: const Color(0xFF007BFF),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14.0.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF007BFF),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25.0.w),
          ),
          padding: EdgeInsets.zero,
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25.0.w),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007BFF).withValues(alpha: 0.3),
                blurRadius: 12.0.w,
                offset: Offset(0, 4.0.h),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 14.0.sp,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InspectionChecklistRow extends StatelessWidget {
  final InspectionItem item;
  final VoidCallback onHappyTap;
  final VoidCallback onSadTap;
  final VoidCallback onNeutralTap;
  final VoidCallback onCameraTap;
  final Widget Function(InspectionItem, String) thumbnailBuilder;

  const InspectionChecklistRow({
    super.key,
    required this.item,
    required this.onHappyTap,
    required this.onSadTap,
    required this.onNeutralTap,
    required this.onCameraTap,
    required this.thumbnailBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasPhotos = item.photos.isNotEmpty;

    return Container(
      margin: EdgeInsets.only(bottom: 12.0.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0.w),
        border: Border.all(
          color: const Color(0xFFBDC3C7).withValues(alpha: 0.2),
          width: 1.0.w,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2C3E50).withValues(alpha: 0.04),
            blurRadius: 8.0.w,
            offset: Offset(0, 4.0.h),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 14.0.w, vertical: 12.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xFF2C3E50),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 14.0.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.0.w),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMockupToggle(
                    isSelected: item.status == RoomItemStatus.happy,
                    activeColor: const Color(0xFF2ECC71),
                    icon: Icons.sentiment_satisfied_alt,
                    onTap: onHappyTap,
                  ),
                  SizedBox(width: 6.0.w),
                  _buildMockupToggle(
                    isSelected: item.status == RoomItemStatus.sad,
                    activeColor: const Color(0xFFE74C3C),
                    icon: Icons.sentiment_very_dissatisfied,
                    onTap: onSadTap,
                  ),
                  SizedBox(width: 6.0.w),
                  _buildMockupToggle(
                    isSelected: item.status == RoomItemStatus.neutral,
                    activeColor: const Color(0xFF95A5A6),
                    icon: Icons.remove,
                    onTap: onNeutralTap,
                  ),
                  SizedBox(width: 6.0.w),
                  GestureDetector(
                    onTap: onCameraTap,
                    child: Container(
                      width: 28.w,
                      height: 28.h,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C3E50),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 13.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (hasPhotos) ...[
            SizedBox(height: 12.0.h),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: item.photos.map((p) => thumbnailBuilder(item, p)).toList(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMockupToggle({
    required bool isSelected,
    required Color activeColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 28.w,
        height: 28.h,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : const Color(0xFFEEF2F6),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFBDC3C7).withValues(alpha: 0.3),
            width: isSelected ? 1.5.w : 1.0.w,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16.w,
            color: isSelected ? activeColor : const Color(0xFF7F8C8D).withValues(alpha: 0.6),
          ),
        ),
      ),
    );
  }
}