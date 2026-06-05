import 'package:dio/dio.dart';

class ErrorHandler {
  static String getFriendlyMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'No se pudo conectar al servidor. Revisa tu conexión a internet o vuelve a intentarlo.';
        case DioExceptionType.badResponse:
          final status = error.response?.statusCode;
          final responseData = error.response?.data;
          
          // Tratar de extraer el mensaje descriptivo del backend si existe
          if (responseData is Map && responseData.containsKey('detail')) {
            final detail = responseData['detail'].toString();
            final detailLower = detail.toLowerCase();
            
            // Traducir mensajes conocidos en inglés a español amigable
            if (detailLower.contains('incorrect email or password') ||
                detailLower.contains('invalid credentials') ||
                detailLower.contains('incorrect password') ||
                detailLower.contains('invalid email or password')) {
              return 'Correo o contraseña incorrectos. Por favor, verifica e intenta de nuevo.';
            }
            if (detailLower.contains('not authenticated') ||
                detailLower.contains('unauthorized')) {
              return 'No estás autenticado o tu sesión ha expirado. Inicia sesión.';
            }
            if (detailLower.contains('email already registered') ||
                detailLower.contains('user already exists') ||
                detailLower.contains('email already exists')) {
              return 'Este correo electrónico ya está registrado. Intenta con otro.';
            }
            return detail;
          }

          if (status == 401) {
            return 'Tu sesión ha expirado. Por favor, inicia sesión de nuevo.';
          } else if (status == 403) {
            return 'No tienes permisos para realizar esta acción.';
          } else if (status == 404) {
            return 'No se encontró el recurso solicitado en el servidor.';
          } else if (status == 500) {
            return 'Error en el servidor. Por favor, intenta de nuevo más tarde o repórtalo.';
          }
          
          return 'Error en el servidor (${status ?? 'Desconocido'}).';
        case DioExceptionType.cancel:
          return 'La solicitud fue cancelada.';
        case DioExceptionType.connectionError:
          return 'No hay conexión de red. Verifica tu internet y vuelve a intentarlo.';
        default:
          return 'Ocurrió un error inesperado al comunicarse con el servidor.';
      }
    }
    
    final errorStr = error.toString();
    if (errorStr.startsWith('Exception:')) {
      return errorStr.replaceFirst('Exception:', '').trim();
    }
    return errorStr;
  }
}
