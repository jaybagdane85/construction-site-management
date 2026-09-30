import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';
import 'session_controller.dart';

class DashboardMetric {
  const DashboardMetric({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
}

class QuickActionItem {
  const QuickActionItem({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

class SiteOverview {
  const SiteOverview({
    required this.name,
    required this.location,
    required this.status,
    required this.progress,
  });

  final String name;
  final String location;
  final String status;
  final double progress;
}

class MaterialAlert {
  const MaterialAlert({
    required this.material,
    required this.message,
    required this.priority,
  });

  final String material;
  final String message;
  final String priority;
}

class RecentActivity {
  const RecentActivity({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;
}

class DashboardController extends GetxController {
  final SessionController sessionController = Get.find<SessionController>();

  final selectedTabIndex = 0.obs;

  final metrics = const <DashboardMetric>[
    DashboardMetric(
      title: 'Active Sites',
      value: '12',
      subtitle: '3 ahead of schedule',
      icon: Icons.apartment_rounded,
    ),
    DashboardMetric(
      title: "Today's Labour",
      value: '86',
      subtitle: '74 present, 12 absent',
      icon: Icons.groups_rounded,
    ),
    DashboardMetric(
      title: "Today's Expense",
      value: '₹42.8K',
      subtitle: 'Materials and wages',
      icon: Icons.account_balance_wallet_rounded,
    ),
    DashboardMetric(
      title: 'Pending Payments',
      value: '₹1.2L',
      subtitle: '5 vendor invoices',
      icon: Icons.receipt_long_rounded,
    ),
  ].obs;

  final quickActions = const <QuickActionItem>[
    QuickActionItem(title: 'Add Site', icon: Icons.add_business_rounded),
    QuickActionItem(title: 'Labour', icon: Icons.badge_rounded),
    QuickActionItem(title: 'Materials', icon: Icons.inventory_2_rounded),
    QuickActionItem(title: 'Expenses', icon: Icons.payments_rounded),
    QuickActionItem(title: 'Payments', icon: Icons.credit_score_rounded),
    QuickActionItem(title: 'Daily Report', icon: Icons.assignment_rounded),
  ].obs;

  final sites = const <SiteOverview>[
    SiteOverview(
      name: 'Skyline Residency',
      location: 'Baner, Pune',
      status: 'On Track',
      progress: 0.72,
    ),
    SiteOverview(
      name: 'Metro Mall Extension',
      location: 'Wakad, Pune',
      status: 'Material Delay',
      progress: 0.48,
    ),
    SiteOverview(
      name: 'Greenfield Villas',
      location: 'Hinjewadi, Pune',
      status: 'Inspection Due',
      progress: 0.61,
    ),
  ].obs;

  final materialAlerts = const <MaterialAlert>[
    MaterialAlert(
      material: 'Cement',
      message: 'Stock below 120 bags at Metro Mall Extension',
      priority: 'High',
    ),
    MaterialAlert(
      material: 'TMT Steel',
      message: 'Vendor delivery confirmation pending',
      priority: 'Medium',
    ),
  ].obs;

  final recentActivities = const <RecentActivity>[
    RecentActivity(
      title: 'Daily report submitted',
      subtitle: 'Skyline Residency • 20 minutes ago',
      icon: Icons.task_alt_rounded,
    ),
    RecentActivity(
      title: 'Labour attendance updated',
      subtitle: '86 workers marked for today',
      icon: Icons.fact_check_rounded,
    ),
    RecentActivity(
      title: 'Payment approval requested',
      subtitle: '₹36,500 invoice from Patel Suppliers',
      icon: Icons.request_quote_rounded,
    ),
  ].obs;

  void changeTab(int index) {
    selectedTabIndex.value = index;
  }

  void openNotifications() {
    Get.snackbar(
      'Notifications',
      'You have 2 material alerts and 5 pending payment updates.',
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
    );
  }

  void handleQuickAction(String action) {
    Get.snackbar(
      action,
      '$action module will be connected in the next development phase.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFF0F172A),
      colorText: Colors.white,
    );
  }

  void showLogoutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Logout'),
        content: const Text('Do you want to logout from this session?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: logout,
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void logout() {
    sessionController.clearSession();
    Get.offAllNamed(AppRoutes.login);
  }
}
