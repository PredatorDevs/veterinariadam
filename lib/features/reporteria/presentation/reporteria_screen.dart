import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../data/reporteria_service.dart';

class ReporteriaScreen extends StatefulWidget {
  const ReporteriaScreen({super.key});

  @override
  State<ReporteriaScreen> createState() => _ReporteriaScreenState();
}

class _ReporteriaScreenState extends State<ReporteriaScreen> {
  final _service = ReporteriaService();

  bool _cargando = true;
  String? _error;
  ReporteriaSnapshot? _snapshot;
  String? _propietarioSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final snapshot = await _service.cargarResumen();
      if (!mounted) {
        return;
      }

      setState(() {
        _snapshot = snapshot;
        if (snapshot.reportePorPropietario.isNotEmpty) {
          _propietarioSeleccionado =
              snapshot.reportePorPropietario.first.propietario.id;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'No fue posible cargar la reporteria');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reporteria')),
      body: RefreshIndicator(onRefresh: _cargar, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 64),
          const Icon(Icons.query_stats_outlined, size: 56),
          const SizedBox(height: 12),
          Text(
            'No fue posible generar la reporteria',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _error!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _cargar, child: const Text('Reintentar')),
        ],
      );
    }

    final snapshot = _snapshot;
    if (snapshot == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 1)],
      );
    }

    PropietarioReporteItem? propietarioSeleccionado;
    if (snapshot.reportePorPropietario.isNotEmpty) {
      propietarioSeleccionado = snapshot.reportePorPropietario.firstWhere(
        (item) => item.propietario.id == _propietarioSeleccionado,
        orElse: () => snapshot.reportePorPropietario.first,
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Dashboard General',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 10),
        _MetricGrid(snapshot: snapshot),
        const SizedBox(height: 16),
        Text(
          'Ultimas Entradas Clinicas',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (snapshot.ultimosHistoriales.isEmpty)
          const _SimpleCard(
            title: 'Sin entradas recientes',
            subtitle: 'Aun no existen registros de historial para mostrar.',
          )
        else
          ...snapshot.ultimosHistoriales.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.event_note_outlined),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.perroNombre,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.diagnostico,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(item.fecha),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 16),
        Text(
          'Reporte por Propietario',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (snapshot.reportePorPropietario.isEmpty)
          const _SimpleCard(
            title: 'Sin propietarios',
            subtitle: 'No hay datos para construir este reporte.',
          )
        else ...[
          DropdownButtonFormField<String>(
            value: propietarioSeleccionado?.propietario.id,
            items: snapshot.reportePorPropietario
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item.propietario.id,
                    child: Text(item.propietario.nombre),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value == null) {
                return;
              }
              setState(() => _propietarioSeleccionado = value);
            },
            decoration: const InputDecoration(labelText: 'Propietario'),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total perros: ${propietarioSeleccionado?.perros.length ?? 0}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total entradas clinicas: ${propietarioSeleccionado?.totalEntradas ?? 0}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  if ((propietarioSeleccionado?.perros.isEmpty ?? true))
                    Text(
                      'Este propietario aun no tiene perros registrados.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  else
                    ...(propietarioSeleccionado?.perros ?? const []).map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.pets_outlined, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.perro.nombre,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                            Text(
                              item.ultimaVisita == null
                                  ? 'Sin visitas'
                                  : _formatDate(item.ultimaVisita!),
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(
          'Reporte por Raza y Edad',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        if (snapshot.perrosPorRaza.isEmpty)
          const _SimpleCard(
            title: 'Sin datos de razas',
            subtitle: 'Registra perros para visualizar esta seccion.',
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...snapshot.perrosPorRaza.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(child: Text(item.raza)),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                            ),
                            child: Text('${item.total}'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rangos de edad',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _AgeRangeLine(
                    label: '0 - 2 anios',
                    total: _countByAge(snapshot, 0, 2),
                  ),
                  _AgeRangeLine(
                    label: '3 - 7 anios',
                    total: _countByAge(snapshot, 3, 7),
                  ),
                  _AgeRangeLine(
                    label: '8+ anios',
                    total: _countByAge(snapshot, 8, 100),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  int _countByAge(ReporteriaSnapshot snapshot, int min, int max) {
    final propietarios = snapshot.reportePorPropietario;
    int count = 0;

    for (final item in propietarios) {
      for (final perro in item.perros) {
        if (perro.perro.edad >= min && perro.perro.edad <= max) {
          count++;
        }
      }
    }

    return count;
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }
}

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.snapshot});

  final ReporteriaSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: [
        _MetricCard(
          title: 'Propietarios',
          value: '${snapshot.totalPropietarios}',
          icon: Icons.people_alt_outlined,
        ),
        _MetricCard(
          title: 'Perros',
          value: '${snapshot.totalPerros}',
          icon: Icons.pets_outlined,
        ),
        _MetricCard(
          title: 'Entradas Clinicas',
          value: '${snapshot.totalHistoriales}',
          icon: Icons.event_note_outlined,
        ),
        _MetricCard(
          title: 'Edad Promedio',
          value: snapshot.promedioEdadPerros.toStringAsFixed(1),
          icon: Icons.cake_outlined,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon),
            Text(value, style: Theme.of(context).textTheme.titleLarge),
            Text(title, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _AgeRangeLine extends StatelessWidget {
  const _AgeRangeLine({required this.label, required this.total});

  final String label;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text('$total', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
