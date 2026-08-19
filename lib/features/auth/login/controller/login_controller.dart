// Dio is used for making HTTP API requests.
import 'package:dio/dio.dart';

// Flutter Material provides TextEditingController.
import 'package:flutter/material.dart';

// GetX provides reactive variables such as .obs, RxStatus and validation utilities.
import 'package:get/get.dart';

// GetStorage is used to save user information locally on the device.
import 'package:get_storage/get_storage.dart';

// BaseController provides shared values such as isLoading,
// restClient, email, name, phone, idCode and userId.
import 'package:tenantsnap/core/controllers/base_controller.dart';

// Contains LoginRequest and LoginResponse models.
import 'package:tenantsnap/features/auth/login/model/login_model.dart';

class LoginController extends BaseController {
  // Controls whether the password is hidden.
  // true means the password is hidden.
  final obscurePassword = true.obs;

  // Stores the validation error shown below the email field.
  // RxnString allows the value to be either String or null.
  final emailError = RxnString();

  // Stores the validation error shown below the password field.
  final passwordError = RxnString();

  // Stores the current login API state:
  // empty, loading, success or error.
  final Rx<RxStatus> loginStatus = RxStatus.empty().obs;

  // Controls and reads the value entered in the email field.
  final TextEditingController emailController = TextEditingController();

  // Controls and reads the value entered in the password field.
  final TextEditingController passwordController = TextEditingController();

  // ------------------------------------------------------------
  // SHOW OR HIDE PASSWORD
  // ------------------------------------------------------------

  void toggleObscurePassword() {
    // Changes true to false or false to true.
    // The UI updates automatically because it is an observable value.
    obscurePassword.value = !obscurePassword.value;
  }

  // ------------------------------------------------------------
  // VALIDATE LOGIN INPUTS
  // ------------------------------------------------------------

  bool validateInputs() {
    // Remove old validation messages before validating again.
    emailError.value = null;
    passwordError.value = null;

    // Read and clean the email entered by the user.
    final String emailInput = emailController.text.trim();

    // Read the password.
    // trim() removes spaces from the beginning and end.
    final String password = passwordController.text.trim();

    // Assume that the form is valid initially.
    bool isValid = true;

    // Check whether the email field is empty.
    if (emailInput.isEmpty) {
      emailError.value = 'Email is required';
      isValid = false;
    }
    // Check whether the email has a valid email format.
    else if (!GetUtils.isEmail(emailInput)) {
      emailError.value = 'Enter valid email';
      isValid = false;
    }

    // Check whether the password field is empty.
    if (password.isEmpty) {
      passwordError.value = 'Password is required';
      isValid = false;
    }
    // Check whether the password contains at least 6 characters.
    else if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters';
      isValid = false;
    }

