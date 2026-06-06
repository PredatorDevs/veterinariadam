import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../data/propietarios_repository.dart';

class PropietarioFormScreen extends StatefulWidget {
  const PropietarioFormScreen({super.key});

  @override
  State<PropietarioFormScreen> createState() => _PropietarioFormScreenState();
}

class _PropietarioFormScreenState extends State<PropietarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();

  final _repository = PropietariosRepository();

  bool _guardando = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _correoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _guardando) {
      return;
    }

    setState(() => _guardando = true);

    try {
      await _repository.crear(
        nombre: _nombreCtrl.text,
        telefono: _telefonoCtrl.text,
        direccion: _direccionCtrl.text,
        correo: _correoCtrl.text,
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
        const SnackBar(content: Text('Error inesperado al crear propietario')),
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
      appBar: AppBar(title: const Text('Nuevo Propietario')),
      drawer: const AppDrawer(currentRoute: '/propietarios'),
      body: SafeArea(
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
                    hintText: 'Ej. Ana Perez',
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'El nombre es obligatorio';
                    }
                    if (text.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _telefonoCtrl,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefono',
                    hintText: 'Ej. 5551234',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _direccionCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Direccion',
                    hintText: 'Ej. Calle 10 # 20-30',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _correoCtrl,
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    hintText: 'Ej. ana@email.com',
                  ),
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
      ),
    );
  }
}
