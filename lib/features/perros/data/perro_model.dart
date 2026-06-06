class PerroModel {
  const PerroModel({
    required this.id,
    required this.nombre,
    required this.raza,
    required this.edad,
    required this.propietarioId,
    this.propietarioNombre,
    this.propietarioTelefono,
    this.propietarioDireccion,
    this.propietarioCorreo,
  });

  final String id;
  final String nombre;
  final String raza;
  final int edad;
  final String propietarioId;
  final String? propietarioNombre;
  final String? propietarioTelefono;
  final String? propietarioDireccion;
  final String? propietarioCorreo;

  factory PerroModel.fromJson(Map<String, dynamic> json) {
    final propietarioRaw = json['propietario'];

    String propietarioId = '';
    String? propietarioNombre;
    String? propietarioTelefono;
    String? propietarioDireccion;
    String? propietarioCorreo;

    if (propietarioRaw is Map) {
      propietarioId = (propietarioRaw['_id'] ?? '').toString();
      propietarioNombre = propietarioRaw['nombre']?.toString();
      propietarioTelefono = propietarioRaw['telefono']?.toString();
      propietarioDireccion = propietarioRaw['direccion']?.toString();
      propietarioCorreo = propietarioRaw['correo']?.toString();
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
      propietarioTelefono: propietarioTelefono,
      propietarioDireccion: propietarioDireccion,
      propietarioCorreo: propietarioCorreo,
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
