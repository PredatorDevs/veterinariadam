import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key, this.currentRoute});

  final String? currentRoute;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Veterinaria DAM',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            _DrawerItem(
              icon: Icons.home_outlined,
              label: 'Inicio (Perros)',
              routeName: '/',
              currentRoute: currentRoute,
            ),
            _DrawerItem(
              icon: Icons.people_alt_outlined,
              label: 'Propietarios',
              routeName: '/propietarios',
              currentRoute: currentRoute,
            ),
            _DrawerItem(
              icon: Icons.pets_outlined,
              label: 'Registrar Perro',
              routeName: '/perros',
              currentRoute: currentRoute,
            ),
            _DrawerItem(
              icon: Icons.medical_services_outlined,
              label: 'Historial',
              routeName: '/historial',
              currentRoute: currentRoute,
            ),
            _DrawerItem(
              icon: Icons.bar_chart_outlined,
              label: 'Reporteria',
              routeName: '/reporteria',
              currentRoute: currentRoute,
            ),
            const Divider(height: 24),
            _DrawerItem(
              icon: Icons.dashboard_outlined,
              label: 'Menu Modulos',
              routeName: '/menu',
              currentRoute: currentRoute,
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.routeName,
    required this.currentRoute,
  });

  final IconData icon;
  final String label;
  final String routeName;
  final String? currentRoute;

  @override
  Widget build(BuildContext context) {
    final selected = currentRoute == routeName;

    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      onTap: () {
        Navigator.of(context).pop();

        if (selected) {
          return;
        }

        Navigator.pushReplacementNamed(context, routeName);
      },
    );
  }
}
