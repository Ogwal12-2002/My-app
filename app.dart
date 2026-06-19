import 'package:flutter/material.dart';

import 'core/constants.dart';
import 'core/theme/app_theme.dart';
import 'models/scan_record.dart';
import 'screens/generator/generator_screen.dart';
import 'screens/history/history_screen.dart';
import 'screens/result/result_screen.dart';
import 'screens/scanner/scanner_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QR Scanner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.scanner,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.scanner:
            return MaterialPageRoute(builder: (_) => const ScannerScreen());

          case AppRoutes.history:
            return MaterialPageRoute(builder: (_) => const HistoryScreen());

          case AppRoutes.generator:
            return MaterialPageRoute(builder: (_) => const GeneratorScreen());

          case AppRoutes.result:
            final record = settings.arguments as ScanRecord;
            return MaterialPageRoute(builder: (_) => ResultScreen(record: record));

          default:
            return MaterialPageRoute(builder: (_) => const ScannerScreen());
        }
      },
    );
  }
}
