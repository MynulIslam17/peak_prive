import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('PATCH/POST without a body send {} (the server rejects "null")', () async {
    final bodies = <String>[];
    final client = MockClient((req) async {
      bodies.add(req.body);
      return http.Response('{"success":true,"message":"ok","data":null}', 200);
    });
    final caller = NetworkCaller(onUnAuthorize: () {}, accessToken: () => 't', client: client);
    await caller.patchRequest(url: 'https://x.test/notifications/read-all');
    await caller.postRequest(url: 'https://x.test/a');
    expect(bodies, ['{}', '{}']);
  });

  test('401 on a credential check shows the server reason and does not log out', () async {
    var loggedOut = false;
    final client = MockClient((_) async =>
        http.Response('{"success":false,"message":"Current password is incorrect."}', 401));
    final caller = NetworkCaller(onUnAuthorize: () => loggedOut = true, accessToken: () => 't', client: client);
    final r = await caller.postRequest(url: 'https://x.test/auth/change-password', body: {}, isFromLogin: true);
    expect(r.errorMessage, 'Current password is incorrect.');
    expect(loggedOut, isFalse);
    await caller.getRequest(url: 'https://x.test/booking/my');
    expect(loggedOut, isTrue);
  });
}
