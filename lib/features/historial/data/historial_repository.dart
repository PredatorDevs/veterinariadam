import '../../../core/network/app_api.dart';
import '../../../core/network/endpoints.dart';
import 'historial_model.dart';

class HistorialRepository {
  Future<List<HistorialModel>> obtenerPorPerro(String perroId) async {
    final response = await AppApi.client.get('${Endpoints.historial}/$perroId');

    if (response is! List) {
      return const [];
    }

    return response
        .whereType<Map>()
        .map((item) => HistorialModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<HistorialModel> crear({
    required String perroId,
    double? peso,
    required String diagnostico,
    String? tratamiento,
    String? observaciones,
  }) async {
    final body = <String, dynamic>{
      'perro': perroId,
      'diagnostico': diagnostico.trim(),
    };

    if (peso != null) {
      body['peso'] = peso;
    }
    if (tratamiento != null && tratamiento.trim().isNotEmpty) {
      body['tratamiento'] = tratamiento.trim();
    }
    if (observaciones != null && observaciones.trim().isNotEmpty) {
      body['observaciones'] = observaciones.trim();
    }

    final response = await AppApi.client.post(Endpoints.historial, body: body);

    if (response is! Map) {
      throw Exception('Respuesta invalida al crear historial');
    }

    return HistorialModel.fromJson(Map<String, dynamic>.from(response));
  }
}
