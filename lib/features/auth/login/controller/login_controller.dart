import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/login/model/login_model.dart';

class LoginController extends BaseController {
  final obscurePassword = true.obs;
  final emailError = RxnString();
  final passwordError = RxnString();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  bool validateInputs() {
    emailError.value = null;
    passwordError.value = null;

    final emailInput = emailController.text.trim();
    final password = passwordController.text;

    bool isValid = true;

    if (emailInput.isEmpty) {
      emailError.value = 'Email is required.';
      isValid = false;
    } else if (!GetUtils.isEmail(emailInput)) {
      emailError.value = 'Please enter a valid email address.';
      isValid = false;
    }

    if (password.isEmpty) {
      passwordError.value = 'Password is required.';
      isValid = false;
    } else if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters.';
      isValid = false;
    }

    return isValid;
  }

  Future<String?> login() async {
    final emailInput = emailController.text.trim();
    final password = passwordController.text;

    if (emailInput.isEmpty || password.isEmpty) {
      return "Email and password are required";
    }
    isLoading.value = true;
    
    try {
      final request = LoginRequest(email: emailInput, password: password);
      final response = await restClient.dio.post('/users/login', data: request.toJson());
      
      if (response.statusCode == 200) {
        final loginRes = LoginResponse.fromJson(response.data);
        if (loginRes.token != null) {
          BaseController.email.value = (loginRes.email ?? emailInput).trim();
          BaseController.name.value = '${loginRes.firstName ?? ''} ${loginRes.lastName ?? ''}'.trim();
          BaseController.phone.value = loginRes.phone ?? '';
          BaseController.idCode.value = loginRes.idCode ?? '';
          isLoading.value = false;
          return null;
        }
      }
    } on DioException catch (dioError) {
      isLoading.value = false;
      if (dioError.response != null && dioError.response?.data != null) {
        final data = dioError.response?.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      return "Incorrect credentials. Please try again.";
    } catch (e) {
      isLoading.value = false;
      return "Connection error. Please try again.";
    }
    
    isLoading.value = false;
    return "Login failed. Please try again.";
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

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
