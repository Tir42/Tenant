import 'package:get/get.dart';

class AuthController extends GetxController {
  final obscurePassword = true.obs;
  final isLoading = false.obs;

  // Stored login/signup profile details
  final name = 'Liam Carter'.obs;
  final email = 'Liam.Carter@snapnode.io'.obs;
  final phone = '+1 (555) 012-3456'.obs;
  final idCode = 'TS-402-URBL'.obs;

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<bool> login(String emailInput, String password) async {
    if (emailInput.trim().isEmpty || password.isEmpty) {
      return false;
    }
    isLoading.value = true;
    // Simulate API validation / credentials decryption delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Store credentials for data continuity
    email.value = emailInput.trim();
    if (emailInput.toLowerCase().contains('sterling') || emailInput.toLowerCase().contains('landlord')) {
      name.value = 'Victoria Sterling';
      phone.value = '+1 (555) 019-2834';
      idCode.value = 'LL-9821-VS';
    } else {
      name.value = 'Liam Carter';
      phone.value = '+1 (555) 012-3456';
      idCode.value = 'TS-402-URBL';
    }

    isLoading.value = false;
    return true;
  }

  Future<bool> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String idCode,
  }) async {
    if (firstName.trim().isEmpty ||
        lastName.trim().isEmpty ||
        email.trim().isEmpty ||
        phone.trim().isEmpty ||
        idCode.trim().isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return false;
    }
    if (password != confirmPassword) {
      return false;
    }
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    // Store credentials for data continuity
    this.name.value = '$firstName $lastName';
    this.email.value = email.trim();
    this.phone.value = phone.trim();
    this.idCode.value = idCode.trim();

    isLoading.value = false;
    return true;
  }
}
