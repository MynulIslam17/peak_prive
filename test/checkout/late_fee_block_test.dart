import 'package:flutter_test/flutter_test.dart';
import 'package:harry_service_app/app/data/services/stripe/checkout_controller.dart';

void main() {
  test('402 text: amount and booking id are pulled out', () {
    final r = parseLateFeeBlock('Please pay your outstanding late fee of 10 first (booking 6afbe1811fca1800f38dd35c).');
    expect(r.amount, 10);
    expect(r.bookingId, '6afbe1811fca1800f38dd35c');
  });

  test('402 text without details: both null', () {
    final r = parseLateFeeBlock('Please pay your outstanding late fee first.');
    expect(r.amount, isNull);
    expect(r.bookingId, isNull);
  });
}
