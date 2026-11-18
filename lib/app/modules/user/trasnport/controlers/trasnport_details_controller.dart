import '../../../../data/api/peak_api.dart';
import '../../shared/controllers/listing_detail_controller.dart';

/// Transport listing (`GET /transport/:id`) + reviews.
class TransportDetailsController extends ListingDetailController<TransportDetail> {
  TransportDetailsController() : super(ServiceKind.transport);

  /// Bookable: active and priced.
  bool get isBookable => canBook && (listing?.price.amount ?? 0) > 0;

  /// Back-compat names.
  TransportDetail? get transportDetails => listing;
  Future<bool> fetchTransportDetails(String id) => fetch(id);
}
