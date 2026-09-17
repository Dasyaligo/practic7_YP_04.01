class LoyaltyCard {
  final int id;
  final int customerId;
  final String cardNumber;
  final int points;
  final DateTime issuedAt;
  final DateTime? expiresAt;
  final DateTime? deletedAt;

  const LoyaltyCard({
    required this.id,
    required this.customerId,
    required this.cardNumber,
    this.points = 0,
    required this.issuedAt,
    this.expiresAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  LoyaltyCard copyWith({
    int? customerId,
    String? cardNumber,
    int? points,
    DateTime? issuedAt,
    DateTime? expiresAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return LoyaltyCard(
      id: id,
      customerId: customerId ?? this.customerId,
      cardNumber: cardNumber ?? this.cardNumber,
      points: points ?? this.points,
      issuedAt: issuedAt ?? this.issuedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'cardNumber': cardNumber,
        'points': points,
        'issuedAt': issuedAt.toIso8601String(),
        'expiresAt': expiresAt?.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => LoyaltyCard(
        id: json['id'] as int? ?? 0,
        customerId: json['customerId'] as int? ?? 0,
        cardNumber: json['cardNumber'] as String? ?? '',
        points: json['points'] as int? ?? 0,
        issuedAt: json['issuedAt'] != null ? DateTime.parse(json['issuedAt'] as String) : DateTime.now(),
        expiresAt: json['expiresAt'] != null ? DateTime.parse(json['expiresAt'] as String) : null,
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      );
}