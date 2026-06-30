import '../../domain/entities/pedido.dart';

class PedidoModel extends Pedido {
  const PedidoModel({
    required super.idDetalle,
    required super.idVenta,
    super.nombreServicio,
    super.observacion,
    required super.idEstado,
    required super.estado,
    required super.precio,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    // Backend retorna relaciones en inglés: sale, service, serviceStatus
    final sale = json['sale'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;
    final serviceStatus = json['serviceStatus'] as Map<String, dynamic>?;

    return PedidoModel(
      idDetalle: json['id_detalle'] as int,
      idVenta: sale?['id_venta'] as int? ?? json['id_venta'] as int? ?? 0,
      nombreServicio: service?['nombre'] as String?,
      // Observación de la línea (SaleDetail), no la descripción del servicio
      observacion: json['observacion'] as String?,
      idEstado: serviceStatus?['id_estado'] as int? ?? 1,
      estado: serviceStatus?['nombre'] as String? ?? '',
      precio: double.tryParse(json['precio']?.toString() ?? '0') ?? 0.0,
    );
  }
}
