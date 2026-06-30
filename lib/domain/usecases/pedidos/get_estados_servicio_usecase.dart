import '../../entities/estado_servicio.dart';
import '../../repositories/pedidos_repository.dart';

class GetEstadosServicioUsecase {
  final PedidosRepository _repository;

  GetEstadosServicioUsecase(this._repository);

  Future<List<EstadoServicio>> call() => _repository.getEstadosServicio();
}
