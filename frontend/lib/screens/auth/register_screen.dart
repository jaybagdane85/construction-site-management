import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import 'widgets/auth_layout.dart';

class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Create Account',
      subtitle: 'Join SiteManager and start your\nconstruction journey.',
      showBackButton: true,
      bottomContent: const _RegisterFooterFeatures(),
      footer: const SizedBox.shrink(),
      children: [
        AuthTextField(
          controller: controller.nameController,
          label: '',
          hint: 'Full Name',
          icon: Icons.person_outline,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: controller.emailController,
          label: '',
          hint: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        AuthTextField(
          controller: controller.mobileController,
          label: '',
          hint: 'Mobile Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.next,
          prefix: const Padding(
            padding: EdgeInsets.only(right: 10),
            child: Text(
              '+91  ',
              style: TextStyle(
                color: AuthLayout.ink,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => AuthTextField(
            controller: controller.passwordController,
            label: '',
            hint: 'Password',
            icon: Icons.lock_outline,
            obscureText: controller.isPasswordHidden.value,
            textInputAction: TextInputAction.next,
            suffixIcon: IconButton(
              tooltip: controller.isPasswordHidden.value
                  ? 'Show password'
                  : 'Hide password',
              onPressed: controller.togglePasswordVisibility,
              icon: Icon(
                controller.isPasswordHidden.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => AuthTextField(
            controller: controller.confirmPasswordController,
            label: '',
            hint: 'Confirm Password',
            icon: Icons.lock_outline,
            obscureText: controller.isConfirmPasswordHidden.value,
            textInputAction: TextInputAction.done,
            suffixIcon: IconButton(
              tooltip: controller.isConfirmPasswordHidden.value
                  ? 'Show password'
                  : 'Hide password',
              onPressed: controller.toggleConfirmPasswordVisibility,
              icon: Icon(
                controller.isConfirmPasswordHidden.value
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
              ),
            ),
            onSubmitted: (_) => controller.register(),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () => Checkbox(
                value: controller.acceptTerms.value,
                onChanged: controller.toggleAcceptTerms,
                activeColor: AuthLayout.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 11),
                child: Text.rich(
                  TextSpan(
                    text: 'I agree to the ',
                    children: [
                      TextSpan(
                        text: 'Terms & Conditions',
                        style: TextStyle(color: AuthLayout.purple),
                      ),
                      TextSpan(text: '\nand '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: AuthLayout.purple),
                      ),
                    ],
                  ),
                  style: TextStyle(
                    color: AuthLayout.ink,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => AuthPrimaryButton(
            label: 'Create Account',
            isLoading: controller.isLoading.value,
            onPressed: controller.register,
          ),
        ),
      ],
    );
  }
}

class _RegisterFooterFeatures extends StatelessWidget {
  const _RegisterFooterFeatures();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Row(
          children: [
            AuthFeatureItem(
              icon: Icons.verified_user_outlined,
              label: 'Secure\nAccess',
            ),
            AuthFeatureItem(
              icon: Icons.groups_2_outlined,
              label: 'Manage\nYour Team',
            ),
            AuthFeatureItem(
              icon: Icons.bar_chart_rounded,
              label: 'Track\nProgress',
            ),
            AuthFeatureItem(
              icon: Icons.engineering_rounded,
              label: 'Build\nTogether',
            ),
          ],
        ),
        SizedBox(height: 28),
        Text(
          'Together We Build a Smarter Tomorrow',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AuthLayout.muted,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
