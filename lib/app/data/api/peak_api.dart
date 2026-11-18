import '../models/network_response.dart';
import '../services/network/network_caller.dart';
import 'api_result.dart';
import 'json_read.dart';
import 'models/app_notification.dart';
import 'models/availability.dart';
import 'models/booking.dart';
import 'models/booking_request.dart';
import 'models/dashboard.dart';
import 'models/listing.dart';
import 'models/listing_form.dart';
import 'models/service_kind.dart';
import 'models/wallet.dart';

export 'api_result.dart';
export 'models/app_notification.dart';
export 'models/availability.dart';
export 'models/booking.dart';
export 'models/booking_request.dart';
export 'models/dashboard.dart';
export 'models/listing.dart';
export 'models/listing_form.dart';
export 'models/service_kind.dart';
export 'models/wallet.dart';

/// Shared request/parse plumbing for the API groups below.
abstract class _ApiGroup {
  _ApiGroup(this._http, this._base);

  final NetworkCaller _http;
  final String _base;

  String url(String path, [Map<String, Object?> query = const {}]) {
    final q = <String, String>{};
    query.forEach((k, v) {
      if (v == null) return;
      final s = v is DateTime ? formatDay(v) : v.toString().trim();
      if (s.isNotEmpty) q[k] = s;
    });
    final uri = Uri.parse('$_base$path');
    return (q.isEmpty ? uri : uri.replace(queryParameters: q)).toString();
  }

  ApiResult<T> object<T>(NetworkResponse r, T Function(Json json) parse) {
    if (!r.isSuccess) return ApiResult.failed(ApiFailure.fromResponse(r));
    final data = readMap(r.body?['data']);
    if (data == null) return ApiResult.failed(ApiFailure.badShape());
    try {
      return ApiResult.success(parse(data), message: readString(r.body?['message']));
    } catch (_) {
      return ApiResult.failed(ApiFailure.badShape());
    }
  }

  /// List endpoints: `data` is the array, paging in `meta`. Also reads the
  /// previous `{result, pagination}` shape in case an old route answers.
  ApiResult<Paged<T>> page<T>(NetworkResponse r, T Function(Json json) parse) {
    if (!r.isSuccess) return ApiResult.failed(ApiFailure.fromResponse(r));
    final body = r.body;
    var raw = body?['data'];
    var meta = readMap(body?['meta']);
    final legacy = readMap(raw);
    if (legacy != null && legacy['result'] is List) {
      raw = legacy['result'];
      meta ??= readMap(legacy['pagination']);
    }
    if (raw is! List) return ApiResult.failed(ApiFailure.badShape());
    final items = readList(raw, parse);
    final m = PageMeta.fromJson(meta, fallbackCount: items.length);
    return ApiResult.success(Paged(items, m), message: readString(body?['message']), meta: m);
  }

  ApiResult<void> done(NetworkResponse r) => r.isSuccess
      ? ApiResult<void>.success(null, message: readString(r.body?['message']))
      : ApiResult.failed(ApiFailure.fromResponse(r));
}

/// Browse, detail, reviews and provider CRUD for the five listing types.
class ListingApi extends _ApiGroup {
  ListingApi(super.http, super.base);

