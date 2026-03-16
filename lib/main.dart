// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'features/receipt_scan/presentation/bloc/scan_bloc.dart';
import 'main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Hive.initFlutter();
  await initDependencies();

  final prefs  = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDark') ?? false;

  runApp(ParkScanApp(initialDark: isDark));
}

class ParkScanApp extends StatefulWidget {
  final bool initialDark;
  const ParkScanApp({super.key, required this.initialDark});

  @override
  State<ParkScanApp> createState() => _ParkScanAppState();
}

class _ParkScanAppState extends State<ParkScanApp> {
  late bool _isDark;

  @override
  void initState() {
    super.initState();
    _isDark = widget.initialDark;
  }

  Future<void> _toggleTheme() async {
    setState(() => _isDark = !_isDark);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', _isDark);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ScanBloc>(),
      child: MaterialApp(
        title: 'ParkScan',
        debugShowCheckedModeBanner: false,
        theme:      AppTheme.light,
        darkTheme:  AppTheme.dark,
        themeMode:  _isDark ? ThemeMode.dark : ThemeMode.light,
        home: MainShell(
          onToggleTheme: _toggleTheme,
          isDark: _isDark,
        ),
      ),
    );
  }
}
