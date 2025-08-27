import 'package:dio/dio.dart';
import '../models/common/common_models.dart';

class MealieException implements Exception {
  final String message;
  final int? statusCode;
  final String? detail;
  final DioException? dioException;

  const MealieException({
    required this.message,
    this.statusCode,
    this.detail,
    this.dioException,
  });

  factory MealieException.fromDioException(DioException dioException) {
    String message = 'Unknown error occurred';
    String? detail;
    
    if (dioException.response?.data != null) {
      try {
        final errorResponse = ErrorResponse.fromJson(dioException.response!.data);
        message = errorResponse.message;
        detail = errorResponse.detail;
      } catch (_) {
        // If parsing fails, use the raw message
        if (dioException.response?.data is Map<String, dynamic>) {
          final data = dioException.response!.data as Map<String, dynamic>;
          message = data['message'] ?? data['error'] ?? message;
          detail = data['detail']?.toString();
        } else if (dioException.response?.data is String) {
          message = dioException.response!.data;
        }
      }
    } else if (dioException.message != null) {
      message = dioException.message!;
    }

    return MealieException(
      message: message,
      statusCode: dioException.response?.statusCode,
      detail: detail,
      dioException: dioException,
    );
  }

  bool get isNetworkError => 
      dioException?.type == DioExceptionType.connectionTimeout ||
      dioException?.type == DioExceptionType.receiveTimeout ||
      dioException?.type == DioExceptionType.sendTimeout ||
      dioException?.type == DioExceptionType.connectionError;

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;

  @override
  String toString() {
    return 'MealieException: $message${detail != null ? ' - $detail' : ''}';
  }
}