import 'package:flutter/material.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/entities/estado_servicio.dart';
import '../../domain/usecases/pedidos/get_pedidos_usecase.dart';
import '../../domain/usecases/pedidos/get_estados_servicio_usecase.dart';
import '../../domain/usecases/pedidos/cambiar_estado_pedido_usecase.dart';

class PedidosProvider extends ChangeNotifier {
  final GetPedidosUsecase _getPedidosUsecase;
  final GetEstadosServicioUsecase _getEstadosUsecase;
  final CambiarEstadoPedidoUsecase _cambiarEstadoUsecase;

  PedidosProvider({
    required GetPedidosUsecase getPedidosUsecase,
    required GetEstadosServicioUsecase getEstadosUsecase,
    required CambiarEstadoPedidoUsecase cambiarEstadoUsecase,
  })  : _getPedidosUsecase = getPedidosUsecase,
        _getEstadosUsecase = getEstadosUsecase,
        _cambiarEstadoUsecase = cambiarEstadoUsecase;

  bool _isLoading = false;
  String? _error;
  List<Pedido> _pedidos = [];
  List<EstadoServicio> _estados = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Pedido> get pedidos => _pedidos;
  List<EstadoServicio> get estados => _estados;

  Future<void> cargar() async {
    final primeraCarga = _pedidos.isEmpty;
    if (primeraCarga) {
      _isLoading = true;
      notifyListeners();
    }

    try {
      final data = await _getPedidosUsecase();
      // Más nuevos primero (fecha desc; desempate por id desc)
      data.sort((a, b) {
        final c = b.fecha.compareTo(a.fecha);
        return c != 0 ? c : b.idDetalle.compareTo(a.idDetalle);
      });
      _pedidos = data;
      // Catálogo de estados (incluye "Cancelado") con sus ids reales del backend
      if (_estados.isEmpty) {
        _estados = await _getEstadosUsecase();
      }
      _error = null;
    } catch (e) {
      if (primeraCarga) _error = e is AppException ? e.message : 'Error al cargar pedidos';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstado(int idDetalle, int idEstado) async {
    try {
      await _cambiarEstadoUsecase(idDetalle: idDetalle, idEstado: idEstado);
      await cargar();
      return true;
    } catch (e) {
      _error = e is AppException ? e.message : 'Error al cambiar estado';
      notifyListeners();
      return false;
    }
  }
}
