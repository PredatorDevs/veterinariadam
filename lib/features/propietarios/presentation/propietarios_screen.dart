import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../data/propietario_model.dart';
import '../data/propietarios_repository.dart';
import 'propietario_form_screen.dart';

class PropietariosScreen extends StatefulWidget {
  const PropietariosScreen({super.key});

  @override
  State<PropietariosScreen> createState() => _PropietariosScreenState();
}

class _PropietariosScreenState extends State<PropietariosScreen> {
  final _repository = PropietariosRepository();

  bool _cargando = true;
  String? _error;
  List<PropietarioModel> _items = const [];

  @override
  void initState() {
    super.initState();
    _cargarPropietarios();
  }

  Future<void> _cargarPropietarios() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final propietarios = await _repository.obtenerTodos();
      if (!mounted) {
        return;
      }
      setState(() => _items = propietarios);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'No se pudo cargar la informacion');
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _abrirNuevoPropietario() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const PropietarioFormScreen()),
    );

    if (created == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Propietario creado correctamente')),
        );
      }
      await _cargarPropietarios();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Propietarios')),
      body: RefreshIndicator(
        onRefresh: _cargarPropietarios,
        child: _buildContent(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevoPropietario,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildContent() {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 64),
          const Icon(Icons.cloud_off_outlined, size: 56),
          const SizedBox(height: 12),
          Text(
            'No fue posible obtener propietarios',
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
          ElevatedButton(
            onPressed: _cargarPropietarios,
            child: const Text('Reintentar'),
          ),
        ],
      );
    }

    if (_items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 64),
          const Icon(Icons.people_outline, size: 56),
          const SizedBox(height: 12),
          Text(
            'Aun no hay propietarios registrados',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pulsa "Nuevo" para crear el primer propietario.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = _items[index];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.nombre,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  value: item.telefono ?? 'Sin telefono',
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.email_outlined,
                  value: item.correo ?? 'Sin correo',
                ),
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  value: item.direccion ?? 'Sin direccion',
                ),
              ],
            ),
          ),
        );
      },
    );
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
