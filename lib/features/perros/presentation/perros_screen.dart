import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../data/perro_model.dart';
import '../data/perros_repository.dart';
import 'perro_detail_screen.dart';
import 'perro_form_screen.dart';

class PerrosScreen extends StatefulWidget {
  const PerrosScreen({super.key});

  @override
  State<PerrosScreen> createState() => _PerrosScreenState();
}

class _PerrosScreenState extends State<PerrosScreen> {
  final _repository = PerrosRepository();

  bool _cargando = true;
  String? _error;
  List<PerroModel> _items = const [];

  @override
  void initState() {
    super.initState();
    _cargarPerros();
  }

  Future<void> _cargarPerros() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final perros = await _repository.obtenerTodos();
      if (!mounted) {
        return;
      }
      setState(() => _items = perros);
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

  Future<void> _abrirNuevoPerro() async {
    final created = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const PerroFormScreen()));

    if (created == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perro creado correctamente')),
        );
      }
      await _cargarPerros();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Pacientes'),
        actions: [
          IconButton(
            onPressed: _cargarPerros,
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
          ),
        ],
      ),
      drawer: const AppDrawer(currentRoute: '/'),
      body: RefreshIndicator(onRefresh: _cargarPerros, child: _buildContent()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirNuevoPerro,
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
            'No fue posible obtener perros',
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
            onPressed: _cargarPerros,
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
          const Icon(Icons.pets_outlined, size: 56),
          const SizedBox(height: 12),
          Text(
            'Aun no hay perros registrados',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Pulsa "Nuevo" para crear el primer perro.',
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
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PerroDetailScreen(perro: item),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.pets_outlined, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.nombre,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 14),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(icon: Icons.category_outlined, value: item.raza),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.cake_outlined,
                    value: '${item.edad} anios',
                  ),
                  const SizedBox(height: 4),
                  _InfoRow(
                    icon: Icons.person_outline,
                    value:
                        item.propietarioNombre ?? 'Propietario no disponible',
                  ),
                ],
              ),
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
