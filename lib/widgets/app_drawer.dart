import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../screens/compliance_checklist/compliance_checklist_screen.dart';
import '../screens/database_version/database_version_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/about/about_screen.dart';
import '../screens/faq/faq_screen.dart';

class AppDrawer extends StatelessWidget {
  final int currentTabIndex;
  final ValueChanged<int> onSelectTab;

  const AppDrawer({
    super.key,
    required this.currentTabIndex,
    required this.onSelectTab,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: AppColors.heroGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.electrical_services_rounded,
                          color: AppColors.primaryBlue, size: 30),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Auto Cable Sizing Pro',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Engineering hub',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _sectionLabel(context, 'Destinations'),
            _destinationTile(
              context,
              icon: Icons.grid_view_rounded,
              title: 'Dashboard',
              subtitle: 'Database status and workflow overview',
              selected: currentTabIndex == 0,
              onTap: () {
                Navigator.pop(context);
                onSelectTab(0);
              },
            ),
            _destinationTile(
              context,
              icon: Icons.bolt_rounded,
              title: 'Quick Design',
              subtitle: 'Fast cable and breaker check',
              selected: currentTabIndex == 1,
              onTap: () {
                Navigator.pop(context);
                onSelectTab(1);
              },
            ),
            _destinationTile(
              context,
              icon: Icons.engineering_rounded,
              title: 'Detailed Design',
              subtitle: 'Full LV feeder design workflow',
              selected: currentTabIndex == 2,
              onTap: () {
                Navigator.pop(context);
                onSelectTab(2);
              },
            ),
            _destinationTile(
              context,
              icon: Icons.search_rounded,
              title: 'Cable Lookup',
              subtitle: 'Filter and inspect database records',
              selected: currentTabIndex == 3,
              onTap: () {
                Navigator.pop(context);
                onSelectTab(3);
              },
            ),
            _plainTile(
              context,
              icon: Icons.fact_check_rounded,
              title: 'Compliance Checklist',
              subtitle: 'TNB / ST / IEC design review checklist',
              onTap: () => _push(context, const ComplianceChecklistScreen()),
            ),
            _plainTile(
              context,
              icon: Icons.grid_on_rounded,
              title: 'Database Version',
              subtitle: 'Database records, sources and disclaimer',
              onTap: () => _push(context, const DatabaseVersionScreen()),
            ),
            const Divider(height: 32),
            _sectionLabel(context, 'App options'),
            _plainTile(
              context,
              icon: Icons.settings_rounded,
              title: 'Settings',
              subtitle: 'Theme and app-wide preferences',
              onTap: () => _push(context, const SettingsScreen()),
            ),
            _plainTile(
              context,
              icon: Icons.info_outline_rounded,
              title: 'About',
              subtitle: 'App purpose and developer profile',
              onTap: () => _push(context, const AboutScreen()),
            ),
            _plainTile(
              context,
              icon: Icons.help_outline_rounded,
              title: 'FAQ',
              subtitle: 'Common cable-sizing questions',
              onTap: () => _push(context, const FaqScreen()),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Version 1.0.0 • Design-assist only. Verify final issue '
                'against IEC/TNB/ST and manufacturer data.',
                style: TextStyle(
                  fontSize: 11.5,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  Widget _sectionLabel(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      );

  Widget _destinationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final color = selected ? AppColors.primaryTeal : null;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.primaryTeal)
          : null,
      onTap: onTap,
    );
  }

  Widget _plainTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}
