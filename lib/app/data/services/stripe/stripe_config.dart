import 'package:flutter/material.dart';

import '../../../core/constants/env_config.dart';

/// Payment-sheet presentation settings. Contains no credentials: keys
/// come from the backend (`POST /booking/intent`), and PaymentIntents are
/// created by the server.
class StripeConfig {
  const StripeConfig({
    this.merchantDisplayName = EnvConfig.stripeMerchantName,
    this.paymentSheetTheme = ThemeMode.light,
    this.allowsDelayedPaymentMethods = false,
  });

  final String merchantDisplayName;
  final ThemeMode paymentSheetTheme;

  /// Keep `false` unless bookings can wait for asynchronous confirmation
  /// (e.g. SEPA debit) — with delayed methods the sheet closes before the
  /// money has actually been collected.
  final bool allowsDelayedPaymentMethods;
}
