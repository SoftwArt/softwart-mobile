import '../../domain/entities/dashboard_stats.dart';

class DashboardModel extends DashboardStats {
  const DashboardModel({
    required super.ventasMes,
    required super.totalVentasMes,
    required super.citasHoy,
    required super.pedidosPendientes,
    required super.pagosPendientes,
    super.citasHoyLista,
    super.ventasRecientes,
    super.pedidosPorEstado,
    super.ventasSinPago,
    super.citasSinVenta,
    super.pedidosAtrasados,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    // El backend retorna: { kpis: {...}, citas_hoy: [...], ventas_recientes: [...], ... }
    final kpis = json['kpis'] as Map<String, dynamic>? ?? {};

    final pedidosSinEmpezar = kpis['pedidos_sin_empezar'] as int? ?? 0;
    final pedidosEnPreparacion = kpis['pedidos_en_preparacion'] as int? ?? 0;

    final citasHoyRaw = json['citas_hoy'] as List<dynamic>? ?? [];
    final ventasRecientesRaw = json['ventas_recientes'] as List<dynamic>? ?? [];
    final pedidosPorEstadoRaw =
        json['pedidos_por_estado'] as List<dynamic>? ?? [];

    final alertas = json['alertas'] as Map<String, dynamic>? ?? {};
    final ventasSinPagoRaw    = alertas['ventas_sin_pago'] as List<dynamic>? ?? [];
    final citasSinVentaRaw    = alertas['citas_sin_venta'] as List<dynamic>? ?? [];
    final pedidosAtrasadosRaw = alertas['pedidos_atrasados'] as List<dynamic>? ?? [];

    return DashboardModel(
      ventasMes: kpis['ventas_mes_actual'] as int? ?? 0,
      totalVentasMes:
          (kpis['ingresos_mes'] as num? ?? 0).toDouble(),
      citasHoy: kpis['citas_hoy'] as int? ?? citasHoyRaw.length,
      pedidosPendientes: pedidosSinEmpezar + pedidosEnPreparacion,
      pagosPendientes: (kpis['pagos_pendientes'] as num? ?? 0).toDouble(),
      citasHoyLista: citasHoyRaw.cast<Map<String, dynamic>>(),
      ventasRecientes: ventasRecientesRaw.cast<Map<String, dynamic>>(),
      pedidosPorEstado: pedidosPorEstadoRaw.cast<Map<String, dynamic>>(),
      ventasSinPago: ventasSinPagoRaw.cast<Map<String, dynamic>>(),
      citasSinVenta: citasSinVentaRaw.cast<Map<String, dynamic>>(),
      pedidosAtrasados: pedidosAtrasadosRaw.cast<Map<String, dynamic>>(),
    );
  }
}
