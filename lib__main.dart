import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/shell.dart';
import 'theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: FX.surface,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(const FlixoraApp());
}

class FlixoraApp extends StatelessWidget {
  const FlixoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flixora',
      debugShowCheckedModeBanner: false,
      theme: FX.theme(),
      darkTheme: FX.theme(),
      themeMode: ThemeMode.dark,
      home: const Shell(),
    );
  }
}
