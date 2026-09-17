import 'order_item.dart';  

class Order {
  final int id;
  final int customerId;
  final List<OrderItem> items;
  final DateTime orderDate;
  final String status;
  final double total;
  final DateTime? deletedAt;

  const Order({
    required this.id,
    required this.customerId,
    required this.items,
    required this.orderDate,
    this.status = 'pending',
    this.total = 0,
    this.deletedAt,
  });

  bool get isDeleted => deletedAt != null;

  Order copyWith({
    int? customerId,
    List<OrderItem>? items,
    DateTime? orderDate,
    String? status,
    double? total,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return Order(
      id: id,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      orderDate: orderDate ?? this.orderDate,
      status: status ?? this.status,
      total: total ?? this.total,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'items': items.map((i) => i.toJson()).toList(),
        'orderDate': orderDate.toIso8601String(),
        'status': status,
        'total': total,
        'deletedAt': deletedAt?.toIso8601String(),
      };

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id'] as int? ?? 0,
        customerId: json['customerId'] as int? ?? 0,
        items: (json['items'] as List?)?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList() ?? [],
        orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate'] as String) : DateTime.now(),
        status: json['status'] as String? ?? 'pending',
        total: (json['total'] as num?)?.toDouble() ?? 0.0,
        deletedAt: json['deletedAt'] != null ? DateTime.parse(json['deletedAt'] as String) : null,
      );
}