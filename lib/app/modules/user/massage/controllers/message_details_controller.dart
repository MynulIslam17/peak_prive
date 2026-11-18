import '../../../../data/api/peak_api.dart';
import '../../shared/controllers/listing_detail_controller.dart';

/// Massage listing (`GET /massage/:id`) + reviews.
class MassageDetailsController extends ListingDetailController<MassageDetail> {
  MassageDetailsController() : super(ServiceKind.massage);

  /// Bookable: active with at least one priced duration.
  bool get isBookable =>
      canBook && (listing?.durations.any((d) => d.price > 0) ?? false);

  /// Back-compat names.
  MassageDetail? get massage => listing;
  Future<bool> fetchMassageDetails(String id) => fetch(id);
}
