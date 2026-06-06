import '../../../core/network/app_api.dart';
import '../../../core/network/endpoints.dart';
import 'perro_model.dart';

class PerrosRepository {
  Future<List<PerroModel>> obtenerTodos() async {
    final response = await AppApi.client.get(Endpoints.perros);

    if (response is! List) {
      return const [];
    }

    return response
        .whereType<Map>()
        .map((item) => PerroModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<PerroModel> crear({
    required String nombre,
    required String raza,
    required int edad,
    required String propietarioId,
  }) async {
    final body = <String, dynamic>{
      'nombre': nombre.trim(),
      'raza': raza.trim(),
      'edad': edad,
      'propietario': propietarioId,
    };

    final response = await AppApi.client.post(Endpoints.perros, body: body);

    if (response is! Map) {
      throw Exception('Respuesta invalida al crear perro');
    }

    return PerroModel.fromJson(Map<String, dynamic>.from(response));
  }
}
