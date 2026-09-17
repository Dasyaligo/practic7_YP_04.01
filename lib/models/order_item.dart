class OrderItem {
  final int id;
  final int orderId;
  final int phoneId;
  final int quantity;
  final double price;
  final DateTime? deletedAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.phoneId,
    required this.quantity,
    required this.price,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  
  OrderItem copyWith({
    int? orderId,
    int? phoneId,
    int? quantity,
    double? price,
    DateTime? deletedAt,
  }) {
    return OrderItem(
      id: id,
      orderId: orderId ?? this.orderId,
      phoneId: phoneId ?? this.phoneId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'orderId': orderId,
        'phoneId': phoneId,
        'quantity': quantity,
        'price': price,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id'] as int? ?? 0,
        orderId: json['orderId'] as int? ?? 0,
        phoneId: json['phoneId'] as int? ?? 0,
        quantity: json['quantity'] as int? ?? 0,
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      );
}