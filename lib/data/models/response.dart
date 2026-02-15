// base_response_model.dart
class BaseResponse<T> {
  final bool success;
  final String? message;
  final dynamic error;
  final int? statusCode;

  BaseResponse({
    required this.success,
    this.message,
    this.error,
    this.statusCode,
  });

  factory BaseResponse.fromMap(Map<String, dynamic> map) {
    return BaseResponse<T>(
      success: map['success'] as bool? ?? true,
      message: map['message'] as String?,
      error: map['error'],
      statusCode: map['statusCode'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'success': success,
      'message': message,
      'error': error,
      'statusCode': statusCode,
    };
  }
}