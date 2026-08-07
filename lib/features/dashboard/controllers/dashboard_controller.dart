import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/core/services/rest_client.dart';

class DashboardController extends GetxController {
  final activeRole = 'tenant'.obs;
  final userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    if (BaseController.name.value.isNotEmpty) {
      userName.value = BaseController.name.value;
    }
    fetchRecentSubmissions();
  }
  
  final currentCarouselPage = 0.obs;
  final currentSubsPage = 0.obs;

  // Interactive dashboard metrics
  final activeInspectionsProgress = 85.obs;
  final historyReportsProgress = 100.obs;
  final profileSupportProgress = 95.obs;

  final carouselItems = <Map<String, String>>[
    {
      'title': 'Condition Snapshots',
      'description': 'Capture every defect with timestamped, geo-tagged photos.',
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
  ].obs;

  final tenantPlans = <Map<String, String>>[
    {
      'title': 'Tenant Basic',
      'price': 'Free',
      'description': '1 active property checklist, standard PDF report exports, local storage only.',
      'icon': 'verified_user',
    },
    {
      'title': 'Tenant Premium',
      'price': r'$2.99/mo',
      'description': 'Unlimited properties, secure cloud sync, HD photo attachments, digital sign-offs.',
      'icon': 'cloud_upload',
    },
    {
      'title': 'Tenant Expert',
      'price': r'$4.99/mo',
      'description': 'Premium cloud sync, live support, expert inspection guidelines, checklist customization.',
      'icon': 'star',
    },
  ].obs;

  final landlordPlans = <Map<String, String>>[
    {
      'title': 'Landlord Starter',
      'price': r'$9.99/mo',
      'description': 'Manage up to 3 properties, automated checklist invites, standard audit logs.',
      'icon': 'home',
    },
    {
      'title': 'Landlord Professional',
      'price': r'$29.99/mo',
      'description': 'Manage up to 15 properties, co-signed inspection reports, advanced telemetry dashboard.',
      'icon': 'business',
    },
    {
      'title': 'Landlord Enterprise',
      'price': r'$79.99/mo',
      'description': 'Unlimited properties, custom branded report PDFs, multi-admin settings, API access.',
      'icon': 'domain',
    },
  ].obs;

  final recentSubmissions = <dynamic>[].obs;
  final isLoadingSubmissions = false.obs;

  Future<void> fetchRecentSubmissions() async {
    try {
      isLoadingSubmissions.value = true;
      final restClient = Get.find<RestClient>();
      final box = GetStorage();
      final userId = box.read('userId') ?? 0;

      final Map<String, dynamic> queryParams = {
        'userName': BaseController.name.value.isNotEmpty ? BaseController.name.value : (activeRole.value == 'tenant' ? 'Tenant' : 'Landlord'),
        'role': activeRole.value,
      };
      if (userId > 0) {
        queryParams['userId'] = userId;
      }

      final response = await restClient.dio.get(
        '/pdf-history',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null && response.data['success'] == true) {
        final List allData = response.data['data'] ?? [];
        recentSubmissions.assignAll(allData.take(3).toList());
      }
    } catch (e) {
      Get.log("Failed to fetch recent submissions: $e");
    } finally {
      isLoadingSubmissions.value = false;
    }
  }

  void toggleRole(String role) {
    activeRole.value = role;
    userName.value = BaseController.name.value.isNotEmpty ? BaseController.name.value : (role == 'tenant' ? 'Tenant' : 'Landlord');
    fetchRecentSubmissions();
  }

  void updateUserName(String newName) {
    if (newName.isNotEmpty) {
      userName.value = newName;
    }
  }
}
