import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, MultipartFile, FormData;
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:tenantsnap/core/services/rest_client.dart';
import 'package:tenantsnap/core/utils/download_helper/download_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:convert';
import 'package:tenantsnap/features/inspection/models/inspection_model.dart';
import 'package:tenantsnap/core/utils/pdf/pdf_generator.dart';
import 'package:tenantsnap/features/property/screens/property_details_screen.dart';
import 'package:tenantsnap/features/inspection/controllers/inspection_controller.dart';
import 'package:tenantsnap/features/dashboard/controllers/dashboard_controller.dart';

class HistoryScreen extends StatefulWidget {
  final String role;
  final String userName;

  const HistoryScreen({
    super.key,
    required this.role,
    required this.userName,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _historyItems = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final restClient = Get.find<RestClient>();
      final box = GetStorage();
      final userId = box.read('userId');

      final Map<String, dynamic> queryParams = {
        'userName': widget.userName,
        'role': widget.role,
      };
      if (userId != null) {
        if (userId is int && userId > 0) {
          queryParams['userId'] = userId;
        } else if (userId is String && int.tryParse(userId) != null && int.parse(userId) > 0) {
          queryParams['userId'] = int.parse(userId);
        }
      }

      final response = await restClient.dio.get(
        '/pdf-history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        setState(() {
          _historyItems = response.data['data'] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to load history');
      }
    } catch (e) {
      debugPrint("Fetch history error: $e");
      setState(() {
        _errorMessage = 'Could not load your history archive.\nPlease check your connection and try again.';
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadAndOpenPdf(Map<String, dynamic> item) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFF007BFF),
                ),
                SizedBox(height: 16),
                Text(
                  'Opening report PDF...',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    fontSize: 14,
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
      final dio = restClient.dio;

      String rawBase = dio.options.baseUrl;
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
        throw Exception("Downloaded content is not a valid PDF file. The file may be missing from the server or your local backend is not running.");
      }

      final fileName = 'TenantSnap_Report_${item['idCode'] ?? 'Archive'}_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final savedPath = await DownloadHelper.downloadPdf(
        bytes: bytes,
        fileName: fileName,
      );

      // Pop the loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (savedPath != null) {
        await OpenFilex.open(savedPath);
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

          if (mounted) {
            try {
              Navigator.pop(context);
            } catch (_) {}
          }

          if (savedPath != null) {
            final result = await OpenFilex.open(savedPath);
            if (result.type == ResultType.done) {
              return;
            }
            throw Exception(result.message);
          } else {
            throw Exception('Could not write regenerated PDF to local storage.');
          }
        } catch (fallbackError) {
          debugPrint("PDF regeneration fallback failed: $fallbackError");
        }
      }

      // Pop the loading dialog
      if (mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE74C3C),
            content: Text(
              'Failed to open report PDF: $e',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }
  }

  void _editInspectionReport(Map<String, dynamic> item) {
    try {
      final inspectionController = Get.find<InspectionController>();
      inspectionController.clearInspectionData();
      
      inspectionController.editingRecordId.value = item['_id'] ?? '';
      
      final String? inspectionDataStr = item['inspectionData'];
      if (inspectionDataStr != null && inspectionDataStr.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(inspectionDataStr);
        inspectionController.importFromJson(data);
      } else {
        // Fallback for older items that do not have inspectionData
        inspectionController.idCode.value = item['idCode'] ?? '';
        inspectionController.tenantName.value = item['tenantName'] ?? '';
        inspectionController.landlordName.value = item['landlordName'] ?? '';
        inspectionController.propertyAddress.value = item['propertyAddress'] ?? '';
        inspectionController.agreementDate.value = item['date'] ?? '';
        inspectionController.possessionDate.value = item['inspectionDate'] ?? '';
      }

      if (item['tenantPhone'] != null && item['tenantPhone'].toString().isNotEmpty) {
        inspectionController.tenantPhone.value = item['tenantPhone'];
      }
      if (item['landlordPhone'] != null && item['landlordPhone'].toString().isNotEmpty) {
        inspectionController.landlordPhone.value = item['landlordPhone'];
      }

      Get.to(() => PropertyDetailsScreen(role: widget.role, userName: widget.userName));
    } catch (e) {
      debugPrint("Failed to load inspection for editing: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE74C3C),
          content: Text('Failed to load report data: $e'),
        ),
      );
    }
  }

  Future<void> _confirmDeleteHistoryItem(Map<String, dynamic> item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Report?',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C3E50),
          ),
        ),
        content: Text(
          'Are you sure you want to delete the inspection report for "${item['tenantName'] ?? item['landlordName'] ?? 'this property'}"?\nThis action cannot be undone.',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 14,
            color: Color(0xFF7F8C8D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Color(0xFF7F8C8D),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE74C3C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteHistoryItem(item);
    }
  }

  Future<void> _deleteHistoryItem(Map<String, dynamic> item) async {
    // Show a loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFE74C3C),
                ),
                SizedBox(height: 16),
                Text(
                  'Deleting report...',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                    fontSize: 14,
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
      final String id = item['_id'] ?? '';
      if (id.isEmpty) {
        throw Exception("Invalid report ID");
      }

      final response = await restClient.dio.delete('/pdf-history/$id');

      // Pop the loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        // Remove item from state locally
        setState(() {
          _historyItems.removeWhere((element) => element['_id'] == id);
        });

        // Update DashboardController's recent submissions if registered
        if (Get.isRegistered<DashboardController>()) {
          final dashboardController = Get.find<DashboardController>();
          dashboardController.recentSubmissions.removeWhere((element) => element['_id'] == id);
          dashboardController.fetchRecentSubmissions();
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Color(0xFF2ECC71),
              content: Text(
                'Report deleted successfully.',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
      } else {
        throw Exception(response.data?['message'] ?? 'Failed to delete report');
      }
    } catch (e) {
      // Pop the loading dialog
      if (mounted) {
        try {
          Navigator.pop(context);
        } catch (_) {}
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFFE74C3C),
            content: Text(
              'Failed to delete report: $e',
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    final normalized = status.toUpperCase().trim();
    if (normalized == 'VERIFIED') {
      return const Color(0xFF2ECC71); // Green
    } else if (normalized == 'PENDING SIGNATURE') {
      return const Color(0xFFF39C12); // Orange/Amber
    } else {
      return const Color(0xFF7F8C8D); // Grey for Completed Archive
    }
  }

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
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF007BFF),
            ),
            SizedBox(height: 16),
            Text(
              'Accessing secure archives...',
              style: TextStyle(
                color: Color(0xFF7F8C8D),
                fontFamily: 'Montserrat',
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE74C3C),
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontFamily: 'Montserrat',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _fetchHistory,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_historyItems.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchHistory,
        color: const Color(0xFF007BFF),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.25),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF2F4F7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Color(0xFF7F8C8D),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No saved reports yet',
                    style: TextStyle(
                      color: Color(0xFF2C3E50),
                      fontFamily: 'Montserrat',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.0),
                    child: Text(
                      'Any reports you download or share will be automatically saved in this secure archive.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8F9CA9),
                        fontFamily: 'Montserrat',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchHistory,
      color: const Color(0xFF007BFF),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        itemCount: _historyItems.length,
        separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 1),
        itemBuilder: (context, index) {
          final item = _historyItems[index];
          final String tenantVal = item['tenantName'] ?? '';
          final String landlordVal = item['landlordName'] ?? '';
          final String title = widget.role.toLowerCase() == 'landlord'
              ? (landlordVal.isNotEmpty && landlordVal != 'N/A' ? landlordVal : (item['title'] ?? 'Inspection Report'))
              : (tenantVal.isNotEmpty && tenantVal != 'N/A' ? tenantVal : (item['title'] ?? 'Inspection Report'));
          final String date = item['date'] ?? '';
          final String recordRole = (item['role'] ?? widget.role).toString().toLowerCase() == 'landlord' ? 'Landlord' : 'Tenant';
          final String status = item['status'] ?? 'VERIFIED';
          final Color statusColor = _getStatusColor(status);

          return _buildHistoryItem(
            context: context,
            title: title,
            date: '$date  •  $recordRole',
            status: status.toUpperCase(),
            statusColor: statusColor,
            onTap: () => _downloadAndOpenPdf(item),
            onEditTap: () => _editInspectionReport(item),
            onDeleteTap: () => _confirmDeleteHistoryItem(item),
          );
        },
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
    required VoidCallback onEditTap,
    required VoidCallback onDeleteTap,
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
                  color: statusColor.withValues(alpha: 0.08),
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
                  color: statusColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 0.8),
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
              GestureDetector(
                onTap: onEditTap,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF2F4F7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Color(0xFF7F8C8D),
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onDeleteTap,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDE8E8),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFE74C3C),
                    size: 16,
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
