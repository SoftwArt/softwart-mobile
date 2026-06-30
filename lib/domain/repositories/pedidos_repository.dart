import '../entities/pedido.dart';
import '../entities/estado_servicio.dart';

abstract class PedidosRepository {
  Future<List<Pedido>> getPedidos();
  Future<List<EstadoServicio>> getEstadosServicio();
  Future<void> cambiarEstado({required int idDetalle, required int idEstado});
}