  /// `GET /<service>` (public). [subCategory] is a sub-category name or id.
  Future<ApiResult<Paged<ListingCard>>> browse(
    ServiceKind kind, {
    String? search,
    String? subCategory,
    PassType? passType,
    String? serviceArea,
    num? minPrice,
    num? maxPrice,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    final r = await _http.getRequest(
      url: url('/${kind.path}', {
        'search': search,
        if (kind.hasSubCategories) 'category': subCategory,
        if (kind == ServiceKind.skiPass) 'passType': passType?.apiValue,
        'serviceArea': serviceArea,
        'minPrice': minPrice,
        'maxPrice': maxPrice,
        'sort': sort,
        'page': page,
        'limit': limit.clamp(1, 50),
      }),
    );
    return this.page(r, (j) => ListingCard.fromJson(j, fallbackKind: kind));
  }

  /// `GET /<service>/my`: the provider's own listings, active and inactive.
  Future<ApiResult<Paged<ListingCard>>> mine(
    ServiceKind kind, {
    String? search,
    bool? active,
    int page = 1,
    int limit = 20,
  }) async {
    final r = await _http.getRequest(
      url: url('/${kind.path}/my', {
        'search': search,
        'status': active == null ? null : (active ? 'active' : 'inactive'),
        'page': page,
        'limit': limit.clamp(1, 50),
      }),
    );
    return this.page(r, (j) => ListingCard.fromJson(j, fallbackKind: kind));
  }

  /// Every page of [mine] (for the provider's "My services" screen).
  Future<ApiResult<List<ListingCard>>> allMine(ServiceKind kind, {int maxPages = 20}) async {
    final all = <ListingCard>[];
    for (var p = 1; p <= maxPages; p++) {
      final r = await mine(kind, page: p, limit: 50);
      if (!r.isSuccess) {
        if (all.isEmpty) return ApiResult.failed(r.failure!);
        break;
      }
      all.addAll(r.data!.items);
      if (!r.data!.hasMore) break;
    }
    return ApiResult.success(List.unmodifiable(all));
  }

  Future<ApiResult<ListingDetail>> detail(ServiceKind kind, String id) async {
    if (id.isEmpty) return ApiResult.failed(const ApiFailure(message: 'Listing not found.', statusCode: 404));
    final r = await _http.getRequest(url: url('/${kind.path}/$id'));
    return object(r, (j) => ListingDetail.fromJson(j, expected: kind));
  }

  /// Massage wraps the list as `data: {reviews, rating}`; the others send
  /// `data: [...]` with `rating` next to it.
  Future<ApiResult<ReviewsPage>> reviews(ServiceKind kind, String id, {int page = 1, int limit = 10}) async {
    final r = await _http.getRequest(url: url('/${kind.path}/$id/reviews', {'page': page, 'limit': limit}));
    if (!r.isSuccess) return ApiResult.failed(ApiFailure.fromResponse(r));
    final body = r.body;
    final data = body?['data'];
    final wrapped = readMap(data);
    final list = wrapped != null ? wrapped['reviews'] : data;
    final rating = readMap(wrapped?['rating']) ?? readMap(body?['rating']);
    if (list is! List) return ApiResult.failed(ApiFailure.badShape());
    final reviews = readList(list, Review.fromJson);
    return ApiResult.success(
      ReviewsPage(reviews: reviews, rating: RatingSummary.fromJson(rating)),
      meta: PageMeta.fromJson(readMap(body?['meta']), fallbackCount: reviews.length),
    );
  }

  /// `POST /<service>/:id/review` (customer with a completed booking, once).
  Future<ApiResult<RatingSummary>> addReview(ServiceKind kind, String id, {required int rating, required String comment}) async {
    if (rating < 1 || rating > 5) {
      return ApiResult.failed(const ApiFailure(message: 'Choose 1 to 5 stars.', statusCode: 400));
    }
    if (comment.trim().isEmpty) {
      return ApiResult.failed(const ApiFailure(message: 'Write a short comment.', statusCode: 400));
    }
    final r = await _http.postRequest(url: url('/${kind.path}/$id/review'), body: {'rating': rating, 'comment': comment.trim()});
    return object(r, (j) => RatingSummary.fromJson(readMap(j['rating'])));
  }

  /// `GET /common/category/<service>`: sub-categories for filters and forms.
  Future<ApiResult<List<CategoryOption>>> categories(ServiceKind kind) async {
    if (!kind.hasSubCategories) return const ApiResult.success([]);
    final r = await _http.getRequest(url: url('/common/category/${kind.path}'));
    return page(r, CategoryOption.fromJson).map((p) => p.items);
  }

  Future<ApiResult<ListingDetail>> create(ListingForm form) async {
    final r = await _http.multipartRequest(url: url('/${form.kind.path}'), fields: form.fields, files: form.files);
    return object(r, (j) => ListingDetail.fromJson(j, expected: form.kind));
  }

  Future<ApiResult<ListingDetail>> update(String id, ListingForm form) async {
    final r = await _http.multipartRequest(url: url('/${form.kind.path}/$id'), method: 'PATCH', fields: form.fields, files: form.files);
    return object(r, (j) => ListingDetail.fromJson(j, expected: form.kind));
  }

  /// Hide/show in browse; existing bookings continue.
  Future<ApiResult<bool>> setActive(ServiceKind kind, String id, bool active) async {
    final r = await _http.patchRequest(url: url('/${kind.path}/$id/status'), body: {'isActive': active});
    return object(r, (j) => readBool(j['isActive']) ?? active);
  }

  /// Soft delete. 409 while the listing has open bookings.
  Future<ApiResult<void>> delete(ServiceKind kind, String id) async {
    final r = await _http.deleteRequest(url: url('/${kind.path}/$id'));
    return done(r);
  }

  /// `GET /restaurant/service-fee` → `{serviceFee}`.
  Future<ApiResult<num>> restaurantServiceFee() async {
    final r = await _http.getRequest(url: url('/restaurant/service-fee'));
    return object(r, (j) => readNum(j['serviceFee']) ?? 0);
  }
}

/// Booking tabs for the customer (`/booking/my`) and provider (`/booking/provider`).
enum BookingTab {
  requests('requests', 'Requests'),
  upcoming('upcoming', 'Upcoming'),
  active('active', 'Active'),
  past('past', 'Past'),
  cancelled('cancelled', 'Cancelled');

