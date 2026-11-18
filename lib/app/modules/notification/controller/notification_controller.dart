import 'dart:async';

import 'package:get/get.dart';

import '../../../core/controllers/auth_controller.dart';
import '../../../data/api/peak_api.dart';
import '../../../data/services/socket/live_events.dart';
import '../../../routes/app_routes.dart';

typedef Navigate = void Function(String route, Map<String, dynamic> arguments);

/// Notifications list + unread badge (one instance for the whole session).
///
/// Use [NotificationController.ensure] from any screen that shows the bell.
/// New notifications from the socket are prepended and bump the badge.
class NotificationController extends GetxController {
  NotificationController({
    bool Function()? isLoggedIn,
    String? Function()? sessionKey,
    Navigate? navigate,
  })  : _isLoggedIn = isLoggedIn ?? _defaultLoggedIn,
        _sessionKey = sessionKey ?? _defaultSessionKey,
        _navigate = navigate ?? _defaultNavigate;

  /// The registered controller, created (permanent) on first use.
  static NotificationController ensure() => Get.isRegistered<NotificationController>()
      ? Get.find<NotificationController>()
      : Get.put(NotificationController(), permanent: true);

  static bool _defaultLoggedIn() =>
      Get.isRegistered<AuthController>() && Get.find<AuthController>().isLoggedIn;

  static String? _defaultSessionKey() =>
      Get.isRegistered<AuthController>() ? Get.find<AuthController>().accessToken : null;

  static void _defaultNavigate(String route, Map<String, dynamic> args) =>
      Get.toNamed(route, arguments: args);

  final bool Function() _isLoggedIn;
  final String? Function() _sessionKey;
  String? _loadedFor;
  final Navigate _navigate;

  static const pageSize = 20;

  NotificationApi get _api => Get.find<PeakApi>().notifications;

  final List<AppNotification> items = [];
  int unread = 0;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = false;
  bool hasLoaded = false;
  String? errorMessage;
  int _page = 1;
  int _generation = 0;

  StreamSubscription<AppNotification>? _sub;
  StreamSubscription<void>? _reconnectSub;

  @override
  void onInit() {
    super.onInit();
    _sub = LiveEvents.notifications.listen(onLiveNotification);
    _reconnectSub = LiveEvents.reconnects.listen((_) => refreshUnread());
  }

  @override
  void onClose() {
    _sub?.cancel();
    _reconnectSub?.cancel();
    super.onClose();
  }

  /// First page (pull to refresh, screen open).
  Future<void> fetch() async {
    if (!_isLoggedIn()) return;
    _resetIfOtherUser();
    final gen = ++_generation;
    isLoading = items.isEmpty;
    errorMessage = null;
    update();
    final r = await _api.list(page: 1, limit: pageSize);
    if (gen != _generation) return;
    isLoading = false;
    if (r.isSuccess) {
      items
        ..clear()
        ..addAll(r.data!.items);
      _page = 1;
      hasMore = r.data!.hasMore;
      unread = r.data!.meta.unread ?? items.where((n) => !n.isRead).length;
      hasLoaded = true;
    } else {
      errorMessage = r.errorMessage;
    }
    update();
  }

  Future<void> loadMore() async {
    if (!hasMore || isLoadingMore || isLoading) return;
    final gen = _generation;
    isLoadingMore = true;
    update();
    final r = await _api.list(page: _page + 1, limit: pageSize);
    if (gen != _generation) return;
    isLoadingMore = false;
    if (r.isSuccess) {
      _page++;
      final known = items.map((n) => n.id).toSet();
      items.addAll(r.data!.items.where((n) => !known.contains(n.id)));
      hasMore = r.data!.hasMore;
      if (r.data!.meta.unread != null) unread = r.data!.meta.unread!;
    }
    update();
  }

  /// Badge count only (cheap; call on home screens / app resume).
  Future<void> refreshUnread() async {
    if (!_isLoggedIn()) return;
    _resetIfOtherUser();
    final r = await _api.unreadCount();
    if (r.isSuccess) {
      unread = r.data!;
      update();
    }
  }

  /// Socket `notification:new`.
  void onLiveNotification(AppNotification n) {
    if (items.any((e) => e.id == n.id)) return;
    items.insert(0, n);
    if (!n.isRead) unread++;
    update();
  }

  /// Optimistic; rolls back and returns false when the server refuses.
  Future<bool> markRead(AppNotification n) async {
    final i = items.indexWhere((e) => e.id == n.id);
    if (i < 0 || items[i].isRead) return true;
    items[i] = items[i].copyWith(isRead: true);
    if (unread > 0) unread--;
    update();
    final r = await _api.markRead(n.id);
    if (r.isSuccess) return true;
    final j = items.indexWhere((e) => e.id == n.id);
    if (j >= 0) items[j] = items[j].copyWith(isRead: false);
    unread++;
    update();
    return false;
  }

  /// Optimistic; rolls back and returns false when the server refuses.
  Future<bool> markAllRead() async {
    if (unread == 0 && items.every((n) => n.isRead)) return true;
    final before = List<AppNotification>.of(items);
    final unreadBefore = unread;
    for (var i = 0; i < items.length; i++) {
      if (!items[i].isRead) items[i] = items[i].copyWith(isRead: true);
    }
    unread = 0;
    update();
    final r = await _api.markAllRead();
    if (r.isSuccess) return true;
    items
      ..clear()
      ..addAll(before);
    unread = unreadBefore;
    update();
    return false;
  }

  /// Where tapping [n] leads, or null when it has no booking.
  static String? routeFor(AppNotification n) =>
      (n.bookingId ?? '').isEmpty ? null : Routes.bookingDetails;

  /// Tap: mark read (in the background) and open the booking, if any.
  void open(AppNotification n) {
    unawaited(markRead(n));
    final route = routeFor(n);
    if (route != null) _navigate(route, {'bookingId': n.bookingId!});
  }

  /// "Leave a review" on a completed booking: opens it with the review open.
  void review(AppNotification n) {
    unawaited(markRead(n));
    if ((n.bookingId ?? '').isEmpty) return;
    _navigate(Routes.bookingDetails, {'bookingId': n.bookingId!, 'openReview': true});
  }

  /// This controller outlives a logout; never show one user's list to the next.
  void _resetIfOtherUser() {
    final key = _sessionKey();
    if (key != _loadedFor) {
      if (_loadedFor != null) clear();
      _loadedFor = key;
    }
  }

  /// Logout: forget everything.
  void clear() {
    _generation++;
    items.clear();
    unread = 0;
    hasMore = false;
    hasLoaded = false;
    errorMessage = null;
    update();
  }
}
