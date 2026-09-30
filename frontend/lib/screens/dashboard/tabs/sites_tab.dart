part of '../dashboard_screen.dart';

class _SitesView extends StatelessWidget {
  const _SitesView();

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonView(
      title: 'Sites',
      subtitle: 'Site list, filters, and project details will appear here.',
      icon: Icons.apartment_rounded,
    );
  }
}
