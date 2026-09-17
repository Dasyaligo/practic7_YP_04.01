import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';
import '../models/order_item.dart';
import '../models/page_result.dart';
import '../core/supabase_client.dart';
import 'order_repository.dart';

class ApiOrderRepository implements OrderRepository {
  SupabaseClient get _db => SupabaseClientHolder.client;

  @override
  Future<PageResult<Order>> find() async {
    final data = await _db
        .from('orders')
        .select('*, order_items(*)')
        .isFilter('deleted_at', null)
        .order('id', ascending: false);

    final items = (data as List).map((raw) {
      final map = raw as Map<String, dynamic>;
      final orderItemsRaw = (map['order_items'] as List?) ?? const [];
      final orderItems = orderItemsRaw
          .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return Order.fromJson({...map, 'items': orderItems});
    }).toList();

    return PageResult(
      items: items,
      page: 1,
      size: items.length,
      total: items.length,
    );
  }

  @override
  Future<Order?> findById(int id) async {
    final data = await _db
        .from('orders')
        .select('*, order_items(*)')
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    if (data == null) return null;
    final orderItemsRaw = (data['order_items'] as List?) ?? const [];
    final orderItems = orderItemsRaw
        .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return Order.fromJson({...data, 'items': orderItems});
  }

  @override
  Future<Order> create(Order order) async {
    final inserted = await _db.from('orders').insert({
      'customer_id': order.customerId,
      'status': order.status,
      'total': order.total,
    }).select().single();

    final orderId = inserted['id'] as int;

    for (final item in order.items) {
      await _db.from('order_items').insert({
        'order_id': orderId,
        'phone_id': item.phoneId,
        'quantity': item.quantity,
        'price': item.price,
      });
    }

    return Order.fromJson({...inserted, 'items': order.items});
  }

  @override
  Future<Order> update(Order order) async {
    await _db.from('orders').update({
      'customer_id': order.customerId,
      'status': order.status,
      'total': order.total,
    }).eq('id', order.id);

    return order;
  }

  @override
  Future<void> softDelete(int id) async {
    await _db.from('orders').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  @override
  Future<void> hardDelete(int id) async {
    await _db.from('order_items').delete().eq('order_id', id);
    await _db.from('orders').delete().eq('id', id);
  }

  @override
  Future<void> restore(int id) async {
    await _db.from('orders').update({'deleted_at': null}).eq('id', id);
  }
}