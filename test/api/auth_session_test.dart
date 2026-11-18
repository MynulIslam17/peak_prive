import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/core/controllers/auth_controller.dart';
import 'package:harry_service_app/app/data/services/network/network_caller.dart';
import 'package:harry_service_app/app/modules/auth/controllers/login_controller.dart';
import 'package:harry_service_app/app/modules/auth/models/login_request_model.dart';
import 'package:harry_service_app/app/routes/app_routes.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() => Logger.level = Level.off);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
  });
  tearDown(Get.reset);

  test('login saves the access token and the refresh token', () async {
    Get.put(AuthController());
    Get.put<NetworkCaller>(NetworkCaller(
      onUnAuthorize: () {},
      accessToken: () => '',
      client: MockClient((_) async => http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'user': {
                  '_id': 'u1',
                  'fullName': 'QA',
                  'email': 'qa@example.com',
                  'role': 'User',
                },
                'tokens': {'accessToken': 'access-1', 'refreshToken': 'refresh-1'},
              },
            }),
            200,
          )),
    ));

    final ok = await LoginController().login(
      LoginRequestModel(email: 'qa@example.com', password: 'secret'),
    );

    expect(ok, isTrue);
    final auth = Get.find<AuthController>();
    expect(auth.accessToken, 'access-1');
    expect(auth.refreshToken, 'refresh-1');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access-token'), 'access-1');
    expect(prefs.getString('refresh-token'), 'refresh-1');
  });

  test('one 401 refreshes once, then the queued calls use the new access token', () async {
    final auth = Get.put(AuthController());
    auth.accessToken = 'old-access';
    auth.refreshToken = 'refresh-1';

    final release = Completer<void>();
    final started = Completer<void>();
    var refreshPosts = 0;
    late NetworkCaller caller;
    caller = NetworkCaller(
      onUnAuthorize: () {},
      accessToken: () => auth.accessToken ?? '',
      refreshSession: () => auth.refreshSession(caller),
      client: MockClient((req) async {
        if (req.url.path.endsWith('/auth/refresh-token')) {
          refreshPosts++;
          if (!started.isCompleted) started.complete();
          await release.future;
          expect(jsonDecode(req.body), {'refreshToken': 'refresh-1'});
          expect(req.headers['authorization'], isNull);
          return http.Response(
            jsonEncode({
              'success': true,
              'data': {
                'tokens': {'accessToken': 'new-access', 'refreshToken': 'refresh-2'},
              },
            }),
            200,
          );
        }
        if (req.headers['authorization'] != 'Bearer new-access') {
          return http.Response(jsonEncode({'success': false, 'message': 'expired'}), 401);
        }
        return http.Response(jsonEncode({'success': true, 'data': {'ok': true}}), 200);
      }),
    );
    Get.put<NetworkCaller>(caller);

    final pending = Future.wait([
      caller.getRequest(url: 'https://x.test/a'),
      caller.getRequest(url: 'https://x.test/b'),
      caller.getRequest(url: 'https://x.test/c'),
    ]);
    await started.future;
    expect(refreshPosts, 1);
    release.complete();

    final done = await pending;
    expect(done.every((r) => r.isSuccess), isTrue);
    expect(refreshPosts, 1);
    expect(auth.accessToken, 'new-access');
    expect(auth.refreshToken, 'refresh-2');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access-token'), 'new-access');
    expect(prefs.getString('refresh-token'), 'refresh-2');
  });

  test('a failed refresh logs out once and does not refresh again', () async {
    final auth = Get.put(AuthController());
    auth.accessToken = 'old-access';
    auth.refreshToken = 'refresh-1';
    var refreshPosts = 0;
    var logouts = 0;
    late NetworkCaller caller;
    caller = NetworkCaller(
      onUnAuthorize: () => logouts++,
      accessToken: () => auth.accessToken ?? '',
      refreshSession: () => auth.refreshSession(caller),
      client: MockClient((req) async {
        if (req.url.path.endsWith('/auth/refresh-token')) {
          refreshPosts++;
          return http.Response(jsonEncode({'success': false, 'message': 'Refresh token expired'}), 401);
        }
        return http.Response(jsonEncode({'success': false, 'message': 'expired'}), 401);
      }),
    );

    final done = await Future.wait([
      caller.getRequest(url: 'https://x.test/a'),
      caller.getRequest(url: 'https://x.test/b'),
      caller.getRequest(url: 'https://x.test/c'),
    ]);
    expect(done.every((r) => r.isUnauthorized), isTrue);
    expect(refreshPosts, 1);
    expect(logouts, 1);

    await caller.getRequest(url: 'https://x.test/d');
    expect(refreshPosts, 1);
    expect(logouts, 1);
  });

  test('logout posts the refresh token and then clears both tokens', () async {
    final auth = Get.put(AuthController());
    await auth.saveTokens(accessToken: 'access-1', refreshToken: 'refresh-1');
    final requests = <http.Request>[];
    Get.put<NetworkCaller>(NetworkCaller(
      onUnAuthorize: () {},
      accessToken: () => auth.accessToken ?? '',
      client: MockClient((req) async {
        requests.add(req);
        return http.Response(jsonEncode({'success': true, 'message': 'Logged out'}), 200);
      }),
    ));

    await auth.logout();

    expect(requests, hasLength(1));
    expect(requests.single.method, 'POST');
    expect(requests.single.url.path, endsWith('/auth/logout'));
    expect(jsonDecode(requests.single.body), {'refreshToken': 'refresh-1'});
    expect(auth.accessToken, isNull);
    expect(auth.refreshToken, isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('access-token'), isNull);
    expect(prefs.getString('refresh-token'), isNull);
  });

  testWidgets('logout shows the Android loader until the request finishes', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    try {
      await _expectLogoutLoader(tester, find.byType(CircularProgressIndicator));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });

  testWidgets('logout shows the iOS activity indicator until the request finishes', (tester) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      await _expectLogoutLoader(tester, find.byType(CupertinoActivityIndicator));
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  });
}

Future<void> _expectLogoutLoader(WidgetTester tester, Finder loader) async {
  SharedPreferences.setMockInitialValues({});
  final release = Completer<void>();
  final auth = Get.put(AuthController());
  auth.accessToken = 'access-1';
  auth.refreshToken = 'refresh-1';
  Get.put<NetworkCaller>(NetworkCaller(
    onUnAuthorize: () {},
    accessToken: () => auth.accessToken ?? '',
    client: MockClient((_) async {
      await release.future;
      return http.Response(jsonEncode({'success': true}), 200);
    }),
  ));

  await tester.pumpWidget(GetMaterialApp(
    getPages: [
      GetPage(
        name: '/',
        page: () => Scaffold(
          body: TextButton(
            onPressed: () => Get.find<AuthController>().logout(),
            child: const Text('Log out'),
          ),
        ),
      ),
      GetPage(
        name: Routes.login,
        page: () => const Scaffold(body: Text('login-screen')),
      ),
    ],
  ));

  await tester.tap(find.text('Log out'));
  await tester.pump();
  expect(loader, findsOneWidget);

  release.complete();
  await tester.pumpAndSettle();
  expect(find.text('login-screen'), findsOneWidget);
  expect(auth.accessToken, isNull);
}
