import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'app_drawer.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/quick_design/quick_design_screen.dart';
import '../screens/detailed_design/detailed_design_screen.dart';
import '../screens/cable_lookup/cable_lookup_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = [
    ('Auto Cable Sizing Pro', 'Malaysia IEC LV cable sizing assistant'),
    ('Quick Design', 'Fast cable and breaker recommendation'),
    ('Detailed Design', 'Complete LV feeder sizing workflow'),
    ('Cable Lookup', 'Filter and inspect every cable record'),
  ];

  final _pages = const [
    DashboardScreen(),
    QuickDesignScreen(),
    DetailedDesignScreen(),
    CableLookupScreen(),
  ];

  void _goTo(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final (title, subtitle) = _titles[_index];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: themeProvider.isDark ? 'Switch to light mode' : 'Switch to dark mode',
            icon: Icon(themeProvider.isDark
                ? Icons.light_mode_rounded
                : Icons.dark_mode_rounded),
            onPressed: themeProvider.toggle,
          ),
          const SizedBox(width: 4),
        ],
      ),
      drawer: AppDrawer(currentTabIndex: _index, onSelectTab: _goTo),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _goTo,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.bolt_rounded),
            label: 'Quick',
          ),
          NavigationDestination(
            icon: Icon(Icons.engineering_rounded),
            label: 'Detail',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_rounded),
            label: 'Lookup',
          ),
        ],
      ),
    );
  }
}
