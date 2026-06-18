import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tenantsnap/core/theme/app_theme.dart';
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';

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
    super.dispose();
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

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2C3E50),
            duration: const Duration(seconds: 2),
            content: Text(
              'Photo added to ${targetItem.name}!',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing picture: $e'),
        ),
      );
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
            padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add Photo for ${targetItem.name}',
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F6),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFBDC3C7).withOpacity(0.3)),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: Color(0xFF007BFF),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Take Photo',
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
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(ImageSource.gallery, targetItem: targetItem);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2F6),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFFBDC3C7).withOpacity(0.3)),
                            ),
                            child: const Icon(
                              Icons.photo_library_rounded,
                              color: Color(0xFF007BFF),
                              size: 28,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'From Gallery',
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
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Add Custom Feature',
            style: TextStyle(
              color: Color(0xFF2C3E50),
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'e.g. Air Conditioning, Heater',
                  hintStyle: const TextStyle(
                    color: Color(0xFF95A5A6),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2F4F7),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Color(0xFF95A5A6),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
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
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'Add Feature',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
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
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: size.width * 0.9,
                    constraints: const BoxConstraints(maxWidth: 380),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2C3E50).withOpacity(0.08),
                          blurRadius: 24,
                          spreadRadius: 4,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 28.0),
                    child: Obx(() {
                      final room = controller.roomsList.firstWhere((r) => r.id == widget.roomId);
                      final checklist = room.checklist;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${room.name} Inspection',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFF2C3E50),
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 21,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: const Icon(
                                  Icons.arrow_back_ios_rounded,
                                  color: Color(0xFF007BFF),
                                  size: 24,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          if (room.name.toLowerCase() == 'utils') ...[
                            const Text(
                              'LANDLORD PROVIDED UTILITIES',
                              style: TextStyle(
                                color: Color(0xFF95A5A6),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w700,
                                fontSize: 10,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEBF2F7),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: controller.availableUtilities.map((utility) => _buildChipItem(utility, checklist)).toList(),
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          const Text(
                            'VERIFY STATUS NODES',
                            style: TextStyle(
                              color: Color(0xFF95A5A6),
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 12),

                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEBF2F7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: checklist.map((item) => _buildChecklistRow(item)).toList(),
                            ),
                          ),
                          const SizedBox(height: 20),

                          _buildAddFeatureButton(),
                          const SizedBox(height: 12),

                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF007BFF),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),
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
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSel
              ? const LinearGradient(
                  colors: [Color(0xFF007BFF), Color(0xFF0056B3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSel ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSel ? Colors.transparent : const Color(0xFFBDC3C7).withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: isSel
              ? [
                  BoxShadow(
                    color: const Color(0xFF007BFF).withOpacity(0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSel) ...[
              const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              utility,
              style: TextStyle(
                color: isSel ? Colors.white : const Color(0xFF2C3E50),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w700,
                fontSize: 12,
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
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          contentPadding: const EdgeInsets.all(12),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 300),
                  width: double.infinity,
                  color: const Color(0xFFF2F4F7),
                  child: isRealFile && File(photoPath).existsSync()
                      ? Image.file(
                          File(photoPath),
                          fit: BoxFit.contain,
                        )
                      : Image.network(
                          photoPath.contains("door")
                              ? (photoPath.contains("1")
                                  ? "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=600"
                                  : "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=600")
                              : (photoPath.contains("1")
                                  ? "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=600"
                                  : "https://images.unsplash.com/photo-1558211583-d26f62177b97?w=600"),
                          fit: BoxFit.contain,
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Photo Evidence Capture',
                style: TextStyle(
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'GPS Active • Verified Condition Record',
                style: TextStyle(
                  color: Color(0xFF7F8C8D),
                  fontFamily: 'Montserrat',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Close',
                      style: TextStyle(
                        color: Color(0xFF7F8C8D),
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      final room = controller.roomsList.firstWhere((r) => r.id == widget.roomId);
                      item.photos.remove(photoPath);
                      room.recalculateProgress();
                      controller.roomsList.refresh();
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF2C3E50),
                          content: Text(
                            'Photo evidence deleted successfully.',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE74C3C),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                    label: const Text(
                      'Delete Photo',
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
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
        imageWidget = const Center(
          child: Icon(
            Icons.image_outlined,
            size: 14,
            color: Color(0xFF7F8C8D),
          ),
        );
      }
    } else {
      String imageUrl = "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=150";
      if (photoPath.contains("door")) {
        imageUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=150"
            : "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=150";
      } else if (photoPath.contains("outlet")) {
        imageUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150"
            : "https://images.unsplash.com/photo-1558211583-d26f62177b97?w=150";
      }
      
      imageWidget = Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(
              Icons.image_outlined,
              size: 14,
              color: Color(0xFF7F8C8D),
            ),
          );
        },
      );
    }

    return GestureDetector(
      onTap: () => _showPhotoPreviewDialog(item, photoPath),
      child: Container(
        width: 44,
        height: 32,
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: const Color(0xFFEEF2F6),
          border: Border.all(color: const Color(0xFFBDC3C7).withOpacity(0.3), width: 0.5),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(5),
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
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            color: const Color(0xFF007BFF),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF007BFF).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: 8),
              Text(
                'Add Custom Feature',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 3,
            offset: const Offset(0, 1.5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
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
                  style: const TextStyle(
                    color: Color(0xFF2C3E50),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildMockupToggle(
                    isSelected: item.status == RoomItemStatus.happy,
                    activeColor: const Color(0xFF2ECC71),
                    icon: Icons.sentiment_satisfied_alt,
                    onTap: onHappyTap,
                  ),
                  const SizedBox(width: 6),
                  _buildMockupToggle(
                    isSelected: item.status == RoomItemStatus.sad,
                    activeColor: const Color(0xFFE74C3C),
                    icon: Icons.sentiment_very_dissatisfied,
                    onTap: onSadTap,
                  ),
                  const SizedBox(width: 6),
                  _buildMockupToggle(
                    isSelected: item.status == RoomItemStatus.neutral,
                    activeColor: const Color(0xFF95A5A6),
                    icon: Icons.remove,
                    onTap: onNeutralTap,
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onCameraTap,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2C3E50),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.camera_alt,
                          size: 13,
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
            const SizedBox(height: 10),
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
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withOpacity(0.15) : const Color(0xFFEEF2F6),
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? activeColor : const Color(0xFFBDC3C7).withOpacity(0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Icon(
            icon,
            size: 16,
            color: isSelected ? activeColor : const Color(0xFF7F8C8D).withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
