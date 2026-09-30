part of '../dashboard_screen.dart';

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 128),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [
          _DashboardHeader(),
          SizedBox(height: 18),
          _ProjectOverviewCard(),
          SizedBox(height: 18),
          _MetricGrid(),
          SizedBox(height: 22),
          _QuickActions(),
          SizedBox(height: 22),
          _MySitesSection(),
          SizedBox(height: 22),
          _MaterialAlertSection(),
          SizedBox(height: 22),
          _RecentActivitySection(),
        ],
      ),
    );
  }
}
