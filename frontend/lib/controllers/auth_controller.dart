import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import 'session_controller.dart';

class AuthController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;
  final rememberMe = true.obs;
  final acceptTerms = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? !rememberMe.value;
  }

  void toggleAcceptTerms(bool? value) {
    acceptTerms.value = value ?? !acceptTerms.value;
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty) {
      _showValidationMessage('Email address is required.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showValidationMessage('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showValidationMessage('Password is required.');
      return;
    }

    if (password.length < 6) {
      _showValidationMessage('Password must contain at least 6 characters.');
      return;
    }

    if (!acceptTerms.value) {
      _showValidationMessage('Please accept the terms and privacy policy.');
      return;
    }

    try {
      isLoading.value = true;

      // TODO: Connect this login flow to the Spring Boot REST API later.
      // The service layer will call the backend, validate the response,
      // store the auth token if required, and then navigate on success.
      await Future<void>.delayed(const Duration(milliseconds: 300));

      Get.find<SessionController>().setMockUser(email: email);
      Get.offAllNamed(AppRoutes.dashboard);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty) {
      _showValidationMessage('Full name is required.');
      return;
    }

    if (email.isEmpty) {
      _showValidationMessage('Email address is required.');
      return;
    }

    if (!GetUtils.isEmail(email)) {
      _showValidationMessage('Please enter a valid email address.');
      return;
    }

    if (password.isEmpty) {
      _showValidationMessage('Password is required.');
      return;
    }

    if (password.length < 6) {
      _showValidationMessage('Password must contain at least 6 characters.');
      return;
    }

    if (confirmPassword != password) {
      _showValidationMessage('Passwords do not match.');
      return;
    }

    try {
      isLoading.value = true;

      // TODO: Connect this registration flow to the Spring Boot REST API later.
      await Future<void>.delayed(const Duration(milliseconds: 300));

      Get.find<SessionController>().setMockUser(name: name, email: email);
      Get.offAllNamed(AppRoutes.dashboard);
    } finally {
      isLoading.value = false;
    }
  }

  void _showValidationMessage(String message) {
    Get.snackbar(
      'Validation Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF263238),
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
