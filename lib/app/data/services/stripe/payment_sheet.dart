import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

import '../../../core/constants/env_config.dart';
import 'stripe_config.dart';

/// Result of showing the Stripe payment sheet.
enum SheetStatus {
  /// Paid. The PaymentIntent is `succeeded`.
  succeeded,

  /// The user closed the sheet. Nothing was charged.
  canceled,

  /// Stripe is still processing (e.g. bank redirect). The server's webhook
  /// creates the booking when it completes.
  processing,

  /// Declined or another error.
  failed,
}

class SheetOutcome {
  const SheetOutcome(this.status, [this.message]);
  final SheetStatus status;

  /// Stripe's message for [SheetStatus.failed].
  final String? message;
}

/// Shows a payment sheet for one PaymentIntent. Behind an interface so the
/// checkout flow can be tested without the Stripe plugin.
abstract interface class PaymentSheet {
  Future<SheetOutcome> present({
    required String publishableKey,
    required String clientSecret,
  });
}

/// The key to open the sheet with: the server's `pk_` key.
///
/// If the server sends anything else (a secret `sk_`/`rk_` key by mistake, or
/// nothing) the build-time [fallback] is used, but only when it is a `pk_` key
/// of the same mode (test/live). A secret key is never used. Returns '' when
/// there is no safe key.
String resolvePublishableKey(
  String serverKey, {
  String fallback = EnvConfig.stripePublishableKey,
}) {
  final key = serverKey.trim();
  if (key.startsWith('pk_')) return key;
  if (!fallback.startsWith('pk_')) return '';
  final fallbackIsTest = fallback.startsWith('pk_test_');
  if (key.contains('_test_') && fallbackIsTest) return fallback;
  if (key.contains('_live_') && !fallbackIsTest) return fallback;
  return '';
}

/// [PaymentSheet] backed by `flutter_stripe`.
class StripePaymentSheet implements PaymentSheet {
  const StripePaymentSheet({this.config = const StripeConfig()});

  final StripeConfig config;

  Future<void> _useKey(String publishableKey) async {
    String? current;
    try {
      current = Stripe.publishableKey;
    } on StripeConfigException {
      current = null;
    }
    if (current == publishableKey) return;
    Stripe.publishableKey = publishableKey;
    await Stripe.instance.applySettings();
  }

  @override
  Future<SheetOutcome> present({
    required String publishableKey,
    required String clientSecret,
  }) async {
    try {
      await _useKey(publishableKey);
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: config.merchantDisplayName,
          style: config.paymentSheetTheme,
          allowsDelayedPaymentMethods: config.allowsDelayedPaymentMethods,
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // The sheet closing doesn't prove the money moved; ask Stripe.
      final intent = await Stripe.instance.retrievePaymentIntent(clientSecret);
      return switch (intent.status) {
        PaymentIntentsStatus.Succeeded => const SheetOutcome(SheetStatus.succeeded),
        PaymentIntentsStatus.Processing => const SheetOutcome(SheetStatus.processing),
        PaymentIntentsStatus.Canceled => const SheetOutcome(SheetStatus.canceled),
        _ => const SheetOutcome(SheetStatus.failed, 'Payment was not completed. Please try again.'),
      };
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return const SheetOutcome(SheetStatus.canceled);
      }
      return SheetOutcome(
        SheetStatus.failed,
        e.error.localizedMessage ?? e.error.message ?? 'Payment failed. Please try again.',
      );
    } catch (e) {
      if (kDebugMode) debugPrint('[Stripe] unexpected error: $e');
      return const SheetOutcome(SheetStatus.failed, 'Something went wrong with the payment. Please try again.');
    }
  }
}
