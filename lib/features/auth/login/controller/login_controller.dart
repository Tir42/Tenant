import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/login/model/login_model.dart';

class LoginController extends BaseController {
  final obscurePassword = true.obs;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
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

  Future<bool> sendPasswordResetEmail(String emailInput) async {
    if (emailInput.trim().isEmpty) {
      return false;
    }
    isLoading.value = true;
    try {
      await restClient.dio.post('/users', data: {'email': emailInput.trim()});
    } catch (e) {
      // Ignore exception for reset flow continuity
    }
    isLoading.value = false;
    return true;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
