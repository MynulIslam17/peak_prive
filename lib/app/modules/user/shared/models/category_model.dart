class ServiceCategory {
  final String id;
  final String name;
  final String categoryPhoto;

  ServiceCategory({
    required this.id,
    required this.name,
    required this.categoryPhoto,
  });

  factory ServiceCategory.fromJson(Map<String, dynamic> json) => ServiceCategory(
    id: json['_id'] ?? '',
    name: json['name'] ?? '',
    categoryPhoto: json['categoryPhoto'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'categoryPhoto': categoryPhoto,
  };
}
