/// The five services. One value per backend `category`.
enum ServiceKind {
  skiPass('Ski_Pass', 'ski-pass', 'Ski pass'),
  skiHire('Ski_Hire', 'ski-hire', 'Ski hire'),
  transport('Transport', 'transport', 'Transport'),
  restaurant('Restaurant', 'restaurant', 'Restaurant'),
  massage('Massage', 'massage', 'Massage');

  const ServiceKind(this.apiValue, this.path, this.label);

  /// `category` in JSON, e.g. `Ski_Hire`; also the `?category=` booking filter.
  final String apiValue;

  /// URL segment, e.g. `/ski-hire`, `/common/category/ski-hire`.
  final String path;

  /// Human label.
  final String label;

  /// Rentals have hand-over, return and late fees.
  bool get isRental => this == skiHire || this == transport;

  /// Ski passes have no sub-categories.
  bool get hasSubCategories => this != skiPass;

  /// Bookings wait for the provider (everything except ski passes).
  bool get needsApproval => this != skiPass;

  /// Accepts `Ski_Hire`, `ski-hire`, `ski_hire`, `skihire`, `Ski Hire`.
  static ServiceKind? parse(dynamic value) {
    if (value is! String) return null;
    final key = value.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    for (final k in values) {
      if (k.apiValue.toLowerCase().replaceAll('_', '') == key) return k;
    }
    return null;
  }
}
