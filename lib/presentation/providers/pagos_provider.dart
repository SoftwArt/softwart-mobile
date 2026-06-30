import 'package:flutter/material.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/pago.dart';
import '../../domain/usecases/pagos/get_pagos_usecase.dart';
import '../../domain/usecases/pagos/cambiar_estado_pago_usecase.dart';

class PagosProvider extends ChangeNotifier {
  final GetPagosUsecase _getPagosUsecase;
  final CambiarEstadoPagoUsecase _cambiarEstadoUsecase;

  PagosProvider({
    required GetPagosUsecase getPagosUsecase,
    required CambiarEstadoPagoUsecase cambiarEstadoUsecase,
  })  : _getPagosUsecase = getPagosUsecase,
        _cambiarEstadoUsecase = cambiarEstadoUsecase;

  List<Pago> _pagos = [];
  bool _isLoading = false;
  String? _error;
  String? _filtroEstado;

  List<Pago> get pagos {
    if (_filtroEstado == null) return _pagos;
    return _pagos.where((p) => p.estadoPago == _filtroEstado).toList();
  }

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get filtroEstado => _filtroEstado;

  void setFiltro(String? estado) {
    _filtroEstado = estado;
    notifyListeners();
  }

  Future<void> cargar() async {
    final primeraCarga = _pagos.isEmpty;
    if (primeraCarga) {
      _isLoading = true;
      notifyListeners();
    }
    try {
      final data = await _getPagosUsecase();
      data.sort((a, b) {
        final c = b.fecha.compareTo(a.fecha);
        return c != 0 ? c : b.idPago.compareTo(a.idPago);
      });
      _pagos = data;
      _error = null;
    } catch (e) {
      if (primeraCarga) _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarEstado(int idPago, int idEstadoPago) async {
    _error = null;
    try {
      await _cambiarEstadoUsecase(idPago, idEstadoPago);
      await cargar();
      return true;
    } catch (e) {
      _error = e is AppException ? e.message : 'Error al cambiar estado';
      notifyListeners();
      return false;
    }
  }
}
