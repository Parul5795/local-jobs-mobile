class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final List<String>? errors;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.errors,
  });

  factory ApiResponse.success(T data, [String? message]) {
    return ApiResponse(
      success: true,
      data: data,
      message: message,
    );
  }

  factory ApiResponse.error(String message, [List<String>? errors]) {
    return ApiResponse(
      success: false,
      message: message,
      errors: errors,
    );
  }
}
