import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/dashboard_controller.dart';
import '../../controllers/session_controller.dart';
import '../profile/profile_screen.dart';

part 'tabs/home_tab.dart';
part 'tabs/worker_tab.dart';
part 'tabs/attendance_tab.dart';
part 'tabs/sites_tab.dart';
part 'widgets/dashboard_bottom_navigation.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  static const Color deepNavy = Color(0xFF171717);
  static const Color navySurface = Color(0xFF3B3940);
  static const Color steelBlue = Color(0xFF77BFD3);
  static const Color lightGray = Color(0xFFFFF7FA);
  static const Color borderGray = Color(0xFFF0E8EF);
  static const Color textMuted = Color(0xFF8A8490);
  static const Color amber = Color(0xFFE8A23A);
  static const Color softLavender = Color(0xFFDCC8F5);
  static const Color softPink = Color(0xFFF7C6D9);
  static const Color softPeach = Color(0xFFF6D8C8);
  static const Color softBlue = Color(0xFFC7E8F4);

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: const Color(0xFF171717).withValues(alpha: 0.05),
      blurRadius: 22,
      offset: const Offset(0, 12),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: lightGray,
      body: SafeArea(
        child: Obx(() {
          final index = controller.selectedTabIndex.value;

          return IndexedStack(
            index: index,
            children: const [
              _HomeView(),
              _WorkersView(),
              _AttendanceView(),
              _SitesView(),
              ProfileScreen(),
            ],
          );
        }),
      ),
      bottomNavigationBar: const _DashboardBottomNavigation(),
    );
  }
}

class _DashboardHeader extends GetView<DashboardController> {
  const _DashboardHeader();

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionController>();

