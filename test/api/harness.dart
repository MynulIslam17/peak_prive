import 'dart:async';
import 'dart:convert';

import 'package:get/get.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'fixtures.dart';

const base = 'https://api.test/api/v1';

/// Records requests and answers from [handler].
class Harness {
  Harness(FutureOr<http.Response> Function(http.Request req) handler) {
    final client = MockClient((req) async {
      requests.add(req);
      return handler(req);
    });
    caller = NetworkCaller(
      onUnAuthorize: () => unauthorizedCalls++,
      accessToken: () => 'tok',
      client: client,
    );
    api = PeakApi(caller, baseUrl: base, clock: () => DateTime(2026, 11, 16, 9));
  }

  final requests = <http.Request>[];
  int unauthorizedCalls = 0;
  late final NetworkCaller caller;
  late final PeakApi api;

  http.Request get last => requests.last;
  Map<String, dynamic> get lastBody => jsonDecode(last.body) as Map<String, dynamic>;
}

http.Response json(Object body, [int status = 200]) =>
    http.Response(jsonEncode(body), status, headers: {'content-type': 'application/json'});

http.Response fixtureResponse(String name, [int status = 200]) =>
    http.Response(fixtureText(name), status, headers: {'content-type': 'application/json; charset=utf-8'});


/// Registers [h]'s NetworkCaller and PeakApi in GetX for controller tests.
void registerHarness(Harness h) {
  Get.reset();
  Get.put<NetworkCaller>(h.caller);
  Get.put<PeakApi>(h.api);
}
