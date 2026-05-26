import 'package:dio/dio.dart';

class ApiErrorHandler {
  ApiErrorHandler._();

  static String parse(DioException e) => parseError(e);

  static String parseError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Connection timed out. Check your internet.';
      case DioExceptionType.receiveTimeout:
        return 'Server took too long. Try again.';
      case DioExceptionType.connectionError:
        return 'Unable to connect. Check your internet and try again.';
      default:
        break;
    }

    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (statusCode == 400) {
      final message = _extractMessage(data);
      return message ?? 'Invalid request. Please check your input.';
    }

    if (statusCode == 401) {
      return 'Session expired. Please log in again.';
    }

    if (statusCode == 403) {
      return 'You don\'t have permission to do this.';
    }

    if (statusCode == 404) {
      return _extractMessage(data) ?? 'Not found.';
    }

    if (statusCode == 500) {
      return _extractMessage(data) ?? 'Something went wrong on our end. Try again.';
    }

    return _extractMessage(data) ?? 'Please try again.';
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      final error = data['error'];
      if (error is String && error.trim().isNotEmpty) {
        return error.trim();
      }

      final message = data['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }

    return null;
  }
}
