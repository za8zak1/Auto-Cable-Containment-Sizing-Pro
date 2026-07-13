import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'providers/database_provider.dart';
import 'providers/design_provider.dart';
import 'theme/app_theme.dart';
import 'widgets/main_shell.dart';

void main() {
  runApp(const AutoCableSizingProApp());
}

class AutoCableSizingProApp extends StatelessWidget {
  const AutoCableSizingProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DatabaseProvider()..load()),
        ChangeNotifierProvider(create: (_) => DesignProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Auto Cable Sizing Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeProvider.themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
