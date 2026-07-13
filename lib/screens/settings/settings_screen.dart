import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Card(
            child: SwitchListTile(
              title: const Text('Dark mode', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Switch between light and dark theme'),
              value: theme.isDark,
              onChanged: (_) => theme.toggle(),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Default voltage drop limit',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('5% (edit in Detailed Design per project)'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              title: const Text('Units', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Metric (mm², m, A, V) - fixed in this build'),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
