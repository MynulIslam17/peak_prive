import 'package:get/get.dart';

/// Shows one toast at a time, without GetX's snackbar queue.
///
/// `Get.snackbar` queues every call, so tapping "Try again" five times on a
/// failing request showed the same error five times in a row. Here:
/// * the same toast (same key) while it is still visible is not shown again;
/// * a different toast replaces the visible one straight away;
/// * calls made while the old one is closing collapse into the latest.
abstract final class ToastHost {
  static SnackbarController? _current;
  static String? _currentKey;
  static bool _currentIsStale = false;
  static ({String key, SnackbarController Function() show, bool clearOnNavigate})? _pending;
  static bool _busy = false;

  /// The key of the toast on screen (for tests and debugging).
  static String? get visibleKey => _current == null ? null : _currentKey;

  /// [key] identifies the content (e.g. type + title + message); [show]
  /// creates and shows the snackbar and returns its controller.
  /// With [clearOnNavigate] (errors, warnings) the toast closes when the
  /// user moves to another screen, so an old error doesn't sit over the next
  /// page. Success toasts shown right before navigating stay.
  static void present(String key, SnackbarController Function() show, {bool clearOnNavigate = false}) {
    if (_current != null && _currentKey == key && _pending == null) return;
    _pending = (key: key, show: show, clearOnNavigate: clearOnNavigate);
    _drain();
  }

  /// Closes the toast on screen and drops any waiting one.
  static Future<void> dismiss() async {
    _pending = null;
    final current = _current;
    if (current != null) await _close(current);
  }

  /// Call on every route change (GetMaterialApp.routingCallback).
  static void onRouteChanged() {
    final current = _current;
    if (current != null && _currentIsStale && _pending == null) _close(current);
  }

  static Future<void> _drain() async {
    if (_busy) return; // the running drain picks up the latest request
    _busy = true;
    try {
      while (_pending != null) {
        final current = _current;
        if (current != null) await _close(current);
        final next = _pending;
        _pending = null;
        if (next == null) break;
        final SnackbarController controller;
        try {
          controller = next.show();
        } catch (_) {
          continue; // no overlay yet (e.g. during start-up): drop it
        }
        _current = controller;
        _currentKey = next.key;
        _currentIsStale = next.clearOnNavigate;
        controller.future.whenComplete(() {
          if (identical(_current, controller)) {
            _current = null;
            _currentKey = null;
          }
        });
      }
    } finally {
      _busy = false;
    }
  }

  static Future<void> _close(SnackbarController c) async {
    try {
      await c.close();
    } catch (_) {
      // Already gone (swiped away or its overlay was removed).
    }
    if (identical(_current, c)) {
      _current = null;
      _currentKey = null;
    }
  }
}
