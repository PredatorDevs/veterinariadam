import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../perros/data/perro_model.dart';
import '../data/historial_repository.dart';

class HistorialFormScreen extends StatefulWidget {
  const HistorialFormScreen({
    super.key,
    required this.perros,
    required this.initialPerroId,
  });

  final List<PerroModel> perros;
  final String initialPerroId;

  @override
  State<HistorialFormScreen> createState() => _HistorialFormScreenState();
}

class _HistorialFormScreenState extends State<HistorialFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pesoCtrl = TextEditingController();
  final _diagnosticoCtrl = TextEditingController();
  final _tratamientoCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();

  final _repository = HistorialRepository();

  bool _guardando = false;
  late String _perroSeleccionado;

  @override
  void initState() {
    super.initState();
    _perroSeleccionado = widget.initialPerroId;
  }

  @override
  void dispose() {
    _pesoCtrl.dispose();
    _diagnosticoCtrl.dispose();
    _tratamientoCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || _guardando) {
      return;
    }

    final pesoText = _pesoCtrl.text.trim();
    final peso = pesoText.isEmpty ? null : double.tryParse(pesoText);

    if (pesoText.isNotEmpty && peso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El peso debe ser un numero valido')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      await _repository.crear(
        perroId: _perroSeleccionado,
        peso: peso,
        diagnostico: _diagnosticoCtrl.text,
        tratamiento: _tratamientoCtrl.text,
        observaciones: _observacionesCtrl.text,
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
        const SnackBar(
          content: Text('Error inesperado al crear entrada de historial'),
        ),
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
      appBar: AppBar(title: const Text('Nueva Entrada Clinica')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                DropdownButtonFormField<String>(
                  value: _perroSeleccionado,
                  items: widget.perros
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
                  },
                  decoration: const InputDecoration(labelText: 'Perro *'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pesoCtrl,
                  textInputAction: TextInputAction.next,
                  keyboardType: const TextInputType.numberWithOptions(
                    signed: false,
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Peso (kg)',
                    hintText: 'Ej. 12.5',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _diagnosticoCtrl,
                  textInputAction: TextInputAction.next,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Diagnostico *',
                    hintText: 'Ej. Otitis leve',
                  ),
                  validator: (value) {
                    final text = value?.trim() ?? '';
                    if (text.isEmpty) {
                      return 'El diagnostico es obligatorio';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tratamientoCtrl,
                  textInputAction: TextInputAction.next,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Tratamiento',
                    hintText: 'Ej. Gotas por 7 dias',
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _observacionesCtrl,
                  textInputAction: TextInputAction.done,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Observaciones',
                    hintText: 'Ej. Control en 10 dias',
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
