import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../perros/data/perro_model.dart';
import '../../perros/data/perros_repository.dart';
import '../data/historial_model.dart';
import '../data/historial_repository.dart';
import 'historial_form_screen.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  final _perrosRepository = PerrosRepository();
  final _historialRepository = HistorialRepository();

  bool _cargandoPerros = true;
  bool _cargandoHistorial = false;
  String? _errorPerros;
  String? _errorHistorial;

  List<PerroModel> _perros = const [];
  List<HistorialModel> _historial = const [];
  String? _perroSeleccionado;

  @override
  void initState() {
    super.initState();
    _inicializar();
  }

  Future<void> _inicializar() async {
    setState(() {
      _cargandoPerros = true;
      _errorPerros = null;
    });

    try {
      final perros = await _perrosRepository.obtenerTodos();
      if (!mounted) {
        return;
      }

      setState(() {
        _perros = perros;
        _perroSeleccionado = perros.isNotEmpty ? perros.first.id : null;
      });

      if (_perroSeleccionado != null) {
        await _cargarHistorial(_perroSeleccionado!);
      }
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _errorPerros = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _errorPerros = 'No se pudieron cargar los perros');
    } finally {
      if (mounted) {
        setState(() => _cargandoPerros = false);
      }
    }
  }

  Future<void> _cargarHistorial(String perroId) async {
    setState(() {
      _cargandoHistorial = true;
      _errorHistorial = null;
    });

    try {
      final historial = await _historialRepository.obtenerPorPerro(perroId);
      if (!mounted) {
        return;
      }
      setState(() => _historial = historial);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _errorHistorial = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _errorHistorial = 'No se pudo cargar el historial');
    } finally {
      if (mounted) {
        setState(() => _cargandoHistorial = false);
      }
    }
  }

  Future<void> _abrirNuevaEntrada() async {
    if (_perros.isEmpty || _perroSeleccionado == null) {
      return;
    }

    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => HistorialFormScreen(
          perros: _perros,
          initialPerroId: _perroSeleccionado!,
        ),
      ),
    );

    if (created == true && _perroSeleccionado != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Entrada clinica creada correctamente')),
        );
      }
      await _cargarHistorial(_perroSeleccionado!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),
      drawer: const AppDrawer(currentRoute: '/historial'),
      body: RefreshIndicator(
        onRefresh: () async {
          if (_perroSeleccionado != null) {
            await _cargarHistorial(_perroSeleccionado!);
          } else {
            await _inicializar();
          }
        },
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _perros.isEmpty ? null : _abrirNuevaEntrada,
        icon: const Icon(Icons.add),
        label: const Text('Nueva entrada'),
      ),
    );
  }

  Widget _buildBody() {
    if (_cargandoPerros) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorPerros != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 64),
          const Icon(Icons.cloud_off_outlined, size: 56),
          const SizedBox(height: 12),
          Text(
            'No fue posible cargar perros',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _errorPerros!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _inicializar,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (_perros.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 64),
          const Icon(Icons.pets_outlined, size: 56),
          const SizedBox(height: 12),
          Text(
            'No hay perros registrados',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Primero crea un perro para poder registrar su historial clinico.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField<String>(
          value: _perroSeleccionado,
          items: _perros
              .map(
                (item) => DropdownMenuItem<String>(
                  value: item.id,
                  child: Text(item.nombre),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }
            setState(() => _perroSeleccionado = value);
            _cargarHistorial(value);
          },
          decoration: const InputDecoration(labelText: 'Selecciona un perro'),
        ),
        const SizedBox(height: 14),
        if (_cargandoHistorial)
          const Padding(
            padding: EdgeInsets.only(top: 16),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_errorHistorial != null)
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
                    _errorHistorial!,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      final perroId = _perroSeleccionado;
                      if (perroId != null) {
                        _cargarHistorial(perroId);
                      }
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          )
        else if (_historial.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sin entradas clinicas',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Este perro aun no tiene historial registrado.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          ..._historial
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HistorialCard(item: item),
                ),
              )
              .toList(),
      ],
    );
  }
}

class _HistorialCard extends StatelessWidget {
  const _HistorialCard({required this.item});

  final HistorialModel item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.event_note_outlined, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _formatDate(item.fecha),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _InfoRow(icon: Icons.monitor_weight_outlined, value: _pesoLabel()),
            const SizedBox(height: 4),
            _InfoRow(
              icon: Icons.medical_information_outlined,
              value: item.diagnostico,
            ),
            if ((item.tratamiento ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.healing_outlined,
                value: item.tratamiento!.trim(),
              ),
            ],
            if ((item.observaciones ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 4),
              _InfoRow(
                icon: Icons.notes_outlined,
                value: item.observaciones!.trim(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _pesoLabel() {
    final value = item.peso;
    if (value == null) {
      return 'Peso no registrado';
    }
    return '${value.toStringAsFixed(value % 1 == 0 ? 0 : 1)} kg';
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17),
        const SizedBox(width: 6),
        Expanded(
          child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
