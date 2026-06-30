class DashboardStats {
  final int ventasMes;
  final double totalVentasMes;
  final int citasHoy;
  final int pedidosPendientes;
  final double pagosPendientes;
  // Listas enriquecidas del backend
  final List<Map<String, dynamic>> citasHoyLista;
  final List<Map<String, dynamic>> ventasRecientes;
  final List<Map<String, dynamic>> pedidosPorEstado;
  // Alertas operativas (mismas que el dashboard web)
  final List<Map<String, dynamic>> ventasSinPago;
  final List<Map<String, dynamic>> citasSinVenta;
  final List<Map<String, dynamic>> pedidosAtrasados;

  const DashboardStats({
    required this.ventasMes,
    required this.totalVentasMes,
    required this.citasHoy,
    required this.pedidosPendientes,
    required this.pagosPendientes,
    this.citasHoyLista = const [],
    this.ventasRecientes = const [],
    this.pedidosPorEstado = const [],
    this.ventasSinPago = const [],
    this.citasSinVenta = const [],
    this.pedidosAtrasados = const [],
  });
}
