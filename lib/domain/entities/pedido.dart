class Pedido {
  final int idDetalle;
  final int idVenta;
  final String? clienteNombre;
  final String? nombreServicio;
  final String? observacion;
  final String fecha;
  final int idEstado;
  final String estado;
  final double precio;

  const Pedido({
    required this.idDetalle,
    required this.idVenta,
    this.clienteNombre,
    this.nombreServicio,
    this.observacion,
    this.fecha = '',
    required this.idEstado,
    required this.estado,
    required this.precio,
  });
}
