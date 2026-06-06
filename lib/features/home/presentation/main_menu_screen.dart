import 'package:flutter/material.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Veterinaria DAM')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Menu principal', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 6),
          Text(
            'Accede rapido a los modulos operativos y a reporteria.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          _QuickActionsRow(),
          const SizedBox(height: 14),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.08,
            children: const [
              _MenuTile(
                title: 'Propietarios',
                subtitle: 'Gestion de clientes',
                icon: Icons.people_alt_outlined,
                routeName: '/propietarios',
              ),
              _MenuTile(
                title: 'Perros',
                subtitle: 'Pacientes registrados',
                icon: Icons.pets_outlined,
                routeName: '/perros',
              ),
              _MenuTile(
                title: 'Historial',
                subtitle: 'Entradas clinicas',
                icon: Icons.medical_services_outlined,
                routeName: '/historial',
              ),
              _MenuTile(
                title: 'Reporteria',
                subtitle: 'Metricas y analisis',
                icon: Icons.bar_chart_outlined,
                routeName: '/reporteria',
              ),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.tips_and_updates_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tip: usa ReporterIa para revisar volumen de atenciones y ultimas visitas.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/perros'),
            icon: const Icon(Icons.pets_outlined),
            label: const Text('Nuevo perro'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/historial'),
            icon: const Icon(Icons.note_add_outlined),
            label: const Text('Nueva entrada'),
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routeName,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, routeName),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 28),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [Icon(Icons.arrow_forward_ios, size: 14)],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
