import '../../../../data/api/peak_api.dart';
import '../../shared/controllers/listing_detail_controller.dart';

/// Ski pass listing (`GET /ski-pass/:id`) + reviews.
class PassDetailsController extends ListingDetailController<SkiPassDetail> {
  PassDetailsController() : super(ServiceKind.skiPass);

  /// Back-compat names.
  SkiPassDetail? get passDetails => listing;
  bool get fetchProgress => isLoading;
  Future<bool> fetchPass(String id) => fetch(id);
}
