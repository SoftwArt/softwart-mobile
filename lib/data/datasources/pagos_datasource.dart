import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../../core/utils/token_storage.dart';
import '../models/pago_model.dart';

class PagosDatasource {
  Future<List<PagoModel>> getPagos() async {
    final token = await TokenStorage.getToken();
    final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.payments}?limit=500');
    final res = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (res.statusCode != 200) throw Exception('Error al cargar pagos');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;
    return data.map((e) => PagoModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // Usa el endpoint con guard (PATCH /payment-status/pago/:id/estado): el
  // backend bloquea (409) cambiar un pago Validado/Anulado. Antes usaba
  // PUT /payments/:id, que se saltaba ese bloqueo.
  Future<bool> cambiarEstadoPago(int idPago, int idEstadoPago) async {
    try {
      final token = await TokenStorage.getToken();
      final uri = Uri.parse(
        '${ApiConstants.baseUrl}${ApiConstants.changePaymentStatus(idPago)}',
      );
      final res = await http.patch(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'id_estado_pago': idEstadoPago}),
      );

      if (res.statusCode == 401) {
        throw const UnauthorizedException('Sesión expirada');
      }
      if (res.statusCode != 200) {
        // Surface el mensaje del backend (p.ej. pago validado/anulado → 409)
        String msg = 'Error al cambiar estado';
        try {
          final body = jsonDecode(res.body) as Map<String, dynamic>;
          if (body['message'] is String &&
              (body['message'] as String).isNotEmpty) {
            msg = body['message'] as String;
          }
        } catch (_) {}
        throw ServerException(msg);
      }
      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw NetworkException('Error de conexión: $e');
    }
  }
}
