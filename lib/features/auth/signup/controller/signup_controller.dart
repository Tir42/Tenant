import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/signup/model/signup_model.dart';

class SignUpController extends BaseController {
  final obscurePassword = true.obs;

  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController idCodeController = TextEditingController();

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<bool> signUp() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final idCode = idCodeController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        idCode.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      return false;
    }
    if (password != confirmPassword) {
      return false;
    }
    isLoading.value = true;

    try {
      final request = SignupRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        fullPhoneNumber: phone,
        password: password,
        idCode: idCode,
      );
      final response = await restClient.dio.post('/users/register', data: request.toJson());
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final signupRes = SignupResponse.fromJson(response.data);
        BaseController.name.value = '${signupRes.firstName ?? firstName} ${signupRes.lastName ?? lastName}'.trim();
        BaseController.email.value = (signupRes.email ?? email).trim();
        BaseController.phone.value = (signupRes.phone ?? phone).trim();
        BaseController.idCode.value = signupRes.idCode ?? idCode;
        print("Signup success response: idCode = ${signupRes.idCode}");
        isLoading.value = false;
        return true;
      }
    } catch (e) {
      isLoading.value = false;
      return false;
    }

    isLoading.value = false;
    return false;
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    idCodeController.dispose();
    super.dispose();
  }
}
