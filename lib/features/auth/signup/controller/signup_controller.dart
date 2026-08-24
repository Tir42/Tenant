import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:country_picker/country_picker.dart';
import 'package:dio/dio.dart';

import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/signup/model/signup_model.dart';

class SignUpController extends BaseController {
  final obscurePassword = true.obs;
  final signupStatus = RxStatus.empty().obs;

  final firstNameError = RxnString();
  final lastNameError = RxnString();
  final emailError = RxnString();
  final phoneError = RxnString();
  final idCodeError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();

  final emailText = ''.obs;
  final phoneText = ''.obs;
  final idCodeText = ''.obs;

  Worker? emailWorker;
  Worker? phoneWorker;
  Worker? idCodeWorker;

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  //final idCodeController = TextEditingController();

  final selectedCountry = Rx<Country>(
    CountryService().findByCode('US') ??
        Country(
          phoneCode: '1',
          countryCode: 'US',
          e164Sc: 1,
          geographic: true,
          level: 1,
          name: 'United States',
          example: '2015550123',
          displayName: 'United States (US) [+1]',
          displayNameNoCountryCode: 'United States (US)',
          e164Key: '1-US-0',
        ),
  );

  @override
  void onInit() {
    super.onInit();

    emailWorker = debounce<String>(
      emailText,
          (value) async {
        final email = value.trim();

        if (email.isEmpty) {
          emailError.value = null;
          return;
        }

        if (!GetUtils.isEmail(email)) {
          emailError.value = 'Please enter a valid email address.';
          return;
        }

        final exists = await checkEmailExists(email);
        emailError.value = exists ? 'Email already exists.' : null;
      },
      time: const Duration(milliseconds: 600),
    );

    phoneWorker = debounce<String>(
      phoneText,
          (value) async {
        final phone = value.trim();

        if (phone.isEmpty) {
          phoneError.value = null;
          return;
        }

        final error = validatePhoneNumberValue(phone);
        if (error != null) {
          phoneError.value = error;
          return;
        }

        final exists = await checkPhoneExists(phone);
        phoneError.value = exists ? 'Phone number already exists.' : null;
      },
      time: const Duration(milliseconds: 600),
    );

    idCodeWorker = debounce<String>(
      idCodeText,
          (value) async {
        final idCode = value.trim();

        if (idCode.isEmpty) {
          idCodeError.value = null;
          return;
        }

        final exists = await checkIdCodeExists(idCode);
        idCodeError.value = exists ? 'ID Code already exists.' : null;
      },
      time: const Duration(milliseconds: 600),
    );

    ever(selectedCountry, (_) {
      phoneText.value = phoneController.text;
    });
  }

  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  bool validateInputs() {
    firstNameError.value = null;
    lastNameError.value = null;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
 
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    bool isValid = true;

    if (firstName.isEmpty) {
      firstNameError.value = 'First name is required.';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(firstName)) {
      firstNameError.value = 'First name must contain letters only.';
      isValid = false;
    }

    if (lastName.isEmpty) {
      lastNameError.value = 'Last name is required.';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(lastName)) {
      lastNameError.value = 'Last name must contain letters only.';
      isValid = false;
    }

    if (email.isEmpty) {
      emailError.value = 'Email is required.';
      isValid = false;
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter a valid email address.';
      isValid = false;
    } else if (emailError.value == 'Email already exists.') {
      isValid = false;
    }

    if (phone.isEmpty) {
      phoneError.value = 'Phone number is required.';
      isValid = false;
    } else {
      final error = validatePhoneNumberValue(phone);
      if (error != null) {
        phoneError.value = error;
        isValid = false;
      } else if (phoneError.value == 'Phone number already exists.') {
        isValid = false;
      }
    }

  

    if (password.isEmpty) {
      passwordError.value = 'Password is required.';
      isValid = false;
    } else if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters.';
      isValid = false;
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      passwordError.value = 'Password must contain at least one number.';
      isValid = false;
    } else {
      passwordError.value = null;
    }

    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password.';
      isValid = false;
    } else if (password != confirmPassword) {
      confirmPasswordError.value = 'Passwords do not match.';
      isValid = false;
    } else {
      confirmPasswordError.value = null;
    }

    return isValid;
  }

  Future<String?> signUp() async {
    if (!validateInputs()) {
      return 'Please fix the errors and try again.';
    }

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    //final idCode = idCodeController.text.trim();

    isLoading.value = true;
    signupStatus.value = RxStatus.loading();

    try {
      if (await checkEmailExists(email)) {
        emailError.value = 'Email already exists.';
        signupStatus.value = RxStatus.error();
        return 'Email already exists.';
      }

      if (await checkPhoneExists(phone)) {
        phoneError.value = 'Phone number already exists.';
        signupStatus.value = RxStatus.error();
        return 'Phone number already exists.';
      }

      /*if (await checkIdCodeExists(idCode)) {
        idCodeError.value = 'ID Code already exists.';
        signupStatus.value = RxStatus.error();
        return 'ID Code already exists.';
      }*/

      final request = SignupRequest(
        firstName: firstName,
        lastName: lastName,
        email: email,
        fullPhoneNumber: phone,
        password: password,
        //idCode: idCode,
      );

      final response = await restClient.dio.post(
        '/users/register',
        data: request.toJson(),
        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          response.data != null) {
        final signupRes = SignupResponse.fromJson(response.data);

        BaseController.name.value =
            '${signupRes.firstName ?? firstName} ${signupRes.lastName ?? lastName}'.trim();
        BaseController.email.value = (signupRes.email ?? email).trim();
        BaseController.phone.value = (signupRes.phone ?? phone).trim();
        BaseController.userId.value = signupRes.id ?? 0;

        final box = GetStorage();
        box.write('userId', BaseController.userId.value);

        signupStatus.value = RxStatus.success();
        return null;
      }

      signupStatus.value = RxStatus.error();
      return response.data is Map && response.data['message'] != null
          ? response.data['message'].toString()
          : 'Signup failed. Please try again.';
    } on DioException catch (e) {
      signupStatus.value = RxStatus.error();

      final data = e.response?.data;

      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }

      if (data is Map && data['error'] != null) {
        return data['error'].toString();
      }

      return 'Connection error. Please try again.';
    } catch (_) {
      signupStatus.value = RxStatus.error();
      return 'Connection error. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> checkEmailExists(String email) async {
    try {
      final response = await restClient.dio.get(
        '/users/check-email',
        queryParameters: {'email': email},
      );
      return response.data is Map && response.data['exists'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkPhoneExists(String phone) async {
    try {
      final response = await restClient.dio.get(
        '/users/check-phone',
        queryParameters: {'phone': phone},
      );
      return response.data is Map && response.data['exists'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> checkIdCodeExists(String idCode) async {
    try {
      final response = await restClient.dio.get(
        '/users/check-idcode',
        queryParameters: {'idCode': idCode},
      );
      return response.data is Map && response.data['exists'] == true;
    } catch (_) {
      return false;
    }
  }

  List<int> getValidPhoneLengths(String countryCode, String phoneCode, String example) {
    final upperCountryCode = countryCode.toUpperCase();
    
    switch (upperCountryCode) {
      case 'IN': // India
        return [10];
      case 'US': // USA
      case 'CA': // Canada
        return [10];
      case 'GB': // UK
        return [10];
      case 'AU': // Australia
        return [9];
      case 'SG': // Singapore
        return [8];
      case 'AE': // UAE
        return [9];
      case 'MY': // Malaysia
        return [9, 10];
      case 'NZ': // New Zealand
        return [8, 9, 10];
      case 'DE': // Germany
        return [10, 11];
      case 'FR': // France
        return [9];
      case 'PK': // Pakistan
        return [10];
      case 'BD': // Bangladesh
        return [10];
      case 'ZA': // South Africa
        return [9];
      case 'SA': // Saudi Arabia
        return [9];
    }
    
    if (example.isNotEmpty) {
      final cleanExample = example.replaceAll(RegExp(r'[^0-9]'), '');
      if (cleanExample.isNotEmpty) {
        return [cleanExample.length];
      }
    }
    
    return [8, 9, 10, 11, 12];
  }

  String? validatePhoneNumberValue(String phone) {
    if (phone.isEmpty) {
      return null;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      return 'Phone number must contain digits only.';
    }

    final country = selectedCountry.value;
    final allowedLengths = getValidPhoneLengths(country.countryCode, country.phoneCode, country.example);

    if (!allowedLengths.contains(phone.length)) {
      if (allowedLengths.length == 1) {
        return 'Phone number must be ${allowedLengths.first} digits for ${country.name}.';
      } else {
        return 'Phone number must be ${allowedLengths.join(' or ')} digits for ${country.name}.';
      }
    }

    return null;
  }

  void clearFirstNameError() => firstNameError.value = null;
  void clearLastNameError() => lastNameError.value = null;
  void clearEmailError() => emailError.value = null;
  void clearPhoneError() => phoneError.value = null;
  void clearIdCodeError() => idCodeError.value = null;
  void clearPasswordError() => passwordError.value = null;
  void clearConfirmPasswordError() => confirmPasswordError.value = null;

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    //idCodeController.dispose();

    emailWorker?.dispose();
    phoneWorker?.dispose();
    idCodeWorker?.dispose();

    super.onClose();
  }
}