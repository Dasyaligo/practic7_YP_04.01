class Phone {
  final int id;
  final String model;
  final int brandId;
  final double price;
  final int? storage;
  final int? ram;
  final String? color;
  final double? screenSize;
  final int stock;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const Phone({
    required this.id,
    required this.model,
    required this.brandId,
    required this.price,
    this.storage,
    this.ram,
    this.color,
    this.screenSize,
    required this.stock,
    required this.createdAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Phone copyWith({
    String? model,
    int? brandId,
    double? price,
    int? storage,
    int? ram,
    String? color,
    double? screenSize,
    int? stock,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Phone(
      id: id,
      model: model ?? this.model,
      brandId: brandId ?? this.brandId,
      price: price ?? this.price,
      storage: storage ?? this.storage,
      ram: ram ?? this.ram,
      color: color ?? this.color,
      screenSize: screenSize ?? this.screenSize,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'model': model,
        'brandId': brandId,
        'price': price,
        'storage': storage,
        'ram': ram,
        'color': color,
        'screenSize': screenSize,
        'stock': stock,
        'createdAt': createdAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Phone.fromJson(Map<String, dynamic> json) {
    // Безопасный парсинг даты
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return Phone(
      id: json['id'] as int? ?? 0,
      model: json['model'] as String? ?? '',
      brandId: (json['brand_id'] ?? json['brandId']) as int? ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      storage: json['storage'] as int?,
      ram: json['ram'] as int?,
      color: json['color'] as String?,
      screenSize: ((json['screen_size'] ?? json['screenSize']) as num?)?.toDouble(),
      stock: json['stock'] as int? ?? 0,
      createdAt: parseDate(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      deletedAt: parseDate(json['deleted_at'] ?? json['deletedAt']),
    );
  }
}