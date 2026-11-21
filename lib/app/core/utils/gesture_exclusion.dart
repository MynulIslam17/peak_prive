import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Switches off Android's edge back-swipe over given screen areas, so a
/// control sitting at the edge (like the draggable orb) gets the touch
/// instead of the system going back. Does nothing on iOS or Android < 10.
///
/// Each caller owns one area under its own key; all areas are sent together.
class GestureExclusion {
  GestureExclusion._();

  static const _channel = MethodChannel('app/gesture_exclusion');
  static final Map<Object, Rect> _areas = {};
  static List<List<int>> _sent = const [];

  /// [area] is in logical pixels, global coordinates; null removes it.
  static void set(Object key, Rect? area, double devicePixelRatio) {
    if (kIsWeb || !Platform.isAndroid) return;
    if (area == null) {
      if (_areas.remove(key) == null) return;
    } else {
      _areas[key] = area;
    }
    final rects = [
      for (final r in _areas.values)
        [
          (r.left * devicePixelRatio).floor(),
          (r.top * devicePixelRatio).floor(),
          (r.right * devicePixelRatio).ceil(),
          (r.bottom * devicePixelRatio).ceil(),
        ],
    ];
    if (listEquals(rects.expand((r) => r).toList(), _sent.expand((r) => r).toList())) return;
    _sent = rects;
    _channel.invokeMethod('setRects', rects).catchError((_) {});
  }
}
