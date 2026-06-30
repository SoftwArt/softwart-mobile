import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../../core/errors/exceptions.dart';
import '../models/cita_model.dart';

class CitasDatasource {
  Future<List<CitaModel>> getCitas(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.appointments}?limit=500'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
          );
    
          if (response.statusCode == 401) {
            throw const UnauthorizedException('Sesión expirada');
          }
          if (response.statusCode != 200) {
            throw ServerException('Error al cargar citas (${response.statusCode})');
          }
    
          final body = jsonDecode(response.body) as Map<String, dynamic>;
          final data = body['data'] as List<dynamic>;
          return data
              .map((e) => CitaModel.fromJson(e as Map<String, dynamic>))
              .toList();
        } on AppException {
          rethrow;
    }     catch (e) {
          throw NetworkException('Error de conexión: $e');
    }    
  }    
    
  Future<void> cambiarEstado({
        required String token,
    required int idCita,
    required int idEstado,
  }) async {
    try {
      final response = await http.patch(
            Uri.parse(
              '${ApiConstants.baseUrl}${ApiConstants.changeAppointmentStatus(idCita)}',
            ),
             
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'id_estado_cita': idEstado}),
      );    
    
      if (    response.statusCode == 401) {
            throw const UnauthorizedException('Sesión expirada');
          }
          if (response.statusCode != 200) {
            String msg = 'Error al cambiar estado';
            try {
              final body = jsonDecode(response.body) as Map<String, dynamic>;
              if (body['message'] is String &&
                  (body['message'] as String).isNotEmpty) {
                msg = body['message'] as String;
              }
            } catch (_) {}
            throw ServerException(msg);
          }
        } on AppException {
          rethrow;
        } catch (e) {
      throw NetworkException('Error de conexión: $e');
    }
  }
}