    // Returns true if there are no validation errors.
    return isValid;
  }

  // ------------------------------------------------------------
  // USER LOGIN
  // ------------------------------------------------------------

  Future<String?> login() async {
    // Clear previous validation errors.
    emailError.value = null;
    passwordError.value = null;

    // Read email and password from the text fields.
    final String emailInput = emailController.text.trim();
    final String password = passwordController.text.trim();

    // Stop the login process if validation fails.
    if (!validateInputs()) {
      return 'Please fix the errors and try again.';
    }

    // Start the loading indicator.
    isLoading.value = true;

    // Tell the UI that the login request is currently running.
    loginStatus.value = RxStatus.loading();

    try {
      // Create the login request model.
      final LoginRequest request = LoginRequest(
        email: emailInput,
        password: password,
      );

      // Call the login API.
      //
      // The body will normally look like:
      // {
      //   "email": "user@example.com",
      //   "password": "123456"
      // }
      final response = await restClient.dio.post(
        '/users/login',
        data: request.toJson(),
      );

      // Check whether the API returned a successful response.
      if (response.statusCode == 200 && response.data != null) {
        // Convert the JSON response into a LoginResponse object.
        final LoginResponse loginRes =
        LoginResponse.fromJson(response.data);

        // A valid token means that login was successful.
        if (loginRes.token != null && loginRes.token!.isNotEmpty) {
          // Store email in the shared BaseController.
          // If the API does not return email, use the entered email.
          BaseController.email.value =
              (loginRes.email ?? emailInput).trim();

          // Combine the first name and last name.
          BaseController.name.value =
              '${loginRes.firstName ?? ''} '
                  '${loginRes.lastName ?? ''}'
                  .trim();

          // Store the remaining user details.
          BaseController.phone.value = loginRes.phone ?? '';
          BaseController.idCode.value = loginRes.idCode ?? '';
          BaseController.userId.value = loginRes.userId ?? 0;

          // Open the local device storage.
          final GetStorage box = GetStorage();

          // Remember that the user is logged in.
          await box.write('isLoggedIn', true);

          // Store the time at which the user logged in.
          await box.write(
            'loginTime',
            DateTime.now().millisecondsSinceEpoch,
          );

          // Determine the user role using idCode.
          //
          // If the ID starts with "ll" or "LL", the user is a landlord.
          // Otherwise, the user is treated as a tenant.
          final String computedRole =
          BaseController.idCode.value.toLowerCase().startsWith('ll')
              ? 'landlord'
              : 'tenant';

          // Save the role and user information locally.
          await box.write('role', computedRole);
          await box.write('userName', BaseController.name.value);
          await box.write('email', BaseController.email.value);
          await box.write('phone', BaseController.phone.value);
          await box.write('idCode', BaseController.idCode.value);
          await box.write('userId', BaseController.userId.value);

          // Tell the UI that login was successful.
          loginStatus.value = RxStatus.success();

          // Returning null means there is no error.
          return null;
        }

        // The API returned 200, but a valid token was not received.
        loginStatus.value = RxStatus.error();

        // Return the API error if available.
        return loginRes.error ?? 'Login failed. Please try again.';
      }

      // Handle unexpected API status codes.
      loginStatus.value = RxStatus.error();
      return 'Login failed. Please try again.';
    } on DioException catch (dioError) {
      // This block handles errors returned by Dio,
      // such as 400, 401, 404, 500 and network failures.
      loginStatus.value = RxStatus.error();

      // Get the response body returned by the backend.
      final dynamic data = dioError.response?.data;

      // Return the backend "message" value when available.
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      // Return the backend "error" value when available.
      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }

      // Default message when the backend provides no useful error.
      return 'Incorrect credentials. Please try again.';
    } catch (error) {
      // Handles unexpected errors that are not Dio errors.
      loginStatus.value = RxStatus.error();
      return 'Connection error. Please try again.';
    } finally {
      // This always runs after success or failure.
      // It stops the loading indicator.
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // SEND FORGOT-PASSWORD OTP
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> sendOtp(String emailInput) async {
    // Clean the entered email.
    final String email = emailInput.trim();

    // Check whether an email was entered.
    if (email.isEmpty) {
      return {
        'success': false,
        'message': 'Email is required',
      };
    }

    // Validate the email format.
    if (!GetUtils.isEmail(email)) {
      return {
        'success': false,
        'message': 'Enter a valid email',
      };
    }

    // Start the loading indicator.
    isLoading.value = true;

    try {
      // Request a password-reset OTP from the backend.
      final response = await restClient.dio.post(
        '/users/forgot-password',
        data: {
          'email': email,
        },
      );

      // Check whether the OTP request was successful.
      if (response.statusCode == 200) {
        final dynamic data = response.data;

        // Return the result to the UI.
        return {
          'success': true,

          // This receives OTP only if the backend returns it.
          'otp': data is Map ? data['otp']?.toString() : null,

          // Use the backend message when available.
          'message': data is Map
              ? data['message']?.toString() ??
              'OTP generated successfully'
              : 'OTP generated successfully',
        };
      }

      // Handle unexpected status codes.
      return {
        'success': false,
        'message': 'Failed to send OTP.',
      };
    } on DioException catch (dioError) {
      // Read the error response returned by the backend.
      final dynamic data = dioError.response?.data;

      // Return the backend error message when available.
      if (data is Map && data['message'] != null) {
        return {
          'success': false,
          'message': data['message'].toString(),
        };
      }

      return {
        'success': false,
        'message': 'Incorrect email or network error.',
      };
    } catch (error) {
      // Handle any unexpected exception.
      return {
        'success': false,
        'message': 'Connection error. Please try again.',
      };
    } finally {
      // Stop loading whether the request succeeds or fails.
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // RESET PASSWORD
  // ------------------------------------------------------------

  Future<String?> resetPassword(
      String email,
      String otp,
      String newPassword,
      String confirmPassword,
      ) async {
    // Remove extra spaces from email and OTP.
    final String cleanEmail = email.trim();
    final String cleanOtp = otp.trim();

    // Make sure all required values are entered.
    if (cleanEmail.isEmpty ||
        cleanOtp.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      return 'All fields are required';
    }

    // Validate the email format.
    if (!GetUtils.isEmail(cleanEmail)) {
      return 'Enter a valid email';
    }

    // Require at least 6 characters for the new password.
    if (newPassword.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check whether both entered passwords are identical.
    if (newPassword != confirmPassword) {
      return 'Passwords do not match';
    }

    // Start the loading indicator.
    isLoading.value = true;

    try {
      // Send the password-reset request to the backend.
      final response = await restClient.dio.post(
        '/users/reset-password',
        data: {
          'email': cleanEmail,
          'otp': cleanOtp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      // Password reset was successful.
      if (response.statusCode == 200) {
        // null means that there is no error.
        return null;
      }

      return 'Reset failed. Please try again.';
    } on DioException catch (dioError) {
      // Read the backend error response.
      final dynamic data = dioError.response?.data;

      // Return the backend message when available.
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      return 'Failed to reset password. Please check your OTP.';
    } catch (error) {
      // Handle unexpected errors.
      return 'Connection error. Please try again.';
    } finally {
      // Stop the loading indicator.
      isLoading.value = false;
    }
  }

  // ------------------------------------------------------------
  // CLEAR LOGIN FORM
  // ------------------------------------------------------------

  void clearLoginFields() {
    // Remove text from the email and password fields.
    emailController.clear();
    passwordController.clear();

    // Clear validation errors.
    emailError.value = null;
    passwordError.value = null;

    // Hide the password again.
    obscurePassword.value = true;

    // Reset the login status.
    loginStatus.value = RxStatus.empty();
  }

  // ------------------------------------------------------------
  // CONTROLLER CLEANUP
  // ------------------------------------------------------------

  @override
  void onClose() {
    // Dispose the text controllers to prevent memory leaks.
    emailController.dispose();
    passwordController.dispose();

    // Run BaseController/GetX cleanup.
    super.onClose();
  }
}