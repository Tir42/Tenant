import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/login/model/login_model.dart';

class LoginController extends BaseController {
  final obscurePassword = true.obs;
  final emailError = RxnString();
  final passwordError = RxnString();
  Rx<RxStatus> loginStatus = RxStatus.empty().obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  bool validateInputs() {
    emailError.value = null;
    passwordError.value = null;

    final emailInput = emailController.text.trim();
    final password = passwordController.text.trim();

    bool isValid = true;

    if (emailInput.isEmpty) {
      emailError.value = 'Email is required';
      isValid = false;
    } else if (!GetUtils.isEmail(emailInput)) {
      emailError.value = 'Enter valid email';
      isValid = false;
    }

    if (password.isEmpty) {
      passwordError.value = 'Password is required';
      isValid = false;
    } else if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      isValid = false;
    }

    return isValid;
  }

  Future<String?> login() async {
    emailError.value = null;
    passwordError.value = null;

    final emailInput = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!validateInputs()) {
      return 'Please fix the errors and try again.';
    }

    isLoading.value = true;
    loginStatus.value = RxStatus.loading();

    try {
      final request = LoginRequest(
        email: emailInput,
        password: password,
      );

      final response = await restClient.dio.post(
        '/users/login',
        data: request.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        final loginRes = LoginResponse.fromJson(response.data);

        if (loginRes.token != null && loginRes.token!.isNotEmpty) {
          BaseController.email.value = (loginRes.email ?? emailInput).trim();

          BaseController.name.value =
              '${loginRes.firstName ?? ''} ${loginRes.lastName ?? ''}'.trim();

          BaseController.phone.value = loginRes.phone ?? '';
          BaseController.idCode.value = loginRes.idCode ?? '';

          final box = GetStorage();

          box.write('isLoggedIn', true);
          box.write('loginTime', DateTime.now().millisecondsSinceEpoch);
          box.write('role', 'tenant');
          box.write('userName', BaseController.name.value);
          box.write('email', BaseController.email.value);
          box.write('phone', BaseController.phone.value);
          box.write('idCode', BaseController.idCode.value);

          loginStatus.value = RxStatus.success();
          return null;
        }

        loginStatus.value = RxStatus.error();

        return loginRes.error ?? 'Login failed. Please try again.';
      }

      loginStatus.value = RxStatus.error();
      return 'Login failed. Please try again.';
    } on DioException catch (dioError) {
      loginStatus.value = RxStatus.error();

      final data = dioError.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }

      return 'Incorrect credentials. Please try again.';
    } catch (e) {
      loginStatus.value = RxStatus.error();
      return 'Connection error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }



  Future<Map<String, dynamic>> sendOtp(String emailInput) async {
    if (emailInput.trim().isEmpty) {
      return {'success': false, 'message': 'Email is required'};
    }
    isLoading.value = true;
    try {
      final response = await restClient.dio.post(
        '/users/forgot-password',
        data: {'email': emailInput.trim()},
      );
      isLoading.value = false;
      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': true,
          'otp': data['otp']?.toString(),
          'message': data['message']?.toString() ?? 'OTP generated successfully',
        };
      }
    } on DioException catch (dioError) {
      isLoading.value = false;
      if (dioError.response != null && dioError.response?.data != null) {
        final data = dioError.response?.data;
        if (data is Map && data.containsKey('message')) {
          return {'success': false, 'message': data['message'].toString()};
        }
      }
      return {'success': false, 'message': 'Incorrect email or network error.'};
    } catch (e) {
      isLoading.value = false;
      return {'success': false, 'message': 'Connection error. Please try again.'};
    }
    isLoading.value = false;
    return {'success': false, 'message': 'Failed to send OTP.'};
  }

  Future<String?> resetPassword(
    String email,
    String otp,
    String newPassword,
    String confirmPassword,
  ) async {
    if (email.trim().isEmpty || otp.trim().isEmpty || newPassword.isEmpty || confirmPassword.isEmpty) {
      return 'All fields are required';
    }
    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }
    isLoading.value = true;
    try {
      final response = await restClient.dio.post(
        '/users/reset-password',
        data: {
          'email': email.trim(),
          'otp': otp.trim(),
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );
      isLoading.value = false;
      if (response.statusCode == 200) {
        return null; // success
      }
    } on DioException catch (dioError) {
      isLoading.value = false;
      if (dioError.response != null && dioError.response?.data != null) {
        final data = dioError.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      return 'Failed to reset password. Please check your OTP.';
    } catch (e) {
      isLoading.value = false;
      return 'Connection error. Please try again.';
    }
    isLoading.value = false;
    return 'Reset failed. Please try again.';
  }
  void clearLoginFields() {
    emailController.clear();
    passwordController.clear();

    emailError.value = null;
    passwordError.value = null;
    obscurePassword.value = true;
  }
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
