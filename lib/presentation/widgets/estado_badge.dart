import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class EstadoBadge extends StatelessWidget {
  final String texto;
  final Color? color;

  const EstadoBadge({super.key, required this.texto, this.color});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? colorForEstado(texto);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: bg.withOpacity(0.4)),
      ),
      child: Text(
        texto,
        style: TextStyle(
          color: bg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static Color colorForEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return const Color(0xFFF59E0B); // amber
      case 'completada':
      case 'finalizado':
      case 'validado':
        return const Color(0xFF10B981); // green
      case 'cancelada':
      case 'cancelado':
      case 'anulado':
      case 'no asistió':
        return AppColors.destructive;
      case 'en preparación':
        return AppColors.secondary;
      case 'sin empezar':
        return AppColors.muted;
      default:
        return AppColors.muted;
    }
  }
}
