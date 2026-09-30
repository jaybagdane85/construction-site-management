import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../routes/app_routes.dart';
import 'widgets/auth_layout.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Welcome Back!',
      subtitle: 'Sign in to continue managing\nyour construction sites.',
      bottomContent: const _LoginBottomNote(),
      footer: const SizedBox.shrink(),
      children: [
        AuthTextField(
          controller: controller.emailController,
          label: '',
          hint: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),
        Obx(
          () => AuthTextField(
            controller: controller.passwordController,
            label: '',
            hint: 'Password',
            icon: Icons.lock_outline,
            obscureText: controller.isPasswordHidden.value,
            textInputAction: TextInputAction.done,
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
            onSubmitted: (_) => controller.login(),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Obx(
              () => SizedBox(
                width: 28,
                height: 28,
                child: Checkbox(
                  value: controller.rememberMe.value,
                  onChanged: controller.toggleRememberMe,
                  activeColor: AuthLayout.purple,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Remember me',
              style: TextStyle(
                color: AuthLayout.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AuthLayout.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Obx(
          () => AuthPrimaryButton(
            label: 'Sign In',
            isLoading: controller.isLoading.value,
            onPressed: controller.login,
          ),
        ),
        const SizedBox(height: 16),
        const _DividerText(),
        const SizedBox(height: 14),
        const Row(
          children: [
            Expanded(
              child: _SocialButton(icon: 'G', label: 'Google'),
            ),
            SizedBox(width: 10),
            Expanded(
              child: _SocialButton(icon: 'A', label: 'Apple'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text(
              "Don't have an account? ",
              style: TextStyle(
                color: AuthLayout.ink,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.register),
              child: const Text(
                'Register Now',
                style: TextStyle(
                  color: AuthLayout.purple,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DividerText extends StatelessWidget {
  const _DividerText();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE8E2F4))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: TextStyle(
              color: AuthLayout.muted.withValues(alpha: 0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE8E2F4))),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF8FF),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            icon,
            style: TextStyle(
              color: icon == 'G' ? const Color(0xFF4285F4) : Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AuthLayout.ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBottomNote extends StatelessWidget {
  const _LoginBottomNote();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Every Project\nBuilds a Better Future',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: AuthLayout.purple,
        fontSize: 15,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w700,
        height: 1.1,
      ),
    );
  }
}
