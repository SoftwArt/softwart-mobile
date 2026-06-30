import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/pago.dart';
import '../../providers/pagos_provider.dart';
import '../../widgets/estado_badge.dart';

class PagoDetallePage extends StatefulWidget {
  final Pago pago;
  const PagoDetallePage({super.key, required this.pago});

  @override
  State<PagoDetallePage> createState() => _PagoDetallePageState();
}

class _PagoDetallePageState extends State<PagoDetallePage> {
  // Pendiente=1, Validado=2 — mismo orden que los seeds
  static const _estados = [
    (id: 1, nombre: 'Pendiente'),
    (id: 2, nombre: 'Validado'),
  ];

  late int _estadoSeleccionado;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _estadoSeleccionado = widget.pago.idEstadoPago;
  }

  Future<void> _guardar() async {
    if (_estadoSeleccionado == widget.pago.idEstadoPago) return;

    final provider = context.read<PagosProvider>();
    final target = _estados.firstWhere(
      (e) => e.id == _estadoSeleccionado,
      orElse: () => (id: 0, nombre: ''),
    );

    // Validar es definitivo: un pago validado queda bloqueado → confirmar
    if (target.nombre.toLowerCase() == 'validado') {
      final confirm = await _confirmarValidacion();
      if (confirm != true) return;
    }

    setState(() => _guardando = true);
    final ok = await provider.cambiarEstado(
      widget.pago.idPago,
      _estadoSeleccionado,
    );
    if (!mounted) return;
    setState(() => _guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Estado actualizado' : (provider.error ?? 'Error al actualizar'),
        ),
        backgroundColor: ok ? const Color(0xFF10B981) : AppColors.destructive,
      ),
    );
    if (ok) Navigator.of(context).pop();
  }

  Future<bool?> _confirmarValidacion() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Validar este pago?'),
        content: const Text(
          'Validar es definitivo: una vez validado, el pago no podrá '
          'cambiar de estado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Volver'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, validar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pago = widget.pago;
    final estadoColor = EstadoBadge.colorForEstado(pago.estadoPago);
    // Validado y Anulado son terminales: no se pueden modificar.
    final terminal =
        ['validado', 'anulado'].contains(pago.estadoPago.toLowerCase());

    return Scaffold(
      appBar: AppBar(title: Text('Pago #${pago.idPago}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con monto destacado
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    formatCOP(pago.monto),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pago.estadoPago,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: estadoColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(label: 'Venta', valor: '#${pago.idVenta}'),
                    _InfoRow(label: 'Fecha', valor: formatFecha(pago.fecha)),
                    _InfoRow(label: 'Método', valor: pago.metodoPago ?? '—'),
                    if (pago.observacion != null && pago.observacion!.isNotEmpty)
                      _InfoRow(label: 'Observación', valor: pago.observacion!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (terminal)
              // Estado terminal: un pago validado/anulado no se puede modificar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: estadoColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: estadoColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  'Este pago está ${pago.estadoPago.toLowerCase()} y no puede modificarse.',
                  style: TextStyle(fontSize: 13, color: estadoColor),
                ),
              )
            else ...[
              const Text(
                'Cambiar estado',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _estados.map((e) {
                  final selected = _estadoSeleccionado == e.id;
                  return GestureDetector(
                    onTap: () => setState(() => _estadoSeleccionado = e.id),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: selected ? AppColors.primary : Colors.white,
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.border,
                          width: selected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        e.nombre,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.normal,
                          color: selected ? Colors.white : AppColors.foreground,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_guardando ||
                          _estadoSeleccionado == widget.pago.idEstadoPago)
                      ? null
                      : _guardar,
                  child: _guardando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Guardar cambio'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String valor;
  const _InfoRow({required this.label, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(color: AppColors.muted, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
