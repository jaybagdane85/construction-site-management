part of '../dashboard_screen.dart';

class _DashboardBottomNavigation extends GetView<DashboardController> {
  const _DashboardBottomNavigation();

  static const _items = [
    _NavItem('Home', Icons.home_outlined, Icons.home_rounded),
    _NavItem('Worker', Icons.groups_2_outlined, Icons.groups_2_rounded),
    _NavItem(
      'Attendance',
      Icons.calendar_month_outlined,
      Icons.calendar_month_rounded,
    ),
    _NavItem('Sites', Icons.apartment_outlined, Icons.apartment_rounded),
    _NavItem('Profile', Icons.badge_outlined, Icons.assignment_ind_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF5A6B83).withValues(alpha: 0.15),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.9),
              blurRadius: 2,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Obx(() {
          final selectedIndex = controller.selectedTabIndex.value;

          return Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isSelected = selectedIndex == index;

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => controller.changeTab(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            width: 38,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFEAF3FF)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isSelected ? item.selectedIcon : item.icon,
                              color: isSelected
                                  ? const Color(0xFF0B77F0)
                                  : const Color(0xFF657086),
                              size: 24,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF0B77F0)
                                  : const Color(0xFF657086),
                              fontWeight: isSelected
                                  ? FontWeight.w900
                                  : FontWeight.w700,
                              fontSize: 11,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  const _NavItem(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
