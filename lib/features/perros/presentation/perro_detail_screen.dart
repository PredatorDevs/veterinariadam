import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../historial/data/historial_model.dart';
import '../../historial/data/historial_repository.dart';
import '../../historial/presentation/historial_form_screen.dart';
import '../data/perro_model.dart';

class PerroDetailScreen extends StatefulWidget {
  const PerroDetailScreen({super.key, required this.perro});

  final PerroModel perro;

  @override
  State<PerroDetailScreen> createState() => _PerroDetailScreenState();
}

class _PerroDetailScreenState extends State<PerroDetailScreen> {
  final _historialRepository = HistorialRepository();

  bool _cargando = true;
  String? _error;
  List<HistorialModel> _historial = const [];

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final historial = await _historialRepository.obtenerPorPerro(
        widget.perro.id,
      );
      if (!mounted) {
        return;
      }
      setState(() => _historial = historial);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'No se pudo cargar el historial clinico');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _agregarConsulta() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HistorialFormScreen(
          perros: [widget.perro],
          initialPerroId: widget.perro.id,
        ),
      ),
    );

    if (created == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Consulta medica agregada correctamente'),
          ),
        );
      }
      await _cargarHistorial();
    }
  }

  @override
  Widget build(BuildContext context) {
    final perro = widget.perro;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Paciente'),
        actions: [
          IconButton(
            onPressed: _cargarHistorial,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar historial',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: _cargarHistorial,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.pets_outlined, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            perro.nombre,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _InfoLine(
                      icon: Icons.category_outlined,
                      label: 'Raza',
                      value: perro.raza,
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      icon: Icons.cake_outlined,
                      label: 'Edad',
                      value: '${perro.edad} anios',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Datos del Propietario',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    _InfoLine(
                      icon: Icons.person_outline,
                      label: 'Nombre',
                      value: perro.propietarioNombre ?? 'No disponible',
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      icon: Icons.phone_outlined,
                      label: 'Telefono',
                      value: perro.propietarioTelefono ?? 'No disponible',
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      icon: Icons.location_on_outlined,
                      label: 'Direccion',
                      value: perro.propietarioDireccion ?? 'No disponible',
                    ),
                    const SizedBox(height: 6),
                    _InfoLine(
                      icon: Icons.email_outlined,
                      label: 'Correo',
                      value: perro.propietarioCorreo ?? 'No disponible',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Historial Clinico',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_cargando)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No fue posible cargar historial',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _cargarHistorial,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              )
            else if (_historial.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Text(
                    'Este paciente aun no tiene consultas registradas.',
                  ),
                ),
              )
            else
              ..._historial.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(item.fecha),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          _InfoLine(
                            icon: Icons.medical_information_outlined,
                            label: 'Diagnostico',
                            value: item.diagnostico,
                          ),
                          const SizedBox(height: 6),
                          _InfoLine(
                            icon: Icons.monitor_weight_outlined,
                            label: 'Peso',
                            value: item.peso == null
                                ? 'No registrado'
                                : '${item.peso} kg',
                          ),
                          const SizedBox(height: 6),
                          _InfoLine(
                            icon: Icons.healing_outlined,
                            label: 'Tratamiento',
                            value: item.tratamiento?.trim().isNotEmpty == true
                                ? item.tratamiento!.trim()
                                : 'No registrado',
                          ),
                          const SizedBox(height: 6),
                          _InfoLine(
                            icon: Icons.notes_outlined,
                            label: 'Observaciones',
                            value: item.observaciones?.trim().isNotEmpty == true
                                ? item.observaciones!.trim()
                                : 'No registrado',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _agregarConsulta,
        icon: const Icon(Icons.add),
        label: const Text('Agregar consulta'),
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$label: $value',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
