import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
    _commentController = TextEditingController(text: widget.room.comment);
    
    // Seed checklist items exactly as shown in the mockup screenshot:
    // 1. Ceiling (😄 active)
    // 2. Walls (😄 active)
    // 3. Floor / Carpet / Tiles (neutral/inactive)
    // 4. Doors / Door Frames (showing 2 photo thumbnails, no smileys)
    // 5. Closets / Wardrobes (smileys & camera icon)
    // 6. Shelving (smileys & camera icon)
    // 7. Closets / Wardrobes (smileys & camera icon)
    // 8. Windows / Blinds / Curtains (😟 active & camera icon)
    // 9. Light Fixtures (smileys & camera icon)
    // 10. Electrical Outlets (showing 2 photo thumbnails, no smileys)
    _checklist = [
      InspectionItem(name: "Ceiling", status: RoomItemStatus.happy),
      InspectionItem(name: "Walls", status: RoomItemStatus.happy),
      InspectionItem(name: "Floor / Carpet / Tiles", status: RoomItemStatus.neutral),
      InspectionItem(name: "Doors / Door Frames", status: RoomItemStatus.happy, photos: ["assets/bedroom_door1.jpg", "assets/bedroom_door2.jpg"]),
      InspectionItem(name: "Closets / Wardrobes", status: RoomItemStatus.neutral),
      InspectionItem(name: "Shelving", status: RoomItemStatus.neutral),
      InspectionItem(name: "Closets / Wardrobes", status: RoomItemStatus.neutral),
      InspectionItem(name: "Windows / Blinds / Curtains", status: RoomItemStatus.sad),
      InspectionItem(name: "Light Fixtures", status: RoomItemStatus.neutral),
      InspectionItem(name: "Electrical Outlets", status: RoomItemStatus.happy, photos: ["assets/outlet1.jpg", "assets/outlet2.jpg"]),
    ];

    // Synchronize initial mockup photos in timeline feed
    _photos = [
      {"path": "assets/bedroom_door1.jpg", "timestamp": "2026-06-02 10:14 • GPS 45.42, -75.69"},
      {"path": "assets/bedroom_door2.jpg", "timestamp": "2026-06-02 10:14 • GPS 45.42, -75.69"},
      {"path": "assets/outlet1.jpg", "timestamp": "2026-06-02 10:15 • GPS 45.42, -75.69"},
      {"path": "assets/outlet2.jpg", "timestamp": "2026-06-02 10:15 • GPS 45.42, -75.69"},
    ];
    
    // Set mock data room checklist to match our mockup checklist
    widget.room.checklist.clear();
    widget.room.checklist.addAll(_checklist);
    widget.room.recalculateProgress();
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

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source, {InspectionItem? targetItem}) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (!mounted) return;

      if (pickedFile != null) {
        final now = DateTime.now().toLocal().toString().split(' ')[1].substring(0, 5);
        final today = DateTime.now().toLocal().toString().split(' ')[0];
        final mockGps = " • GPS 45.42, -75.69";
        
        setState(() {
          if (targetItem != null) {
            targetItem.photos.add(pickedFile.path);
          }
          _photos.add({
            "path": pickedFile.path,
            "timestamp": "$today $now$mockGps",
          });
          widget.room.recalculateProgress();
        });
        _triggerUpdate();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2C3E50),
            duration: const Duration(seconds: 2),
            content: Text(
              targetItem != null
                  ? 'Photo added to ${targetItem.name}!'
                  : 'Photo added to timeline feed!',
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error capturing picture: $e'),
        ),
      );
    }
  }

  void _showImageSourcePicker({InspectionItem? targetItem}) {
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
                  targetItem != null
                      ? 'Add Photo for ${targetItem.name}'
                      : 'Add Photo to Timeline Feed',
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


  // Dynamic Add Custom Feature modal prompt
  void _showAddFeatureDialog() {
    final TextEditingController nameController = TextEditingController();
    bool hasCameraOption = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: hasCameraOption,
                        activeColor: const Color(0xFF007BFF),
                        onChanged: (value) {
                          setDialogState(() {
                            hasCameraOption = value ?? true;
                          });
                        },
                      ),
                      const Text(
                        'Include Camera Snap Option',
                        style: TextStyle(
                          color: Color(0xFF2C3E50),
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
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
                      setState(() {
                        _checklist.add(
                          InspectionItem(name: name, status: RoomItemStatus.neutral),
                        );
                        widget.room.recalculateProgress();
                      });
                      _triggerUpdate();
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
        decoration: BoxDecoration(
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
                  // Center-positioned premium mockup card container
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left-aligned Title & Right-aligned Blue Back Arrow exactly matching mockup
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${widget.room.name} Inspection',
                              style: const TextStyle(
                                color: Color(0xFF2C3E50),
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.w800,
                                fontSize: 21,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _triggerUpdate();
                                Navigator.of(context).pop();
                              },
                              child: const Icon(
                                Icons.arrow_back_ios_rounded,
                                color: Color(0xFF007BFF), // Mockup blue back arrow
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Checklist items workspace area styled with light-blue inner background
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEBF2F7), // Soft grey/blue panel background
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: _checklist.map((item) => _buildChecklistRow(item)).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Add Custom Feature button exactly matching mockup solid blue button styling
                        _buildAddFeatureButton(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistRow(InspectionItem item) {
    final bool canSnap = item.name != "Ceiling" && 
                         item.name != "Walls" && 
                         item.name != "Floor / Carpet / Tiles";

    return InspectionChecklistRow(
      item: item,
      canSnap: canSnap,
      onHappyTap: () {
        setState(() {
          item.status = RoomItemStatus.happy;
          widget.room.recalculateProgress();
        });
        _triggerUpdate();
      },
      onSadTap: () {
        setState(() {
          item.status = RoomItemStatus.sad;
          widget.room.recalculateProgress();
        });
        _triggerUpdate();
      },
      onNeutralTap: () {
        setState(() {
          item.status = RoomItemStatus.neutral;
          widget.room.recalculateProgress();
        });
        _triggerUpdate();
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
              // Gorgeous Image Preview
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
                  // Close Button
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
                  // Delete Button
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        item.photos.remove(photoPath);
                        _photos.removeWhere((p) => p["path"] == photoPath);
                        widget.room.recalculateProgress();
                      });
                      _triggerUpdate();
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
                      backgroundColor: const Color(0xFFE74C3C), // Solid Red
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
      // Mock assets - load gorgeous curated network previews for perfect mockup aesthetic!
      String imageUrl = "https://images.unsplash.com/photo-1513694203232-719a280e022f?w=150"; // default cozy room
      if (photoPath.contains("door")) {
        imageUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=150" // plant / door details
            : "https://images.unsplash.com/photo-1505691938895-1758d7feb511?w=150"; // cozy room door frame
      } else if (photoPath.contains("outlet")) {
        imageUrl = photoPath.contains("1")
            ? "https://images.unsplash.com/photo-1621905251189-08b45d6a269e?w=150" // electrical outlet details
            : "https://images.unsplash.com/photo-1558211583-d26f62177b97?w=150"; // wall corner aesthetic
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
            color: const Color(0xFF007BFF), // Solid blue button exactly matching mockup
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

// --- Decoupled Standalone Checklist Row Widget ---
class InspectionChecklistRow extends StatelessWidget {
  final InspectionItem item;
  final bool canSnap;
  final VoidCallback onHappyTap;
  final VoidCallback onSadTap;
  final VoidCallback onNeutralTap;
  final VoidCallback onCameraTap;
  final Widget Function(InspectionItem, String) thumbnailBuilder;

  const InspectionChecklistRow({
    super.key,
    required this.item,
    required this.canSnap,
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
        color: Colors.white, // White card list item
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
          // Row 1: Item Name (Left) and Controls (Right)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left Side: Feature Name styled in slate Montserrat
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
              
              // Right Side: Toggles and camera buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 😄 Happy Smile (Active green circle)
                  _buildMockupToggle(
                    isSelected: item.status == RoomItemStatus.happy,
                    activeColor: const Color(0xFF2ECC71),
                    icon: Icons.sentiment_satisfied_alt,
                    onTap: onHappyTap,
                  ),
                  const SizedBox(width: 6),
                  
                  // 😟 Sad Face (Active red circle)
                  _buildMockupToggle(
                    isSelected: item.status == RoomItemStatus.sad,
                    activeColor: const Color(0xFFE74C3C),
                    icon: Icons.sentiment_very_dissatisfied,
                    onTap: onSadTap,
                  ),
                  const SizedBox(width: 6),
                  
                  // Option 3: Either Neutral Dash or Circular Camera Icon Button
                  if (canSnap)
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
                    )
                  else
                    _buildMockupToggle(
                      isSelected: item.status == RoomItemStatus.neutral,
                      activeColor: const Color(0xFF95A5A6),
                      icon: Icons.remove,
                      onTap: onNeutralTap,
                    ),
                ],
              ),
            ],
          ),
          
          // Row 2: Photo thumbnails (if any) displayed below the controls
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
