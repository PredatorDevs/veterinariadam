class PerroModel {
  const PerroModel({
    required this.id,
    required this.nombre,
    required this.raza,
    required this.edad,
    required this.propietarioId,
    this.propietarioNombre,
  });

  final String id;
  final String nombre;
  final String raza;
  final int edad;
  final String propietarioId;
  final String? propietarioNombre;

  factory PerroModel.fromJson(Map<String, dynamic> json) {
    final propietarioRaw = json['propietario'];

    String propietarioId = '';
    String? propietarioNombre;

    if (propietarioRaw is Map) {
      propietarioId = (propietarioRaw['_id'] ?? '').toString();
      propietarioNombre = propietarioRaw['nombre']?.toString();
    } else {
      propietarioId = (propietarioRaw ?? '').toString();
    }

    return PerroModel(
      id: (json['_id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      raza: (json['raza'] ?? '').toString(),
      edad: _toInt(json['edad']),
      propietarioId: propietarioId,
      propietarioNombre: propietarioNombre,
    );
  }

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse('$value') ?? 0;
  }
}
