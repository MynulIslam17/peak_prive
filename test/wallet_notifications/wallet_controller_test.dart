import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:harry_service_app/app/data/api/peak_api.dart';
import 'package:harry_service_app/app/modules/user/shared/controllers/wallet_controller.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import '../api/fixtures.dart';
import '../api/harness.dart';

http.Response okJson(Object body) => json(body);

void main() {
  setUpAll(() => Logger.level = Level.off);
  tearDown(Get.reset);

  /// Provider wallet backed by the real fixtures; [balance] overrides it.
  Harness providerServer({num? balance, http.Response Function(http.Request)? onWithdraw}) {
    var current = balance ?? 565808;
    return Harness((req) {
      final p = req.url.path;
      if (p.endsWith('/wallet/get-my-account')) {
        final j = fixture('p_account');
        (j['data'] as Map)['balance'] = current;
        return okJson(j);
      }
      if (p.endsWith('/Withdraw/my')) return fixtureResponse('p_withdraw');
      if (p.endsWith('/Withdraw/send-request')) {
        final r = onWithdraw?.call(req) ?? okJson({'success': true, 'message': 'Requested'});
        if (r.statusCode == 200) current -= 10;
        return r;
      }
      if (p.endsWith('/wallet/add')) return okJson({'success': true});
      return http.Response('not found', 404);
    });
  }

  group('provider wallet', () {
    test('load fills balance, accounts and withdrawals', () async {
      final h = providerServer();
      registerHarness(h);
      final c = WalletController(isProvider: true);
      await c.load();
      expect(c.balance, 565808);
      expect(c.accounts.single.card, '•••• 5458');
      expect(c.withdrawals, hasLength(2));
      expect(c.hasMore, isFalse);
      expect(c.errorMessage, isNull);
    });

    test('rejected withdrawal reads as returned to the balance', () async {
      registerHarness(providerServer());
      final c = WalletController(isProvider: true);
      await c.load();
      final rejected = c.withdrawals.firstWhere((w) => w.status == WithdrawalStatus.rejected);
      expect(withdrawalStatusText(rejected), 'Rejected — returned to your balance');
      final pending = c.withdrawals.firstWhere((w) => w.status == WithdrawalStatus.pending);
      expect(withdrawalStatusText(pending), 'Pending');
      expect(
        withdrawalStatusText(Withdrawal.fromJson({'id': 'x', 'status': 'Paid', 'card': '•••• 1'})),
        'Paid to •••• 1',
      );
    });

    test('withdraw validation: account, empty, zero, text, over balance', () async {
      final h = providerServer(balance: 50);
      registerHarness(h);
      final c = WalletController(isProvider: true);
      await c.loadAccount();
      final before = h.requests.length;
      expect(await c.withdraw(accountId: null, amountText: '10'), 'Choose where to send the money.');
      expect(await c.withdraw(accountId: 'a', amountText: ''), 'Enter an amount greater than €0.');
      expect(await c.withdraw(accountId: 'a', amountText: '0'), 'Enter an amount greater than €0.');
      expect(await c.withdraw(accountId: 'a', amountText: 'abc'), 'Enter an amount greater than €0.');
      expect(await c.withdraw(accountId: 'a', amountText: '-5'), 'Enter an amount greater than €0.');
      expect(await c.withdraw(accountId: 'a', amountText: '60'), 'Your balance is €50. You asked for €60.');
      expect(h.requests.length, before, reason: 'nothing sent for invalid input');
    });

    test('decimal comma is accepted', () {
      expect(WalletController.parseAmount('12,50'), 12.5);
      expect(WalletController.parseAmount(' €7 '), 7);
      expect(WalletController.parseAmount('1e400'), isNull);
    });

    test('successful withdraw sends the account id and refreshes balance + history', () async {
      final h = providerServer(balance: 50);
      registerHarness(h);
      final c = WalletController(isProvider: true);
      await c.load();
      final error = await c.withdraw(accountId: '69c91a96c6549b7336fcd9bd', amountText: '10');
      expect(error, isNull);
      final send = h.requests.firstWhere((r) => r.url.path.endsWith('/send-request'));
      expect(send.body, '{"cardId":"69c91a96c6549b7336fcd9bd","amount":10}');
      expect(c.balance, 40);
      final after = h.requests.skipWhile((r) => !r.url.path.endsWith('/send-request')).skip(1);
      expect(after.map((r) => r.url.path), containsAll(['/api/v1/wallet/get-my-account', '/api/v1/Withdraw/my']));
      expect(c.isWithdrawing, isFalse);
    });

    test('server refusal is shown and the balance reloaded', () async {
      final h = providerServer(
        balance: 50,
        onWithdraw: (_) => json({'success': false, 'message': 'Insufficient balance.'}, 400),
      );
      registerHarness(h);
      final c = WalletController(isProvider: true);
      await c.loadAccount();
      final error = await c.withdraw(accountId: 'a', amountText: '10');
      expect(error, 'Insufficient balance.');
      expect(h.last.url.path, '/api/v1/wallet/get-my-account');
    });

    test('double tap sends one request', () async {
      final h = providerServer(balance: 50);
      registerHarness(h);
      final c = WalletController(isProvider: true);
      await c.loadAccount();
      final a = c.withdraw(accountId: 'a', amountText: '10');
      final b = c.withdraw(accountId: 'a', amountText: '10');
      await Future.wait([a, b]);
      expect(h.requests.where((r) => r.url.path.endsWith('/send-request')), hasLength(1));
    });

    test('add account validates and strips spaces', () async {
      final h = providerServer();
      registerHarness(h);
      final c = WalletController(isProvider: true);
      expect(await c.addAccount(accountType: 'Bank Account', cardHolderName: ' ', cardNumber: '12345678'),
          'Fill in the account holder and number.');
      expect(await c.addAccount(accountType: 'Bank Account', cardHolderName: 'Ann', cardNumber: '1234abcd'),
          'Use digits only for the account number.');
      expect(await c.addAccount(accountType: 'Bank Account', cardHolderName: 'Ann', cardNumber: '1234'),
          'The account number must be at least 8 digits.');
      expect(h.requests, isEmpty);
      expect(await c.addAccount(accountType: 'Bank Account', cardHolderName: 'Ann', cardNumber: '4242 4242 4242'), isNull);
      final add = h.requests.firstWhere((r) => r.url.path.endsWith('/wallet/add'));
      expect(add.body, contains('"cardNumber":"424242424242"'));
      expect(c.accounts, isNotEmpty);
    });

    test('load failure keeps balance null with a message', () async {
      registerHarness(Harness((_) => http.Response('<html>502</html>', 502)));
      final c = WalletController(isProvider: true);
      await c.load();
      expect(c.balance, isNull);
      expect(c.errorMessage, isNotEmpty);
      expect(c.activityError, isNotEmpty);
    });
  });

  group('customer payments', () {
    test('loads payments (no wallet account call) and pages', () async {
      final h = Harness((req) {
        final page = int.parse(req.url.queryParameters['page'] ?? '1');
        return json({
          'success': true,
          'data': [
            {'id': 'p$page', 'amount': 25, 'status': 'Paid', 'purpose': 'booking'},
            if (page == 1) {'id': 'lf', 'amount': 44, 'status': 'Partially_Refunded', 'refundedAmount': 4, 'purpose': 'late_fee'},
          ],
          'meta': {'page': page, 'limit': 20, 'total': 3, 'totalPages': 2},
        });
      });
      registerHarness(h);
      final c = WalletController(isProvider: false);
      await c.load();
      expect(h.requests.every((r) => r.url.path == '/api/v1/payment/all'), isTrue);
      expect(c.payments.map((p) => p.id), ['p1', 'lf']);
      expect(c.hasMore, isTrue);
      await c.loadMoreActivity();
      expect(c.payments.map((p) => p.id), ['p1', 'lf', 'p2']);
      expect(c.hasMore, isFalse);
      await c.loadMoreActivity(); // no-op at the end
      expect(h.requests, hasLength(2));

      final lateFee = c.payments[1];
      expect(paymentTitle(lateFee), 'Late fee');
      expect(paymentStatusText(lateFee), '€4 refunded to your card');
      expect(paymentStatusText(PaymentRecord.fromJson({'id': 'r', 'status': 'Refunded'})), 'Refunded to your card');
    });
  });
}
