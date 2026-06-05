import 'package:dio/dio.dart';

class AppErrorHandler {
  static String format(dynamic error) {
    if (error is String) return error;

    if (error is DioException) {
      final responseData = error.response?.data;
      if (responseData is Map<String, dynamic>) {
        if (responseData['error'] is Map<String, dynamic>) {
          final errorMap = responseData['error'] as Map<String, dynamic>;
          final message = errorMap['message'] as String?;
          if (message != null && message.isNotEmpty) {
            return message;
          }
        }
        final message = responseData['message'] as String?;
        if (message != null && message.isNotEmpty) {
          return message;
        }
      }
      
      // Fallback message from Dio
      final dioMessage = error.message;
      if (dioMessage != null && dioMessage.isNotEmpty) {
        return dioMessage;
      }
    }
    
    try {
      if (error?.message != null) return error.message;
      if (error?.toString() != null) return error.toString();
    } catch (_) {}
    
    return 'An unexpected error occurred';
  }
}

