import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:logger/logger.dart';
import 'package:mime/mime.dart';

import '../../models/network_response.dart';

class NetworkCaller {
  final String _defaultErrorMessage = 'Something went wrong. Please try again.';
  final Logger _logger = Logger();

  static const Duration _requestTimeout = Duration(seconds: 30);
  static const Duration _uploadTimeout = Duration(seconds: 120);

  final VoidCallback onUnAuthorize;
  final String Function() accessToken;

  /// Exchanges the refresh token for a new access token.
  /// Null keeps the old behaviour: a 401 ends the session immediately.
  final Future<bool> Function()? refreshSession;

  /// Injected in tests (`MockClient`); a real client otherwise.
  final http.Client _http;

  final _AuthRecovery _recovery = _AuthRecovery();
  int _generation = 0;
  bool _sessionEnded = false;

  NetworkCaller({
    required this.onUnAuthorize,
    required this.accessToken,
    this.refreshSession,
    http.Client? client,
  }) : _http = client ?? http.Client();

  /// A new login may follow a failed refresh. Later 401s can refresh again.
  void resetAuthRecovery() {
    _recovery.gaveUp = false;
    _sessionEnded = false;
  }

  // ===========================================================
  // DECODING
  // Never throws. A proxy or gateway can return HTML or an empty
  // body, and a thrown FormatException there used to surface as a
  // generic failure that hid the real status code.
  // ===========================================================
  Map<String, dynamic>? _safeDecode(String responseBody) {
    if (responseBody.isEmpty) return null;
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return decoded.cast<String, dynamic>();
      // Some endpoints return a bare list; normalise it into the envelope
      // shape so callers can always read `body['data']`.
      if (decoded is List) return {'data': decoded};
      return null;
    } catch (_) {
      return null;
    }
  }

  // ===========================================================
  // EFFECTIVE STATUS CODE
  // This API reports auth failures as HTTP 500 with the real code
  // nested under `error.code`, e.g.
  //   {"success":false,"message":"Please provide your token.",
  //    "error":{"code":401,"name":"AppError"}}
  // Without unwrapping it, an expired session is never detected and
  // every screen sits on a permanent error instead of returning to login.
  // ===========================================================
  int _effectiveStatusCode(int statusCode, Map<String, dynamic>? decoded) {
    if (decoded == null) return statusCode;

    final nested = decoded['error'];
    if (nested is Map) {
      final nestedCode = _asStatusCode(nested['code'] ?? nested['statusCode']);
      if (nestedCode != null) return nestedCode;
    }

    final topLevel = _asStatusCode(decoded['code'] ?? decoded['statusCode']);
    // Only trust a top-level code when the transport itself failed, otherwise a
    // successful payload that happens to carry `code: 0` would be misread.
    if (topLevel != null && statusCode >= 400) return topLevel;

    return statusCode;
  }

  int? _asStatusCode(dynamic value) {
    final parsed = value is int ? value : int.tryParse(value?.toString() ?? '');
    if (parsed == null) return null;
    // Guard against payloads that use `code` for something unrelated.
    return parsed >= 100 && parsed <= 599 ? parsed : null;
  }

  // ===========================================================
  // CENTRAL STATUS CODE → ERROR MESSAGE RESOLVER
  // Controllers never need to touch a status code directly.
  // Always tries the server's own "message" field first.
  // ===========================================================
  String _resolveErrorMessage(int statusCode, Map<String, dynamic>? decoded, {bool checksCredentials = false}) {
    final rawMessage = decoded?['message'];
    final serverMsg = rawMessage is String && rawMessage.trim().isNotEmpty
        ? rawMessage.trim()
        : null;

    switch (statusCode) {
      case 400:
        return serverMsg ?? 'Bad request. Please check your input.';
      case 401:
        // On login / change password a 401 means "wrong password", not an
        // expired session: show the server's reason.
        if (checksCredentials) return serverMsg ?? 'Incorrect password.';
        return 'Session expired. Please log in again.';
      case 403:
        return serverMsg ?? 'You don\'t have permission to perform this action.';
      case 404:
        return serverMsg ?? 'The requested resource was not found.';
      case 408:
        return serverMsg ?? 'Request timed out. Please try again.';
      case 409:
        return serverMsg ?? 'Conflict. This resource already exists.';
      case 422:
        return serverMsg ?? 'Invalid data submitted. Please review your input.';
      case 429:
        return serverMsg ??
            'Too many requests. Please wait a moment and try again.';
      case 500:
        return serverMsg ?? 'Server error. Please try again later.';
      case 502:
        return serverMsg ?? 'Bad gateway. The server is temporarily unavailable.';
      case 503:
        return serverMsg ?? 'Service unavailable. Please try again later.';
      case 504:
        return serverMsg ??
            'Gateway timeout. Please check your connection and try again.';
      default:
        return serverMsg ?? _defaultErrorMessage;
    }
  }

  // ===========================================================
  // CENTRAL RESPONSE HANDLER
  // Single place where success, auth and error messages are decided,
  // so no verb can drift from the others.
  // ===========================================================
  NetworkResponse _buildResponse({
    required int statusCode,
    required String responseBody,
    required bool isFromLogin,
  }) {
    final decoded = _safeDecode(responseBody);
    final effective = _effectiveStatusCode(statusCode, decoded);

    final transportOk = statusCode >= 200 && statusCode < 300;
    final serverOk = decoded?['success'] != false;

    if (transportOk && serverOk && effective < 400) {
      return NetworkResponse(
        isSuccess: true,
        statusCode: statusCode,
        effectiveStatusCode: effective,
        body: decoded,
      );
    }

    return NetworkResponse(
      isSuccess: false,
      statusCode: statusCode,
      effectiveStatusCode: effective,
      body: decoded,
      errorMessage: _resolveErrorMessage(effective, decoded, checksCredentials: isFromLogin),
    );
  }

  NetworkResponse _buildExceptionResponse(Object error) {
    return NetworkResponse(
      isSuccess: false,
      statusCode: -1,
      effectiveStatusCode: -1,
      errorMessage: _networkExceptionMessage(error),
    );
  }

  // ===========================================================
  // UNAUTHORIZED RECOVERY
  // The first 401 starts one refresh. Every other request waits, then
  // runs once with the new access token. A failed refresh logs out once.
  // ===========================================================
  bool _skipsRefresh(String url) {
    final path = Uri.tryParse(url)?.path ?? url;
    return path.endsWith('/auth/login') ||
        path.endsWith('/auth/register') ||
        path.endsWith('/auth/refresh-token') ||
        path.endsWith('/auth/logout') ||
        path.endsWith('/auth/change-password') ||
        path.endsWith('/auth/verify-otp') ||
        path.endsWith('/auth/forgot-password') ||
        path.endsWith('/auth/reset-password') ||
        path.endsWith('/auth/resend-otp');
  }

  Future<NetworkResponse> _send({
    required String url,
    required bool recoverAuth,
    required Future<NetworkResponse> Function() request,
  }) {
    return _withRecovery(
      request,
      recoverable: recoverAuth && !_skipsRefresh(url),
    );
  }

  Future<NetworkResponse> _withRecovery(
    Future<NetworkResponse> Function() request, {
    required bool recoverable,
  }) async {
    if (!recoverable || refreshSession == null) {
      final response = await request();
      if (recoverable && refreshSession == null && response.isUnauthorized) {
        _unauthorizedOnce();
      }
      return response;
    }

    await _recovery.waitIfRefreshing();
    final generation = _generation;
    var response = await request();
    if (!response.isUnauthorized) return response;

    // This request left with the previous access token while a refresh
    // that was already running finished. Replay it; do not refresh again.
    if (generation != _generation) {
      response = await request();
      if (response.isUnauthorized) _unauthorizedOnce();
      return response;
    }

    if (_recovery.gaveUp) {
      _unauthorizedOnce();
      return response;
    }

    final refreshed = await _recovery.refreshOnce(() async {
      final ok = await refreshSession!();
      if (ok) _generation++;
      return ok;
    });
    if (!refreshed) {
      _unauthorizedOnce();
      return response;
    }

    response = await request();
    if (response.isUnauthorized) _unauthorizedOnce();
    return response;
  }

  void _unauthorizedOnce() {
    if (_sessionEnded) return;
    _sessionEnded = true;
    onUnAuthorize();
  }

  Map<String, String> _headers({
    bool json = true,
    String? overrideToken,
    bool authorize = true,
  }) {
    final token = authorize ? (overrideToken ?? accessToken()) : '';
    return {
      if (json) 'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ===========================================================
  // GET REQUEST
  // ===========================================================
  Future<NetworkResponse> getRequest({required String url, bool recoverAuth = true}) {
    return _send(
      url: url,
      recoverAuth: recoverAuth,
      request: () async {
    try {
      final headers = _headers();
      _logRequest('GET', url, null, headers);

      final response =
          await _http.get(Uri.parse(url), headers: headers).timeout(_requestTimeout);

      _logResponse(url, response);
      return _buildResponse(
        statusCode: response.statusCode,
        responseBody: response.body,
        isFromLogin: false,
      );
    } catch (e) {
      _logger.e('GET request failed: $e');
      return _buildExceptionResponse(e);
    }
      },
    );
  }

  // ===========================================================
  // POST REQUEST
  // ===========================================================
  Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
    bool recoverAuth = true,
    bool authorize = true,
    String? overrideToken,
  }) {
    return _send(
      url: url,
      recoverAuth: recoverAuth && !isFromLogin,
      request: () async {
    try {
      final headers = _headers(overrideToken: overrideToken, authorize: authorize);
      _logRequest('POST', url, body, headers);

      final response = await _http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ).timeout(_requestTimeout);

      _logResponse(url, response);
      return _buildResponse(
        statusCode: response.statusCode,
        responseBody: response.body,
        isFromLogin: isFromLogin,
      );
    } catch (e) {
      _logger.e('POST request failed: $e');
      return _buildExceptionResponse(e);
    }
      },
    );
  }

  // ===========================================================
  // PATCH REQUEST
  // ===========================================================
  Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
    bool recoverAuth = true,
  }) {
    return _send(
      url: url,
      recoverAuth: recoverAuth && !isFromLogin,
      request: () async {
    try {
      final headers = _headers();
      _logRequest('PATCH', url, body, headers);

      final response = await _http.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ).timeout(_requestTimeout);

      _logResponse(url, response);
      return _buildResponse(
        statusCode: response.statusCode,
        responseBody: response.body,
        isFromLogin: isFromLogin,
      );
    } catch (e) {
      _logger.e('PATCH request failed: $e');
      return _buildExceptionResponse(e);
    }
      },
    );
  }

  // ===========================================================
  // PUT REQUEST
  // ===========================================================
  Future<NetworkResponse> putRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
    bool recoverAuth = true,
  }) {
    return _send(
      url: url,
      recoverAuth: recoverAuth && !isFromLogin,
      request: () async {
    try {
      final headers = _headers();
      _logRequest('PUT', url, body, headers);

      final response = await _http.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ).timeout(_requestTimeout);

      _logResponse(url, response);
      return _buildResponse(
        statusCode: response.statusCode,
        responseBody: response.body,
        isFromLogin: isFromLogin,
      );
    } catch (e) {
      _logger.e('PUT request failed: $e');
      return _buildExceptionResponse(e);
    }
      },
    );
  }

  // ===========================================================
  // DELETE REQUEST
  // ===========================================================
  Future<NetworkResponse> deleteRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
    bool recoverAuth = true,
  }) {
    return _send(
      url: url,
      recoverAuth: recoverAuth && !isFromLogin,
      request: () async {
    try {
      final headers = _headers();
      _logRequest('DELETE', url, body, headers);

      final response = await _http.delete(
        Uri.parse(url),
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      ).timeout(_requestTimeout);

      _logResponse(url, response);
      return _buildResponse(
        statusCode: response.statusCode,
        responseBody: response.body,
        isFromLogin: isFromLogin,
      );
    } catch (e) {
      _logger.e('DELETE request failed: $e');
      return _buildExceptionResponse(e);
    }
      },
    );
  }

  // ===========================================================
  // MULTIPART REQUEST (POST / PATCH / PUT)
  // ===========================================================
  Future<NetworkResponse> multipartRequest({
    required String url,
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, File>? files,
    bool isFromLogin = false,
    bool recoverAuth = true,
  }) {
    return _send(
      url: url,
      recoverAuth: recoverAuth && !isFromLogin,
      request: () async {
    try {
      final request =
          http.MultipartRequest(method.toUpperCase(), Uri.parse(url));
      request.headers.addAll(_headers(json: false));

      if (fields != null) request.fields.addAll(fields);

      if (files != null) {
        for (final entry in files.entries) {
          final file = entry.value;
          // A picked file can disappear before upload (cache eviction on
          // Android). Skipping beats throwing mid-request.
          if (!file.existsSync()) {
            _logger.w('Skipping missing upload file: ${file.path}');
            continue;
          }
          final mimeType = lookupMimeType(file.path);
          request.files.add(
            await http.MultipartFile.fromPath(
              entry.key,
              file.path,
              filename: file.uri.pathSegments.last,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          );
        }
      }

      _logMultipartRequest(url, fields, files, request.headers);

      final streamed = await _http.send(request).timeout(_uploadTimeout);
      final responseBody = await streamed.stream.bytesToString();

      _logResponse(
        url,
        Response(responseBody, streamed.statusCode,
            reasonPhrase: streamed.reasonPhrase ?? ''),
      );

      return _buildResponse(
        statusCode: streamed.statusCode,
        responseBody: responseBody,
        isFromLogin: isFromLogin,
      );
    } catch (e) {
      _logger.e('MULTIPART request failed: $e');
      return _buildExceptionResponse(e);
    }
      },
    );
  }

  // ===========================================================
  // EXCEPTION → USER-FRIENDLY MESSAGE
  // ===========================================================
  String _networkExceptionMessage(Object e) {
    if (e is TimeoutException) {
      return 'Request timed out. Please check your connection.';
    }
    if (e is SocketException) {
      return 'No internet connection. Please check your network.';
    }
    if (e is HandshakeException) {
      return 'Secure connection failed. Please try again.';
    }
    if (e is HttpException) {
      return 'Network error. Please try again.';
    }
    if (e is FormatException) {
      return 'Unexpected server response. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  // ===========================================================
  // LOGGING
  // Debug builds only. These payloads contain bearer tokens and
  // personal data, which must never reach a release logcat.
  // ===========================================================
  Map<String, String> _redact(Map<String, String>? headers) {
    if (headers == null) return const {};
    return {
      for (final entry in headers.entries)
        entry.key: entry.key.toLowerCase() == 'authorization'
            ? 'Bearer ***'
            : entry.value,
    };
  }

  void _logRequest(
    String method,
    String url,
    dynamic body,
    Map<String, String>? headers,
  ) {
    if (!kDebugMode) return;
    _logger.i('''
================== $method REQUEST ==================
URL     : $url
HEADERS : ${_redact(headers)}
BODY    : ${_redactBody(body)}
====================================================''');
  }

  void _logMultipartRequest(
    String url,
    Map<String, String>? fields,
    Map<String, File>? files,
    Map<String, String>? headers,
  ) {
    if (!kDebugMode) return;
    _logger.i('''
================== MULTIPART REQUEST ==============
URL     : $url
HEADERS : ${_redact(headers)}
FIELDS  : ${_redactBody(fields)}
FILES   : ${files?.keys.toList()}
====================================================''');
  }

  void _logResponse(String url, Response response) {
    if (!kDebugMode) return;
    _logger.i('''
================== RESPONSE =======================
URL         : $url
STATUS CODE : ${response.statusCode}
BODY        : ${_redactSecrets(response.body)}
====================================================''');
  }

  /// Hides Stripe secrets (`sk_…`, `rk_…`, `whsec_…`, `…_secret_…`) so they
  /// never end up in logs or screenshots of logs.
  static final _secretPattern = RegExp(
    r'\b(sk|rk)_(test|live)_[A-Za-z0-9]+|\bwhsec_[A-Za-z0-9]+|_secret_[A-Za-z0-9]+',
  );

  String _redactSecrets(String body) => body
      .replaceAllMapped(_secretPattern, (m) {
        final v = m[0]!;
        return '${v.substring(0, v.indexOf('_', v.indexOf('_') + 1) + 1)}***';
      })
      .replaceAllMapped(_sensitiveJsonPattern, (m) => '${m[1]}"***"');

  /// Keys whose values must never be logged (passwords, OTPs, tokens).
  static final _sensitiveKey = RegExp(
    r'password|otp|token|secret',
    caseSensitive: false,
  );

  /// `"accessToken":"…"`, `"password":"…"` and similar in JSON text.
  static final _sensitiveJsonPattern = RegExp(
    r'("[A-Za-z_]*(?:password|Password|otp|Otp|token|Token|secret|Secret)[A-Za-z_]*"\s*:\s*)"[^"]*"',
  );

  dynamic _redactBody(dynamic body) {
    if (body is Map) {
      return {
        for (final e in body.entries)
          e.key: _sensitiveKey.hasMatch(e.key.toString())
              ? '***'
              : _redactBody(e.value),
      };
    }
    if (body is String) return _redactSecrets(body);
    return body;
  }
}

/// Shares one refresh among every request that is waiting on a 401.
class _AuthRecovery {
  Future<bool>? _inFlight;
  bool gaveUp = false;

  Future<void> waitIfRefreshing() async {
    final pending = _inFlight;
    if (pending != null) await pending;
  }

  Future<bool> refreshOnce(Future<bool> Function() refresh) {
    if (gaveUp) return Future.value(false);
    final existing = _inFlight;
    if (existing != null) return existing;
    late final Future<bool> tracked;
    tracked = refresh().then((ok) {
      if (!ok) gaveUp = true;
      return ok;
    }).whenComplete(() {
      if (identical(_inFlight, tracked)) _inFlight = null;
    });
    _inFlight = tracked;
    return tracked;
  }
}
