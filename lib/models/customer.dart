class Customer {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final int? loyaltyCardId; 
  final int loyaltyPoints;
  final DateTime createdAt;
  final DateTime? deletedAt;

  const Customer({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.loyaltyCardId,
    this.loyaltyPoints = 0,
    required this.createdAt,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Customer copyWith({
    String? fullName,
    String? email,
    String? phone,
    int? loyaltyCardId,
    int? loyaltyPoints,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Customer(
      id: id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      loyaltyCardId: loyaltyCardId ?? this.loyaltyCardId,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'loyaltyCardId': loyaltyCardId,
        'loyaltyPoints': loyaltyPoints,
        'createdAt': createdAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as int? ?? 0,
        fullName: json['fullName'] as String? ?? '',
        email: json['email'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        loyaltyCardId: json['loyaltyCardId'] as int?,
        loyaltyPoints: json['loyaltyPoints'] as int? ?? 0,
        createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      );
}