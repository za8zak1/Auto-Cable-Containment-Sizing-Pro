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
  final ThemeProvider? themeProvider;
  final DatabaseProvider? databaseProvider;
  final DesignProvider? designProvider;

  const AutoCableSizingProApp({
    super.key,
    this.themeProvider,
    this.databaseProvider,
    this.designProvider,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => themeProvider ?? ThemeProvider(),
        ),
        ChangeNotifierProvider<DatabaseProvider>(
          create: (_) {
            final provider = databaseProvider ?? DatabaseProvider();
            if (!provider.isLoaded && !provider.isLoading) {
              provider.load();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider<DesignProvider>(
          create: (_) => designProvider ?? DesignProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, provider, _) {
          return MaterialApp(
            title: 'Auto Cable Sizing Pro',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: provider.themeMode,
            home: const MainShell(),
          );
        },
      ),
    );
  }
}
