import 'package:get/get.dart';
import 'package:tenantsnap/core/services/rest_client.dart';

class BaseController extends GetxController {
  late RestClient restClient;
  final isLoading = false.obs;

  // Global profile details stored statically
  static final name = ''.obs;
  static final email = ''.obs;
  static final phone = ''.obs;
  static final idCode = ''.obs;
  static final userId = 0.obs;

  @override
  void onInit() {
    super.onInit();
    restClient = Get.find<RestClient>();
  }

}
