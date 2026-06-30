import '../../domain/entities/pedido.dart';

class PedidoModel extends Pedido {
  const PedidoModel({
    required super.idDetalle,
    required super.idVenta,
    super.clienteNombre,
    super.nombreServicio,
    super.observacion,
    super.fecha,
    required super.idEstado,
    required super.estado,
    required super.precio,
  });

  factory PedidoModel.fromJson(Map<String, dynamic> json) {
    // Backend retorna relaciones en inglés: sale, sale.client, service, serviceStatus
    final sale = json['sale'] as Map<String, dynamic>?;
    final client = sale?['client'] as Map<String, dynamic>?;
    final service = json['service'] as Map<String, dynamic>?;
    final serviceStatus = json['serviceStatus'] as Map<String, dynamic>?;

    return PedidoModel(
      idDetalle: json['id_detalle'] as int,
      idVenta: sale?['id_venta'] as int? ?? json['id_venta'] as int? ?? 0,
      clienteNombre: client?['nombre'] as String?,
      nombreServicio: service?['nombre'] as String?,
      // Observación de la línea (SaleDetail), no la descripción del servicio
      observacion: json['observacion'] as String?,
      fecha: json['fecha']?.toString() ?? '',
      idEstado: serviceStatus?['id_estado'] as int? ?? 1,
      estado: serviceStatus?['nombre'] as String? ?? '',
      precio: double.tryParse(json['precio']?.toString() ?? '0') ?? 0.0,
    );
  }
}
