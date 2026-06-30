import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/entities/estado_servicio.dart';
import '../models/pedido_model.dart';
import '../models/estado_servicio_model.dart';

class PedidosDatasource {
  Future<List<PedidoModel>> getPedidos(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.saleDetails}?limit=500'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        throw const UnauthorizedException('Sesión expirada');
      }
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al cargar pedidos (${response.statusCode})',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;
      return data
          .map((e) => PedidoModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Error de conexión: $e');
    }
  }

  Future<List<EstadoServicio>> getEstadosServicio(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.serviceStatus}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        throw const UnauthorizedException('Sesión expirada');
      }
      if (response.statusCode != 200) {
        throw ServerException(
          'Error al cargar estados (${response.statusCode})',
        );
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as List<dynamic>;
      return data
          .map((e) => EstadoServicioModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Error de conexión: $e');
    }
  }

  Future<void> cambiarEstado({
    required String token,
    required int idDetalle,
    required int idEstado,
  }) async {
    try {
      final response = await http.patch(
        Uri.parse(
          '${ApiConstants.baseUrl}${ApiConstants.changeSaleDetailStatus(idDetalle)}',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'id_estado': idEstado}),
      );

      if (response.statusCode == 401) {
        throw const UnauthorizedException('Sesión expirada');
      }
      if (response.statusCode != 200) {
        // Surface the backend message (p.ej. servicio cancelado → 409)
        throw ServerException(_mensajeError(response, 'Error al cambiar estado'));
      }
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Error de conexión: $e');
    }
  }

  // Extrae { message } del body cuando el backend devuelve un error
  String _mensajeError(http.Response response, String fallback) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final msg = body['message'];
      if (msg is String && msg.isNotEmpty) return msg;
    } catch (_) {}
    return fallback;
  }
}
