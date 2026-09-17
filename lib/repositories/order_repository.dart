import '../models/order.dart';
import '../models/page_result.dart';

abstract interface class OrderRepository {
  Future<PageResult<Order>> find();
  Future<Order?> findById(int id);
  Future<Order> create(Order order);
  Future<Order> update(Order order);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
}