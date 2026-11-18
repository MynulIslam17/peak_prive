import '../../../data/api/models/booking_request.dart';
import '../../../data/services/stripe/payment_sheet.dart' as stripe;

export '../../../data/services/stripe/payment_sheet.dart' show resolvePublishableKey;

/// Late-fee payments reuse the checkout's Stripe sheet
/// (`data/services/stripe/payment_sheet.dart`), so there is one Stripe
/// implementation in the app. This file only adapts it to the booking
/// controller's function type, which tests replace with a fake.
enum SheetStatus { paid, canceled, failed }

class SheetOutcome {
  const SheetOutcome(this.status, [this.message]);
  const SheetOutcome.paid() : this(SheetStatus.paid);
  const SheetOutcome.canceled() : this(SheetStatus.canceled);
  const SheetOutcome.failed(String message) : this(SheetStatus.failed, message);

  final SheetStatus status;
  final String? message;
}

typedef PaymentSheet = Future<SheetOutcome> Function(PaymentIntentData intent);

/// Real Stripe payment sheet for a late-fee intent.
Future<SheetOutcome> stripePaymentSheet(PaymentIntentData intent) async {
  // Never a secret key: only the server's pk_ or the build's pk_ of that mode.
  final key = stripe.resolvePublishableKey(intent.publishableKey);
  if (key.isEmpty || !intent.isComplete) {
    return const SheetOutcome.failed('Payment is not available right now. Please try again later.');
  }
  final r = await stripe.StripePaymentSheet().present(
    publishableKey: key,
    clientSecret: intent.clientSecret,
  );
  return switch (r.status) {
    stripe.SheetStatus.succeeded => const SheetOutcome.paid(),
    stripe.SheetStatus.canceled => const SheetOutcome.canceled(),
    stripe.SheetStatus.processing => const SheetOutcome.failed(
        'Your payment is still processing. We will update the booking when it completes.'),
    stripe.SheetStatus.failed => SheetOutcome.failed(r.message ?? 'Payment failed. Please try again.'),
  };
}