  const BookingTab(this.apiValue, this.label);
  final String apiValue;
  final String label;
}

class BookingApi extends _ApiGroup {
  BookingApi(super.http, super.base, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;

  Booking _parse(Json j) => Booking.fromJson(j, receivedAt: _clock());

  /// Ski hire: free units per item for the period.
  Future<ApiResult<Availability>> hireAvailability(String listingId, DateTime start, DateTime end) async {
    final r = await _http.getRequest(
      url: url('/booking/availability/$listingId', {'start': formatInstant(start), 'end': formatInstant(end)}),
    );
    return object(r, Availability.fromJson);
  }

  /// Restaurant: slots and free seats on [day].
  Future<ApiResult<Availability>> restaurantAvailability(String listingId, DateTime day) async {
    final r = await _http.getRequest(url: url('/booking/availability/$listingId', {'date': formatDay(day)}));
    return object(r, Availability.fromJson);
  }

  /// Massage: every start time on [day] for a session of [duration]
  /// ("60 min") and [persons], with the places left.
  Future<ApiResult<Availability>> massageSlots(String listingId, DateTime day, String duration, int persons) async {
    final r = await _http.getRequest(
      url: url('/booking/availability/$listingId', {
        'date': formatDay(day),
        'duration': duration,
        'personCount': '$persons',
      }),
    );
    return object(r, Availability.fromJson);
  }

  /// Transport (with dates), ski pass, massage: `{available}`.
  Future<ApiResult<Availability>> availability(String listingId, {DateTime? start, DateTime? end}) async {
    final r = await _http.getRequest(
      url: url('/booking/availability/$listingId', {
        if (start != null) 'start': formatInstant(start),
        if (end != null) 'end': formatInstant(end),
      }),
    );
    return object(r, Availability.fromJson);
  }

  /// Checks the booking and creates the Stripe intent. Nothing is booked yet.
  Future<ApiResult<PaymentIntentData>> intent(BookingRequest request) async {
    final r = await _http.postRequest(url: url('/booking/intent'), body: request.toJson());
    return object(r, PaymentIntentData.fromJson);
  }

  /// After the payment sheet succeeds. Idempotent per [paymentIntentId].
  Future<ApiResult<Booking>> create(String paymentIntentId, BookingRequest request) async {
    final r = await _http.postRequest(url: url('/booking/create'), body: request.toCreateJson(paymentIntentId));
    return object(r, _parse);
  }

  /// Customer bookings. No [tab] = all, newest first.
  Future<ApiResult<Paged<Booking>>> mine({BookingTab? tab, ServiceKind? kind, DateTime? date, int page = 1, int limit = 10}) async {
    final r = await _http.getRequest(
      url: url('/booking/my', {
        'tab': tab == BookingTab.requests ? null : tab?.apiValue,
        'category': kind?.apiValue,
        'date': date,
        'page': page,
        'limit': limit.clamp(1, 50),
      }),
    );
    return this.page(r, _parse);
  }

  /// Provider bookings. [BookingTab.requests] = waiting for approval.
  Future<ApiResult<Paged<Booking>>> forProvider({BookingTab? tab, ServiceKind? kind, DateTime? date, int page = 1, int limit = 10}) async {
    final r = await _http.getRequest(
      url: url('/booking/provider', {
        'tab': tab?.apiValue,
        'category': kind?.apiValue,
        'date': date,
        'page': page,
        'limit': limit.clamp(1, 50),
      }),
    );
    return this.page(r, _parse);
  }

  Future<ApiResult<Booking>> detail(String id) async {
    if (id.isEmpty) return ApiResult.failed(const ApiFailure(message: 'Booking not found.', statusCode: 404));
    final r = await _http.getRequest(url: url('/booking/$id'));
    return object(r, _parse);
  }

  /// Runs a PATCH action (approve, reject, hand over, return, complete,
  /// cancel). Returns the updated booking. A 409 means it changed meanwhile.
  Future<ApiResult<Booking>> act(String id, BookingAction action, {String? reason}) async {
    final seg = action.pathSegment;
    if (seg == null) {
      return ApiResult.failed(ApiFailure(message: '${action.label} is not a direct action.', statusCode: 400));
    }
    final why = reason?.trim();
    final r = await _http.patchRequest(
      url: url('/booking/$id/$seg'),
      body: (action == BookingAction.reject || action == BookingAction.cancel) && why != null && why.isNotEmpty
          ? {'reason': why}
          : const <String, dynamic>{},
    );
    return object(r, _parse);
  }

  Future<ApiResult<PaymentIntentData>> lateFeeIntent(String id) async {
    final r = await _http.postRequest(url: url('/booking/$id/late-fee/intent'), body: const {});
    return object(r, PaymentIntentData.fromJson);
  }

  /// Idempotent; the webhook confirms it too.
  Future<ApiResult<Booking>> lateFeeConfirm(String id, String paymentIntentId) async {
    final r = await _http.postRequest(url: url('/booking/$id/late-fee/confirm'), body: {'paymentIntentId': paymentIntentId});
    return object(r, _parse);
  }
}

class NotificationApi extends _ApiGroup {
  NotificationApi(super.http, super.base);

