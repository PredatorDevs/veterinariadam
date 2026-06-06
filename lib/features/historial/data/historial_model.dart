class HistorialModel {
  const HistorialModel({
    required this.id,
    required this.perroId,
    required this.fecha,
    this.peso,
    required this.diagnostico,
    this.tratamiento,
    this.observaciones,
  });

  final String id;
  final String perroId;
  final DateTime fecha;
  final double? peso;
  final String diagnostico;
  final String? tratamiento;
  final String? observaciones;

  factory HistorialModel.fromJson(Map<String, dynamic> json) {
    return HistorialModel(
      id: (json['_id'] ?? '').toString(),
      perroId: (json['perro'] ?? '').toString(),
      fecha: _toDate(json['fecha']),
      peso: _toDouble(json['peso']),
      diagnostico: (json['diagnostico'] ?? '').toString(),
      tratamiento: json['tratamiento']?.toString(),
      observaciones: json['observaciones']?.toString(),
    );
  }

  static DateTime _toDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    return parsed ?? DateTime.now();
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }
}
