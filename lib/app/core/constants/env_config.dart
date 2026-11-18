/// Build-time configuration loaded from a git-ignored key file:
///
///   flutter run --dart-define-from-file=env/keys.dev.json
///   flutter build appbundle --release --dart-define-from-file=env/keys.prod.json
///
/// See `env/keys.example.json` for every supported key.
///
/// SECURITY: everything here is compiled into the app binary and can be
/// extracted from an APK/IPA, so only public values belong here. The Stripe
/// **secret** key lives on the backend only: the app asks
/// `POST /booking/intent` for each payment and receives the PaymentIntent's
/// client secret and the publishable key from the server.
abstract final class EnvConfig {
  /// Optional Stripe publishable key (`pk_test_...` / `pk_live_...`) used to
  /// warm up the Stripe SDK at launch. The key returned by
  /// `/booking/intent` always wins, so this can be left empty.
  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
  );

  /// Name shown on the Stripe payment sheet.
  static const stripeMerchantName = String.fromEnvironment(
    'STRIPE_MERCHANT_NAME',
    defaultValue: 'Peak Privee',
  );

  static bool get hasStripePublishableKey =>
      stripePublishableKey.startsWith('pk_');

  /// Set only if someone still passes a secret key at build time.
  static const _leakedSecret = String.fromEnvironment('STRIPE_SECRET_KEY');

  /// Human-readable configuration problems, logged at startup.
  static List<String> get problems => [
    if (_leakedSecret.isNotEmpty)
      'STRIPE_SECRET_KEY is set in the build config. Remove it: the app no '
          'longer uses it and secret keys must never ship in an app.',
  ];
}
