class Review {
  final int id;
  final int customerId; // M:1 → Customer
  final int phoneId;    // M:1 → Phone
  final int rating;     // 1–5
  final String comment;
  final DateTime date;
  final DateTime? deletedAt;

  const Review({
    required this.id,
    required this.customerId,
    required this.phoneId,
    required this.rating,
    this.comment = '',
    required this.date,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Review copyWith({
    int? customerId,
    int? phoneId,
    int? rating,
    String? comment,
    DateTime? date,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Review(
      id: id,
      customerId: customerId ?? this.customerId,
      phoneId: phoneId ?? this.phoneId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'phoneId': phoneId,
        'rating': rating,
        'comment': comment,
        'date': date.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as int? ?? 0,
        customerId: (json['customer_id'] ?? json['customerId']) as int? ?? 0,
        phoneId: (json['phone_id'] ?? json['phoneId']) as int? ?? 0,
        rating: json['rating'] as int? ?? 0,
        comment: json['comment'] as String? ?? '',
        date: (json['review_date'] ?? json['date']) != null
            ? DateTime.parse((json['review_date'] ?? json['date']) as String)
            : DateTime.now(),
        deletedAt: (json['deleted_at'] ?? json['deletedAt']) != null
            ? DateTime.parse((json['deleted_at'] ?? json['deletedAt']) as String)
            : null,
      );
}