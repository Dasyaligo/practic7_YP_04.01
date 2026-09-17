class Brand {
  final int id;
  final String name;
  final String country;
  final int? foundedYear;
  final DateTime? deletedAt;

  const Brand({
    required this.id,
    required this.name,
    required this.country,
    this.foundedYear,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Brand copyWith({
    String? name,
    String? country,
    int? foundedYear,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Brand(
      id: id,
      name: name ?? this.name,
      country: country ?? this.country,
      foundedYear: foundedYear ?? this.foundedYear,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'country': country,
        'foundedYear': foundedYear,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Brand.fromJson(Map<String, dynamic> json) => Brand(
        id: json['id'] as int? ?? 0,
        name: json['name'] as String? ?? '',
        country: json['country'] as String? ?? '',
        foundedYear:
            (json['founded_year'] ?? json['foundedYear']) as int?,
        deletedAt: (json['deleted_at'] ?? json['deletedAt']) != null
            ? DateTime.parse(
                (json['deleted_at'] ?? json['deletedAt']) as String)
            : null,
      );
}