class PropietarioModel {
  const PropietarioModel({
    required this.id,
    required this.nombre,
    this.telefono,
    this.direccion,
    this.correo,
  });

  final String id;
  final String nombre;
  final String? telefono;
  final String? direccion;
  final String? correo;

  factory PropietarioModel.fromJson(Map<String, dynamic> json) {
    return PropietarioModel(
      id: (json['_id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      telefono: json['telefono']?.toString(),
      direccion: json['direccion']?.toString(),
      correo: json['correo']?.toString(),
    );
  }
}
