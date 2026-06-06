import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../propietarios/data/propietario_model.dart';
import '../../propietarios/data/propietarios_repository.dart';
import '../data/perros_repository.dart';

class PerroFormScreen extends StatefulWidget {
  const PerroFormScreen({super.key});

  @override
  State<PerroFormScreen> createState() => _PerroFormScreenState();
}

class _PerroFormScreenState extends State<PerroFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _razaCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();

  final _perrosRepository = PerrosRepository();
  final _propietariosRepository = PropietariosRepository();

  bool _cargandoPropietarios = true;
  bool _guardando = false;
  String? _errorCarga;
  List<PropietarioModel> _propietarios = const [];
  String? _propietarioSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarPropietarios();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _razaCtrl.dispose();
    _edadCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPropietarios() async {
    setState(() {
      _cargandoPropietarios = true;
      _errorCarga = null;
    });

    try {
      final propietarios = await _propietariosRepository.obtenerTodos();
      if (!mounted) {
        return;
      }
      setState(() {
        _propietarios = propietarios;
        if (_propietarios.isNotEmpty) {
          _propietarioSeleccionado = _propietarios.first.id;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _errorCarga = e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _errorCarga = 'No se pudieron cargar propietarios');
    } finally {
      if (mounted) {
        setState(() => _cargandoPropietarios = false);
      }
    }
  }

  Future<void> _guardar() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _guardando) {
      return;
    }

    final propietarioId = _propietarioSeleccionado;
    if (propietarioId == null || propietarioId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un propietario')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await _perrosRepository.crear(
        nombre: _nombreCtrl.text,
        raza: _razaCtrl.text,
        edad: int.parse(_edadCtrl.text.trim()),
        propietarioId: propietarioId,
      );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo crear: ${e.message}')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error inesperado al crear perro')),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Perro')),
      drawer: const AppDrawer(currentRoute: '/perros'),
      body: _cargandoPropietarios
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_errorCarga != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 56),
            const SizedBox(height: 12),
            Text(
              'No fue posible cargar propietarios',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _errorCarga!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _cargarPropietarios,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_propietarios.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 56),
            const SizedBox(height: 12),
            Text(
              'Necesitas al menos un propietario',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Primero crea un propietario en su modulo y luego registra el perro.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nombreCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Nombre *',
                  hintText: 'Ej. Toby',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'El nombre es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _razaCtrl,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Raza *',
                  hintText: 'Ej. Beagle',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'La raza es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _edadCtrl,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Edad *',
                  hintText: 'Ej. 3',
                ),
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) {
                    return 'La edad es obligatoria';
                  }
                  final edad = int.tryParse(text);
                  if (edad == null || edad < 0) {
                    return 'Ingresa una edad valida';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _propietarioSeleccionado,
                items: _propietarios
                    .map(
                      (item) => DropdownMenuItem<String>(
                        value: item.id,
                        child: Text(item.nombre),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() => _propietarioSeleccionado = value);
                },
                decoration: const InputDecoration(labelText: 'Propietario *'),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_guardando ? 'Guardando...' : 'Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
