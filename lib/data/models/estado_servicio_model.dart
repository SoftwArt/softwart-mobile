import '../../domain/entities/estado_servicio.dart';

class EstadoServicioModel {
  static EstadoServicio fromJson(Map<String, dynamic> json) => EstadoServicio(
        id: (json['id_estado'] ?? 0) as int,
        nombre: (json['nombre'] ?? '') as String,
      );
}
