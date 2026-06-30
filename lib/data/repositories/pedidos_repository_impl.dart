import '../../core/errors/exceptions.dart';
import '../../core/utils/token_storage.dart';
import '../../domain/entities/pedido.dart';
import '../../domain/entities/estado_servicio.dart';
import '../../domain/repositories/pedidos_repository.dart';
import '../datasources/pedidos_datasource.dart';

class PedidosRepositoryImpl implements PedidosRepository {
  final PedidosDatasource _datasource;

  PedidosRepositoryImpl(this._datasource);

  Future<String> _getToken() async {
    final token = await TokenStorage.getToken();
    if (token == null) throw const UnauthorizedException('Sin sesión activa');
    return token;
  }

  @override
  Future<List<Pedido>> getPedidos() async {
    return _datasource.getPedidos(await _getToken());
  }

  @override
  Future<List<EstadoServicio>> getEstadosServicio() async {
    return _datasource.getEstadosServicio(await _getToken());
  }

  @override
  Future<void> cambiarEstado({
    required int idDetalle,
    required int idEstado,
  }) async {
    await _datasource.cambiarEstado(
      token: await _getToken(),
      idDetalle: idDetalle,
      idEstado: idEstado,
    );
  }
}
