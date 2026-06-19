import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:country_picker/country_picker.dart';
import 'package:tenantsnap/core/controllers/base_controller.dart';
import 'package:tenantsnap/features/auth/signup/model/signup_model.dart';

class SignUpController extends BaseController {
  final obscurePassword = true.obs;

  final firstNameError = RxnString();
  final lastNameError = RxnString();
  final emailError = RxnString();
  final phoneError = RxnString();
  final idCodeError = RxnString();
  final passwordError = RxnString();
  final confirmPasswordError = RxnString();

  final selectedCountry = Rx<Country>(
    CountryService().findByCode('US') ?? Country(
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

  bool validateInputs() {
    firstNameError.value = null;
    lastNameError.value = null;
    emailError.value = null;
    phoneError.value = null;
    idCodeError.value = null;
    passwordError.value = null;
    confirmPasswordError.value = null;

    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;
    final idCode = idCodeController.text.trim();

    bool isValid = true;

    // 1. First Name Validation
    if (firstName.isEmpty) {
      firstNameError.value = 'First name is required.';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(firstName)) {
      firstNameError.value = 'First name must contain letters only.';
      isValid = false;
    }

    // 2. Last Name Validation
    if (lastName.isEmpty) {
      lastNameError.value = 'Last name is required.';
      isValid = false;
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(lastName)) {
      lastNameError.value = 'Last name must contain letters only.';
      isValid = false;
    }

    // 3. Email Validation
    if (email.isEmpty) {
      emailError.value = 'Email is required.';
      isValid = false;
    } else if (!GetUtils.isEmail(email)) {
      emailError.value = 'Please enter a valid email address.';
      isValid = false;
    }

    // 4. Phone Validation
    if (phone.isEmpty) {
      phoneError.value = 'Phone number is required.';
      isValid = false;
    } else if (!RegExp(r'^[0-9]+$').hasMatch(phone)) {
      phoneError.value = 'Phone number must contain digits only.';
      isValid = false;
    } else if (phone.length < 8 || phone.length > 15) {
      phoneError.value = 'Enter a valid phone number (8-15 digits).';
      isValid = false;
    }

    // 5. Tenant ID Code Validation
    if (idCode.isEmpty) {
      idCodeError.value = 'Tenant ID Code is required.';
      isValid = false;
    }

    // 6. Password Validation
    if (password.isEmpty) {
      passwordError.value = 'Password is required.';
      isValid = false;
    } else if (password.length < 6) {
      passwordError.value = 'Password must be at least 6 characters.';
      isValid = false;
    } else if (!RegExp(r'[0-9]').hasMatch(password)) {
      passwordError.value = 'Password must contain at least one number.';
      isValid = false;
    }

    // 7. Confirm Password Validation
    if (confirmPassword.isEmpty) {
      confirmPasswordError.value = 'Please confirm your password.';
      isValid = false;
    } else if (password != confirmPassword) {
      confirmPasswordError.value = 'Passwords do not match.';
      isValid = false;
    }

    return isValid;
  }

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
        debugPrint("Signup success response: idCode = ${signupRes.idCode}");
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
