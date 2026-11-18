class NetworkResponse {
  final bool isSuccess;
  final int statusCode;
  final Map<String, dynamic>? body;
  final String? errorMessage;

  /// The status the server actually meant, which is not always [statusCode].
  /// This API wraps auth failures as HTTP 500 with the real code nested under
  /// `error.code`, so callers must consult this to detect 401/403 reliably.
  final int effectiveStatusCode;

  NetworkResponse({
    required this.isSuccess,
    required this.statusCode,
    this.body,
    this.errorMessage,
    int? effectiveStatusCode,
  }) : effectiveStatusCode = effectiveStatusCode ?? statusCode;

  /// True when the server explicitly reported `success: false` in the payload,
  /// even though the transport returned 2xx.
  bool get isServerReportedFailure => body?['success'] == false;

  bool get isUnauthorized => effectiveStatusCode == 401;

  bool get isForbidden => effectiveStatusCode == 403;

  /// `data` from the standard `{success, message, data}` envelope, or null.
  Map<String, dynamic>? get data {
    final value = body?['data'];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return value.cast<String, dynamic>();
    return null;
  }

  /// `data` when the endpoint returns a list at the top level.
  List<dynamic>? get dataList {
    final value = body?['data'];
    return value is List ? value : null;
  }
}
