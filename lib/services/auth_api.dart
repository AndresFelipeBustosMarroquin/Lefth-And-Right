import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:left_and_right/config/api_config.dart';

class AuthApiException implements Exception {
  const AuthApiException({
    required this.statusCode,
    required this.code,
    required this.message,
  });

  final int statusCode;
  final String code;
  final String message;
}

class AuthSession {
  static String? token;

  static void clear() {
    token = null;
  }
}

class AuthApi {
  static const _emailTimeoutMessage =
      'El envío está tardando más de lo esperado. Revisa tu correo y espera un minuto antes de volver a intentarlo.';

  static Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _post(
      '/register',
      {'nombre': name, 'correo': email, 'contrasena': password},
      timeout: const Duration(seconds: 60),
      timeoutMessage: _emailTimeoutMessage,
    );
  }

  static Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _post('/verify-email', {'correo': email, 'codigo': code});
  }

  static Future<void> resendVerification(String email) async {
    await _post(
      '/resend-verification',
      {'correo': email},
      timeout: const Duration(seconds: 60),
      timeoutMessage: _emailTimeoutMessage,
    );
  }

  static Future<void> requestPasswordReset(String email) async {
    await _post(
      '/forgot-password',
      {'correo': email},
      timeout: const Duration(seconds: 60),
      timeoutMessage: _emailTimeoutMessage,
    );
  }

  static Future<void> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    await _post('/verify-reset-code', {'correo': email, 'codigo': code});
  }

  static Future<void> resetPassword({
    required String email,
    required String code,
    required String password,
  }) async {
    await _post('/reset-password', {
      'correo': email,
      'codigo': code,
      'nuevaContrasena': password,
    });
  }

  static Future<String> login({
    required String email,
    required String password,
  }) async {
    final data = await _post('/login', {
      'correo': email,
      'contrasena': password,
    });
    final token = data['token'];
    if (token is! String || token.isEmpty) {
      throw const AuthApiException(
        statusCode: 502,
        code: 'INVALID_SERVER_RESPONSE',
        message: 'El servidor no devolvió una sesión válida.',
      );
    }

    AuthSession.token = token;
    return token;
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, String> body, {
    Duration timeout = const Duration(seconds: 15),
    String? timeoutMessage,
  }) async {
    late final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$authUrl$path'),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(timeout);
    } on TimeoutException {
      throw AuthApiException(
        statusCode: 0,
        code: 'REQUEST_TIMEOUT',
        message:
            timeoutMessage ?? 'El servidor tardó demasiado. Intenta de nuevo.',
      );
    } on http.ClientException {
      throw const AuthApiException(
        statusCode: 0,
        code: 'SERVER_UNAVAILABLE',
        message: 'No se pudo conectar con el servidor. Verifica la red e intenta de nuevo.',
      );
    }

    late final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      if (response.statusCode == 404) {
        throw const AuthApiException(
          statusCode: 404,
          code: 'ENDPOINT_NOT_AVAILABLE',
          message: 'El servidor no tiene habilitada esta función. Actualiza y reinicia el servidor de autenticación.',
        );
      }
      if (response.statusCode == 403) {
        throw const AuthApiException(
          statusCode: 403,
          code: 'REQUEST_FORBIDDEN',
          message: 'El servidor rechazó la solicitud. Verifica que el origen de la aplicación esté autorizado en la configuración CORS del servidor.',
        );
      }
      throw AuthApiException(
        statusCode: response.statusCode,
        code: 'INVALID_SERVER_RESPONSE',
        message:
            'El servidor devolvió una respuesta inválida (${response.statusCode}).',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw AuthApiException(
        statusCode: response.statusCode,
        code: 'INVALID_SERVER_RESPONSE',
        message:
            'El servidor devolvió una respuesta inválida (${response.statusCode}).',
      );
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException(
        statusCode: response.statusCode,
        code: decoded['code'] is String
            ? decoded['code'] as String
            : 'REQUEST_FAILED',
        message: decoded['error'] is String
            ? decoded['error'] as String
            : 'La solicitud no pudo completarse.',
      );
    }

    return decoded;
  }
}
