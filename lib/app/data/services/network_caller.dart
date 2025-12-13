import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:logger/logger.dart';

import '../models/network_response.dart';

class NetworkCaller {
  final String _defaultErrorMessage = 'Something went wrong';
  final String _unAuthorizeMessage = 'Un-authorized token';
  final Logger _logger = Logger();

  final VoidCallback onUnAuthorize;
  final String Function() accessToken;

  NetworkCaller({
    required this.onUnAuthorize,
    required this.accessToken,
  });

  // ===========================================================
  // GET REQUEST
  // ===========================================================
  Future<NetworkResponse> getRequest({required String url}) async {
    try {
      Uri uri = Uri.parse(url);
      final headers = {
        'Authorization': 'Bearer ${accessToken()}',
        'Content-Type': 'application/json',
      };

      _logRequest(url, null, headers);
      Response response = await get(uri, headers: headers);
      _logResponse(url, response);

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: 200,
          body: decoded,
        );
      } else if (response.statusCode == 401) {
        onUnAuthorize();
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: decoded['message'] ?? _defaultErrorMessage,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // ===========================================================
  // POST REQUEST
  // ===========================================================
  Future<NetworkResponse> postRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${accessToken()}',
      };

      _logRequest(url, body, headers);
      Response response = await post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      _logResponse(url, response);

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: response.statusCode,
          body: decoded,
        );
      }

      if (response.statusCode == 401 && !isFromLogin) {
        onUnAuthorize();
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: decoded['message'] ?? _defaultErrorMessage,
        body: decoded,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // ===========================================================
  // PATCH REQUEST
  // ===========================================================
  Future<NetworkResponse> patchRequest({
    required String url,
    Map<String, dynamic>? body,
    bool isFromLogin = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${accessToken()}',
      };

      _logRequest(url, body, headers);
      Response response = await patch(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      _logResponse(url, response);

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: 200,
          body: decoded,
        );
      }

      if (response.statusCode == 401 && !isFromLogin) {
        onUnAuthorize();
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: decoded['message'] ?? _defaultErrorMessage,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // ===========================================================
  // PUT REQUEST
  // ===========================================================
  Future<NetworkResponse> putRequest({
    required String url,
    Map<String, String>? body,
    bool isFromLogin = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${accessToken()}',
      };

      _logRequest(url, body, headers);
      Response response = await put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      );
      _logResponse(url, response);

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: 200,
          body: decoded,
        );
      }

      if (response.statusCode == 401 && !isFromLogin) {
        onUnAuthorize();
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: decoded['message'] ?? _defaultErrorMessage,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // ===========================================================
  /// DELETE REQUEST
  // ===========================================================
  Future<NetworkResponse> deleteRequest({
    required String url,
    Map<String, String>? body,
    bool isFromLogin = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${accessToken()}',
      };

      _logRequest(url, body, headers);
      final response = await delete(
        uri,
        headers: headers,
        body: body != null ? jsonEncode(body) : null,
      );

      _logResponse(url, response);

      final decoded = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: 200,
          body: decoded,
        );
      }

      if (response.statusCode == 401 && !isFromLogin) {
        onUnAuthorize();
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: response.statusCode,
        errorMessage: decoded['message'] ?? _defaultErrorMessage,
        body: decoded,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // ===========================================================
  /// MULTIPART REQUEST (PATCH/POST/PUT)
  // ===========================================================
  Future<NetworkResponse> multipartRequest({
    required String url,
    String method = 'POST',
    Map<String, String>? fields,
    Map<String, File>? files,
    bool isFromLogin = false,
  }) async {
    try {
      Uri uri = Uri.parse(url);
      final request = http.MultipartRequest(method.toUpperCase(), uri);

      // Add token header
      request.headers['Authorization'] = 'Bearer ${accessToken()}';

      // Add normal fields
      if (fields != null) request.fields.addAll(fields);

      // Add files
      if (files != null) {
        for (var entry in files.entries) {
          File file = entry.value;
          String fileName = file.path.split('/').last;
          String? mimeType = lookupMimeType(file.path);

          request.files.add(
            http.MultipartFile(
              entry.key,
              file.readAsBytes().asStream(),
              file.lengthSync(),
              filename: fileName,
              contentType: mimeType != null ? MediaType.parse(mimeType) : null,
            ),
          );
        }
      }

      _logMultipartRequest(url, fields, files, request.headers);

      final streamed = await request.send();
      final responseBody = await streamed.stream.bytesToString();

      final decoded = jsonDecode(responseBody);

      final response = Response(
        responseBody,            // body first
        streamed.statusCode,     // status code second
        reasonPhrase: streamed.reasonPhrase ?? "",
      );


      _logResponse(url, response);

      if (streamed.statusCode == 200 || streamed.statusCode == 201) {
        return NetworkResponse(
          isSuccess: true,
          statusCode: streamed.statusCode,
          body: decoded,
        );
      }

      if (streamed.statusCode == 401 && !isFromLogin) {
        onUnAuthorize();
      }

      return NetworkResponse(
        isSuccess: false,
        statusCode: streamed.statusCode,
        errorMessage: decoded['message'] ?? _defaultErrorMessage,
        body: decoded,
      );
    } catch (e) {
      return NetworkResponse(
        isSuccess: false,
        statusCode: -1,
        errorMessage: e.toString(),
      );
    }
  }

  // ===========================================================
  // LOGGING
  // ===========================================================
  void _logRequest(String url, dynamic body, Map<String, String>? headers) {
    _logger.i(
      '''
================== REQUEST ========================
URL: $url
HEADERS: $headers
BODY: $body
====================================================
''',
    );
  }

  void _logMultipartRequest(
      String url,
      Map<String, String>? fields,
      Map<String, File>? files,
      Map<String, String>? headers,
      ) {
    _logger.i(
      '''
================== MULTIPART REQUEST ===============
URL: $url
HEADERS: $headers
FIELDS: $fields
FILES: ${files?.keys.toList()}
====================================================
''',
    );
  }

  void _logResponse(String url, Response response) {
    _logger.i(
      '''
================== RESPONSE ========================
URL: $url
STATUS CODE: ${response.statusCode}
BODY: ${response.body}
====================================================
''',
    );
  }
}
