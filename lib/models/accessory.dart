class Accessory {
  final int id;
  final String name;
  final String category;
  final double price;
  final String? description;
  final DateTime? deletedAt;

  const Accessory({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    this.description,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Accessory copyWith({
    String? name,
    String? category,
    double? price,
    String? description,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Accessory(
      id: id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      description: description ?? this.description,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'price': price,
        'description': description,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Accessory.fromJson(Map<String, dynamic> json) => Accessory(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        description: json['description'] as String?,
        deletedAt: json['deletedAt'] != null
            ? DateTime.parse(json['deletedAt'] as String)
            : null,
      );
}