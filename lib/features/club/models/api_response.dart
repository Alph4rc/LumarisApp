/// API 响应包装类
///
/// 用于统一处理所有 API 响应,包含状态码、错误信息、数据等
class ApiResponse<T> {
  /// HTTP 状态码
  final int code;

  /// 业务错误码
  final int errorCode;

  /// 响应消息
  final String message;

  /// 详细错误信息
  final String? detail;

  /// 响应数据
  final T? data;

  /// 请求ID,用于追踪
  final String? requestId;

  /// 时间戳
  final String? timestamp;

  ApiResponse({
    required this.code,
    required this.errorCode,
    required this.message,
    this.detail,
    this.data,
    this.requestId,
    this.timestamp,
  });

  /// 从 JSON 创建 ApiResponse
  ///
  /// [json] JSON 对象
  /// [fromJsonT] 可选的数据转换函数,用于将 data 字段转换为特定类型
  factory ApiResponse.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic)? fromJsonT,
  }) {
    return ApiResponse<T>(
      code: json['code'] ?? 0,
      errorCode: json['errorCode'] ?? 0,
      message: json['message'] ?? '',
      detail: json['detail'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      requestId: json['requestId'],
      timestamp: json['timestamp'],
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'errorCode': errorCode,
      'message': message,
      'detail': detail,
      'data': data,
      'requestId': requestId,
      'timestamp': timestamp,
    };
  }

  /// 判断请求是否成功
  ///
  /// 通常 code 为 200 且 errorCode 为 0 表示成功
  bool get isSuccess => code == 200 && errorCode == 0;

  /// 判断是否有错误
  bool get hasError => !isSuccess;

  /// 获取错误信息
  ///
  /// 优先返回 detail,如果没有则返回 message
  String get errorMessage => detail ?? message;

  @override
  String toString() {
    return 'ApiResponse(code: $code, errorCode: $errorCode, message: $message, data: $data)';
  }
}