    return Obx(() {
      final user = session.user;

      return Container(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 4),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good day,',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: DashboardScreen.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: DashboardScreen.deepNavy,
                      fontWeight: FontWeight.w900,
                      height: 1.04,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Track sites, labour, materials and payments',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: DashboardScreen.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _HeaderIconButton(
              tooltip: 'Notifications',
              onPressed: controller.openNotifications,
              child: const Badge(
                backgroundColor: DashboardScreen.amber,
                smallSize: 8,
                child: Icon(Icons.notifications_none_rounded),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: DashboardScreen.softShadow,
              ),
              alignment: Alignment.center,
              child: CircleAvatar(
                radius: 20,
                backgroundColor: DashboardScreen.softLavender,
                child: Text(
                  user.name.isEmpty ? 'U' : user.name[0].toUpperCase(),
                  style: const TextStyle(
                    color: DashboardScreen.deepNavy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: DashboardScreen.deepNavy.withValues(alpha: 0.08),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onPressed,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 48,
            height: 48,
            child: IconTheme(
              data: const IconThemeData(color: DashboardScreen.deepNavy),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProjectOverviewCard extends StatefulWidget {
  const _ProjectOverviewCard();

  @override
  State<_ProjectOverviewCard> createState() => _ProjectOverviewCardState();
}

class _ProjectOverviewCardState extends State<_ProjectOverviewCard> {
  late final PageController _pageController;
  Timer? _autoSlideTimer;
  int _currentPage = 0;

  static const _slides = [
    'assets/dashboard/site_showcase_1.png',
    'assets/dashboard/site_showcase_2.png',
    'assets/dashboard/site_showcase_3.png',
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || !_pageController.hasClients) {
        return;
      }

      final nextPage = (_currentPage + 1) % _slides.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 226,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: _slides.length,
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _slides[index],
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
            Positioned(
              bottom: 12,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(_slides.length, (index) {
                      final isActive = index == _currentPage;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: isActive ? 18 : 7,
                        height: 7,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        decoration: BoxDecoration(
                          color: isActive
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.58),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricGrid extends GetView<DashboardController> {
  const _MetricGrid();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Obx(() {
          final columns = constraints.maxWidth >= 680 ? 4 : 2;
          final itemWidth =
              (constraints.maxWidth - ((columns - 1) * 12)) / columns;
          final metrics = controller.metrics;

          return Wrap(
            spacing: 12,
            runSpacing: 12,
            children: metrics
                .map(
                  (metric) => SizedBox(
                    width: itemWidth,
                    child: _MetricCard(metric: metric),
                  ),
                )
                .toList(),
          );
        });
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.metric});

  final DashboardMetric metric;

  @override
  Widget build(BuildContext context) {
    final accent = _metricAccent(metric.title);
    final gradient = _metricGradient(metric.title);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradient,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: DashboardScreen.softShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(metric.icon, color: accent, size: 24),
              ),
              const SizedBox(height: 14),
              Text(
                metric.value,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: DashboardScreen.deepNavy,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                metric.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: DashboardScreen.deepNavy,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                metric.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: DashboardScreen.textMuted,
                  fontSize: 12,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _metricAccent(String title) {
    if (title.contains('Labour')) {
      return const Color(0xFF4E9C93);
    }
    if (title.contains('Expense')) {
      return const Color(0xFF5898B8);
    }
    if (title.contains('Payments')) {
      return const Color(0xFFB27BCB);
    }
    return const Color(0xFFE4A34B);
  }

  List<Color> _metricGradient(String title) {
    if (title.contains('Labour')) {
      return const [Color(0xFFE9F8F5), Color(0xFFCFF0E8)];
    }
    if (title.contains('Expense')) {
      return const [Color(0xFFEAF8FC), DashboardScreen.softBlue];
    }
    if (title.contains('Payments')) {
      return const [Color(0xFFF7EEFF), DashboardScreen.softLavender];
    }
    return const [Color(0xFFFFF4EA), DashboardScreen.softPeach];
  }
}

class _QuickActions extends GetView<DashboardController> {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Quick Actions',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Obx(() {
            final crossAxisCount = constraints.maxWidth >= 560 ? 6 : 3;
            final quickActions = controller.quickActions;

            return GridView.builder(
              itemCount: quickActions.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final action = quickActions[index];
                final accent = _actionAccent(index);

                return Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => controller.handleQuickAction(action.title),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.7),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              action.icon,
                              color: DashboardScreen.deepNavy,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 9),
                          Text(
                            action.title,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: DashboardScreen.deepNavy,
                              fontWeight: FontWeight.w800,
                              fontSize: 12,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          });
        },
      ),
    );
  }

  Color _actionAccent(int index) {
    const colors = [
      DashboardScreen.softBlue,
      Color(0xFFD8F0E8),
      DashboardScreen.softLavender,
      DashboardScreen.softPeach,
      Color(0xFFE3ECFF),
      DashboardScreen.softPink,
    ];

    return colors[index % colors.length];
  }
}

class _MySitesSection extends GetView<DashboardController> {
  const _MySitesSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'My Sites',
      trailing: TextButton.icon(
        onPressed: () => controller.changeTab(3),
        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
        label: const Text('View All'),
      ),
      child: Obx(
        () => Column(
          children: controller.sites
              .map((site) => _SiteTile(site: site))
              .toList(),
        ),
      ),
    );
  }
}

class _SiteTile extends StatelessWidget {
  const _SiteTile({required this.site});

  final SiteOverview site;

  @override
  Widget build(BuildContext context) {
    final isDelayed = site.status.toLowerCase().contains('delay');
    final statusColor = isDelayed
        ? const Color(0xFFB45A66)
        : DashboardScreen.deepNavy;
    final statusBg = isDelayed
        ? const Color(0xFFFFE5EC)
        : DashboardScreen.softLavender.withValues(alpha: 0.58);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: DashboardScreen.borderGray),
        boxShadow: [
          BoxShadow(
            color: DashboardScreen.deepNavy.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: DashboardScreen.softBlue.withValues(alpha: 0.52),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.business_rounded,
              color: DashboardScreen.deepNavy,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        site.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DashboardScreen.deepNavy,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        site.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: DashboardScreen.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        site.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DashboardScreen.textMuted,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: site.progress),
                          duration: const Duration(milliseconds: 650),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return LinearProgressIndicator(
                              value: value,
                              minHeight: 8,
                              backgroundColor: DashboardScreen.lightGray,
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFB996E8),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(site.progress * 100).round()}%',
                      style: const TextStyle(
                        color: DashboardScreen.deepNavy,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F1FA),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: DashboardScreen.textMuted,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MaterialAlertSection extends GetView<DashboardController> {
  const _MaterialAlertSection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Material Alert',
      child: Obx(
        () => Column(
          children: controller.materialAlerts
              .map(
                (alert) => _InfoTile(
                  icon: Icons.warning_amber_rounded,
                  title: alert.material,
                  subtitle: alert.message,
                  badge: alert.priority,
                  color: alert.priority == 'High'
                      ? const Color(0xFFB45A66)
                      : const Color(0xFFE0A24C),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _RecentActivitySection extends GetView<DashboardController> {
  const _RecentActivitySection();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Recent Activity',
      child: Obx(
        () => Column(
          children: controller.recentActivities
              .map(
                (activity) => _InfoTile(
                  icon: activity.icon,
                  title: activity.title,
                  subtitle: activity.subtitle,
                  color: const Color(0xFF9B7AD1),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.badge,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFAFC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DashboardScreen.borderGray),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: DashboardScreen.deepNavy,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: Text(
                          badge!,
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: DashboardScreen.textMuted,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: DashboardScreen.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: DashboardScreen.deepNavy,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ComingSoonView extends StatelessWidget {
  const _ComingSoonView({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 128),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: DashboardScreen.borderGray),
          boxShadow: DashboardScreen.softShadow,
        ),
        child: Column(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: DashboardScreen.amber.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, size: 34, color: DashboardScreen.deepNavy),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: DashboardScreen.deepNavy,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: DashboardScreen.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
