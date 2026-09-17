import '../models/order.dart';
import '../models/order_item.dart';
import '../models/page_result.dart';
import 'order_repository.dart';
import 'seed_data.dart';

class InMemoryOrderRepository implements OrderRepository {
  final List<Order> _orders = [];
  final List<OrderItem> _orderItems = [];
  int _nextOrderId = 1;
  int _nextOrderItemId = 1;

  InMemoryOrderRepository() {
    _orders.addAll(seedOrders);
    _nextOrderId = _orders.map((o) => o.id).reduce((a, b) => a > b ? a : b) + 1;
    // Если есть позиции, вычисляем следующий ID
    if (_orderItems.isNotEmpty) {
      _nextOrderItemId = _orderItems.map((oi) => oi.id).reduce((a, b) => a > b ? a : b) + 1;
    }
  }

  @override
  Future<PageResult<Order>> find() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final items = _orders.where((o) => !o.isDeleted).toList();
    return PageResult(
      items: items,
      page: 1,
      size: items.length,
      total: items.length,
    );
  }

  @override
  Future<Order?> findById(int id) async {
    try {
      final order = _orders.firstWhere((o) => o.id == id && !o.isDeleted);
      final items = _orderItems.where((oi) => oi.orderId == id && !oi.isDeleted).toList(); // now isDeleted exists
      return order.copyWith(items: items);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Order> create(Order order) async {
    final newOrder = Order(
      id: _nextOrderId++,
      customerId: order.customerId,
      items: [],
      orderDate: DateTime.now(),
      status: 'pending',
      total: order.total,
    );
    _orders.add(newOrder);

    for (final item in order.items) {
      final newItem = OrderItem(
        id: _nextOrderItemId++,
        orderId: newOrder.id,
        phoneId: item.phoneId,
        quantity: item.quantity,
        price: item.price,
      );
      _orderItems.add(newItem);
    }
    return newOrder;
  }

  @override
  Future<Order> update(Order order) async {
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index == -1) throw StateError('Заказ не найден');
    _orders[index] = order;
    return order;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) throw StateError('Заказ не найден');
    _orders[index] = _orders[index].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _orders.removeWhere((o) => o.id == id);
    _orderItems.removeWhere((oi) => oi.orderId == id);
  }

  @override
  Future<void> restore(int id) async {
    final index = _orders.indexWhere((o) => o.id == id);
    if (index == -1) throw StateError('Заказ не найден');
    _orders[index] = _orders[index].copyWith(clearDeletedAt: true);
  }
}