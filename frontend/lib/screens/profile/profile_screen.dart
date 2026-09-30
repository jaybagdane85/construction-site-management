import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/dashboard_controller.dart';
import '../../controllers/session_controller.dart';

class ProfileScreen extends GetView<DashboardController> {
  const ProfileScreen({super.key});

  static const Color deepNavy = Color(0xFF0F172A);
  static const Color lightGray = Color(0xFFF3F4F6);
  static const Color amber = Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionController>();

    return Obx(() {
      final user = session.user;

      return SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: amber.withValues(alpha: 0.16),
                    child: Text(
                      user.name.isEmpty ? 'U' : user.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: amber,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: deepNavy,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Chip(
                    backgroundColor: lightGray,
                    side: BorderSide.none,
                    label: Text(
                      user.role,
                      style: const TextStyle(
                        color: deepNavy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _ProfileTile(
              icon: Icons.settings_rounded,
              title: 'Settings',
              subtitle: 'Account, app preferences and notifications',
              onTap: () => Get.snackbar(
                'Settings',
                'Settings will be available soon.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                backgroundColor: deepNavy,
                colorText: Colors.white,
              ),
            ),
            _ProfileTile(
              icon: Icons.lock_outline_rounded,
              title: 'Security',
              subtitle: 'Password and sign-in options',
              onTap: () => Get.snackbar(
                'Security',
                'Security settings will be connected later.',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16),
                backgroundColor: deepNavy,
                colorText: Colors.white,
              ),
            ),
            _ProfileTile(
              icon: Icons.logout_rounded,
              title: 'Logout',
              subtitle: 'End current mock session',
              isDestructive: true,
              onTap: controller.showLogoutDialog,
            ),
          ],
        ),
      );
    });
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFDC2626) : ProfileScreen.deepNavy;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: TextStyle(color: color, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.chevron_right_rounded, color: color),
      ),
    );
  }
}
