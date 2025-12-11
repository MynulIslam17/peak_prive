import '../../shared/models/hire_service_model.dart';
import '../../shared/models/provider_home_model.dart';

extension RecentServiceToHireResult on RecentService {
  HireResult toHireResult() {
    return HireResult(
      id: id,
      title: title,
      thumbnail: thumbnail,
      serviceArea: serviceArea,
      extraChargePerHour: extraChargePerHour, // ensure this field exists in RecentService
      totalPrice: totalPrice,
      averageRating: averageRating,
      items: items?.map((e) => Item(
        id: e.id,
        name: e.productName ?? e.description,
        productPhoto: e.productPhoto ?? e.photo,
        price: e.price,
        quantity: e.totalQty,
        availableQty: e.availableQty,
      )).toList(),
      reviews: reviews ?? [],
      refunds: refunds ?? [],
      createdAt: (createdAt != null && createdAt.isNotEmpty)
          ? DateTime.tryParse(createdAt)
          : null,
      updatedAt: (updatedAt != null && updatedAt.isNotEmpty)
          ? DateTime.tryParse(updatedAt)
          : null,
      category: category != null ? Category(
        id: category?.id ?? '',
        name: category?.name ?? '',
        categoryPhoto: category?.categoryPhoto ?? '',
      ) : null,
    );
  }
}


