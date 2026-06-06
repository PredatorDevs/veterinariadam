import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/historial/presentation/historial_screen.dart';
import 'features/home/presentation/main_menu_screen.dart';
import 'features/perros/presentation/perros_screen.dart';
import 'features/propietarios/presentation/propietarios_screen.dart';
import 'features/reporteria/presentation/reporteria_screen.dart';

void main() {
  runApp(const VeterinariaApp());
}

class VeterinariaApp extends StatelessWidget {
  const VeterinariaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Veterinaria DAM',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const PerrosScreen(),
        '/menu': (context) => const MainMenuScreen(),
        '/propietarios': (context) => const PropietariosScreen(),
        '/perros': (context) => const PerrosScreen(),
        '/historial': (context) => const HistorialScreen(),
        '/reporteria': (context) => const ReporteriaScreen(),
      },
    );
  }
}
