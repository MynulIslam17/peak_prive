import '../utils/app_toast.dart';

/// Short named helpers over [showAppToast], kept so existing call sites read
/// as `AppToast.error('...')`. One look for every toast in the app.
abstract final class AppToast {
  static void success(String message, {String title = 'Done'}) =>
      showAppToast(type: ToastType.success, title: title, message: message);

  static void error(String message, {String title = 'Something went wrong'}) =>
      showAppToast(type: ToastType.error, title: title, message: message);

  static void info(String message, {String title = 'Heads up'}) =>
      showAppToast(type: ToastType.info, title: title, message: message);
}
