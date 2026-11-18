# Harry Service App

**Harry Service App** is a Flutter-based mobile application designed to provide services to clients visiting ski resorts. It allows service providers to offer various amenities and enhances the ski experience for clients by integrating real-time communication.

---

## Features

- **Service Management**: Clients can access multiple services during their ski trips:
    - Ski tickets and passes
    - Ski accessories rental or purchase
    - Transportation services
    - Food and restaurant bookings
    - Massage and spa services

- **Real-Time Chat**: Communicate seamlessly with service providers using a chat feature powered by **Socket.IO**.

- **Flutter-Based**: Built entirely with Flutter, ensuring cross-platform compatibility for both iOS and Android.

---

## Tech Stack

- **Frontend**: Flutter
- **Real-Time Communication**: Socket.IO
- **State Management**: GetX
- **Other Packages**:
    - Image Picker
    - Flutter ScreenUtil
    - Custom UI Components (cards, search bar, etc.)

---

## Configuration & Stripe keys

Keys are **never** hardcoded. They live in git-ignored JSON files under `env/`
and are injected at build time:

```bash
cp env/keys.example.json env/keys.dev.json   # then fill in your test keys
flutter run --dart-define-from-file=env/keys.dev.json

# Release
flutter build appbundle --release --dart-define-from-file=env/keys.prod.json
flutter build ipa       --release --dart-define-from-file=env/keys.prod.json
```

Android Studio: *Run → Edit Configurations → Additional run args* →
`--dart-define-from-file=env/keys.dev.json`. VS Code: use the launch configs in `.vscode/launch.json`.

| Key | Required | Notes |
| --- | --- | --- |
| `STRIPE_PUBLISHABLE_KEY` | No | Optional warm-up key. The key returned by the backend for each payment always wins |
| `STRIPE_MERCHANT_NAME` | No | Shown on the payment sheet |

**Never put the Stripe secret key (`sk_...`) in the app.** Anything compiled into
the app can be extracted from the APK/IPA. The app logs a warning at startup if
`STRIPE_SECRET_KEY` is passed at build time.

### Payment flow

Every booking (all five services) is paid like this:

```
1. POST /booking/intent   { ...booking body }
   → backend validates the booking, fixes the price, creates the PaymentIntent
   ← { paymentIntentId, clientSecret, publishableKey, amount, currency }
2. Stripe payment sheet with clientSecret (flutter_stripe)
3. POST /booking/create   { ...same booking body, paymentIntentId }
   → backend verifies the payment with Stripe, then saves the booking
```

- `StripePaymentHelper.processPayment(bookingBody: ...)` does steps 1–2
  (`lib/app/data/services/stripe/`).
- `CreateBookingController.proceedBooking` does step 3 and reports the outcome:
  `created`, `alreadyBooked` (409), `retryable` (network / 5xx: resend the
  same body and `paymentIntentId`), or `rejected` (refunded or never charged:
  the user must pay again).
- Send the **same** body to both calls. For ski pass the server sets the price
  (amount × `personCount`); other services must send `totalPrice`.

## Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/harry_service_app.git
   cd harry_service_app