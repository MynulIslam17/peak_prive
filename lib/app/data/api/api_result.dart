import '../models/network_response.dart';
import 'json_read.dart';

/// `meta` on list responses: `{page, limit, total, totalPages, unread?}`.
class PageMeta {
  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    this.unread,
  });

  /// Used when a list response has no `meta` (single page).
  factory PageMeta.single(int count) => PageMeta(
        page: 1,
        limit: count,
        total: count,
        totalPages: count == 0 ? 0 : 1,
      );

  factory PageMeta.fromJson(Json? json, {int fallbackCount = 0}) {
    if (json == null) return PageMeta.single(fallbackCount);
    return PageMeta(
      page: readInt(json['page']) ?? 1,
      limit: readInt(json['limit']) ?? fallbackCount,
      total: readInt(json['total']) ?? fallbackCount,
      totalPages: readInt(json['totalPages']) ?? 1,
      unread: readInt(json['unread']),
    );
  }

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  /// Notifications only.
  final int? unread;

  bool get hasMore => page < totalPages;
}

/// One page of a list endpoint.
class Paged<T> {
  const Paged(this.items, this.meta);

  final List<T> items;
  final PageMeta meta;

  bool get hasMore => meta.hasMore;
}

/// Field error from a 400: `errors: [{field, message}]`.
class FieldError {
  const FieldError(this.field, this.message);
  final String field;
  final String message;
}

/// Why a call failed, in a form screens can act on.
class ApiFailure {
  const ApiFailure({
    required this.message,
    required this.statusCode,
    this.fieldErrors = const [],
  });

  factory ApiFailure.fromResponse(NetworkResponse r) {
    final body = r.body;
    return ApiFailure(
      message: r.errorMessage ??
          readString(body?['message']) ??
          'Something went wrong. Please try again.',
      statusCode: r.effectiveStatusCode,
      fieldErrors: readList(
        body?['errors'],
        (e) => FieldError(
          readString(e['field']) ?? '',
          readString(e['message']) ?? '',
        ),
      ),
    );
  }

  /// A response we could not read (wrong shape).
  factory ApiFailure.badShape() => const ApiFailure(
        message: 'Unexpected server response. Please try again.',
        statusCode: -2,
      );

  final String message;

  /// HTTP status; -1 = no connection / timeout, -2 = unreadable response.
  final int statusCode;
  final List<FieldError> fieldErrors;

  bool get isOffline => statusCode == -1;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;

  /// The booking or listing changed meanwhile: refresh the screen.
  bool get isConflict => statusCode == 409;

  /// 402: payment missing, or an unpaid late fee blocks new bookings.
  bool get isPaymentRequired => statusCode == 402;

  /// 5xx: try again later.
  bool get isServerError => statusCode >= 500;

  String? fieldMessage(String field) {
    for (final e in fieldErrors) {
      if (e.field == field) return e.message;
    }
    return null;
  }

  @override
  String toString() => 'ApiFailure($statusCode, $message)';
}

/// Result of an API call: either [data] or a [failure].
class ApiResult<T> {
  const ApiResult.success(T this.data, {this.message, this.meta})
      : failure = null;

  const ApiResult.failed(ApiFailure this.failure)
      : data = null,
        message = null,
        meta = null;

  final T? data;
  final ApiFailure? failure;

  /// The server's `message` on success (e.g. "Booking cancelled.").
  final String? message;
  final PageMeta? meta;

  bool get isSuccess => failure == null;

  /// Message to show for a failure.
  String get errorMessage => failure?.message ?? '';

  /// Converts the payload, keeping failures as they are.
  ApiResult<R> map<R>(R Function(T data) convert) {
    if (failure != null) return ApiResult.failed(failure!);
    return ApiResult.success(convert(data as T), message: message, meta: meta);
  }
}
