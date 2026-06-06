import '../../../core/network/app_api.dart';
import '../../../core/network/endpoints.dart';
import 'propietario_model.dart';

class PropietariosRepository {
  Future<List<PropietarioModel>> obtenerTodos() async {
    final response = await AppApi.client.get(Endpoints.propietarios);

    if (response is! List) {
      return const [];
    }

    return response
        .whereType<Map>()
        .map(
          (item) => PropietarioModel.fromJson(Map<String, dynamic>.from(item)),
        )
        .toList();
  }

  Future<PropietarioModel> crear({
    required String nombre,
    String? telefono,
    String? direccion,
    String? correo,
  }) async {
    final body = <String, dynamic>{'nombre': nombre.trim()};

    if (telefono != null && telefono.trim().isNotEmpty) {
      body['telefono'] = telefono.trim();
    }
    if (direccion != null && direccion.trim().isNotEmpty) {
      body['direccion'] = direccion.trim();
    }
    if (correo != null && correo.trim().isNotEmpty) {
      body['correo'] = correo.trim();
    }

    final response = await AppApi.client.post(
      Endpoints.propietarios,
      body: body,
    );

    if (response is! Map) {
      throw Exception('Respuesta invalida al crear propietario');
    }

    return PropietarioModel.fromJson(Map<String, dynamic>.from(response));
  }
}