  /// `meta.unread` carries the unread total.
  Future<ApiResult<Paged<AppNotification>>> list({int page = 1, int limit = 20, bool unreadOnly = false}) async {
    final r = await _http.getRequest(
      url: url('/notifications', {'page': page, 'limit': limit.clamp(1, 50), if (unreadOnly) 'unread': 'true'}),
    );
    return this.page(r, AppNotification.fromJson);
  }

  Future<ApiResult<int>> unreadCount() async {
    final r = await _http.getRequest(url: url('/notifications/unread-count'));
    return object(r, (j) => readInt(j['unread']) ?? 0);
  }

  Future<ApiResult<void>> markRead(String id) async => done(await _http.patchRequest(url: url('/notifications/$id/read')));

  Future<ApiResult<void>> markAllRead() async => done(await _http.patchRequest(url: url('/notifications/read-all')));
}

class WalletApi extends _ApiGroup {
  WalletApi(super.http, super.base);

  Future<ApiResult<num>> balance() async {
    final r = await _http.getRequest(url: url('/wallet/get-balance'));
    return object(r, (j) => readNum(j['balance']) ?? 0);
  }

  Future<ApiResult<WalletAccount>> account() async {
    final r = await _http.getRequest(url: url('/wallet/get-my-account'));
    return object(r, WalletAccount.fromJson);
  }

  Future<ApiResult<void>> addAccount({required String accountType, required String cardNumber, required String cardHolderName}) async {
    final digits = cardNumber.replaceAll(RegExp(r'\s|-'), '');
    if (digits.isEmpty || cardHolderName.trim().isEmpty) {
      return ApiResult.failed(const ApiFailure(message: 'Enter the account number and holder name.', statusCode: 400));
    }
    final r = await _http.postRequest(
      url: url('/wallet/add'),
      body: {'accountType': accountType, 'cardNumber': digits, 'cardHolderName': cardHolderName.trim()},
    );
    return done(r);
  }

  /// The amount is reserved from the balance immediately.
  Future<ApiResult<void>> withdraw({required String accountId, required num amount, num? balance}) async {
    if (amount <= 0) return ApiResult.failed(const ApiFailure(message: 'Enter an amount above 0.', statusCode: 400));
    if (balance != null && amount > balance) {
      return ApiResult.failed(const ApiFailure(message: 'That is more than your balance.', statusCode: 400));
    }
    final r = await _http.postRequest(url: url('/Withdraw/send-request'), body: {'cardId': accountId, 'amount': amount});
    return done(r);
  }

  Future<ApiResult<Paged<Withdrawal>>> withdrawals({int page = 1, int limit = 20}) async {
    final r = await _http.getRequest(url: url('/Withdraw/my', {'page': page, 'limit': limit}));
    return this.page(r, Withdrawal.fromJson);
  }

  /// Customer payment history. [purpose]: `booking` or `late_fee`.
  Future<ApiResult<Paged<PaymentRecord>>> payments({String? purpose, int page = 1, int limit = 20}) async {
    final r = await _http.getRequest(url: url('/payment/all', {'purpose': purpose, 'page': page, 'limit': limit}));
    return this.page(r, PaymentRecord.fromJson);
  }
}

class DashboardApi extends _ApiGroup {
  DashboardApi(super.http, super.base);

  Future<ApiResult<ProviderDashboard>> provider() async {
    final r = await _http.getRequest(url: url('/dashboard/meta/provider'));
    return object(r, (j) => ProviderDashboard.fromJson(j, receivedAt: DateTime.now()));
  }
}

/// Entry point: `Get.find<PeakApi>().bookings.detail(id)`.
class PeakApi {
  PeakApi(NetworkCaller http, {required String baseUrl, DateTime Function()? clock})
      : listings = ListingApi(http, baseUrl),
        bookings = BookingApi(http, baseUrl, clock: clock),
        notifications = NotificationApi(http, baseUrl),
        wallet = WalletApi(http, baseUrl),
        dashboard = DashboardApi(http, baseUrl);

  final ListingApi listings;
  final BookingApi bookings;
  final NotificationApi notifications;
  final WalletApi wallet;
  final DashboardApi dashboard;
}
