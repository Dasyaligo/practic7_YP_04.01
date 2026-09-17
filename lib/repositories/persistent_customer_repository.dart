import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer.dart';
import '../models/page_result.dart';
import 'customer_repository.dart';
import 'seed_data.dart';

class PersistentCustomerRepository implements CustomerRepository {
  static const String _key = 'onlyphones_customers_v2';
  final SharedPreferences _prefs;
  List<Customer> _customers = [];
  int _nextId = 1;

  PersistentCustomerRepository(this._prefs) { _restore(); }

  void _restore() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _customers = List.from(seedCustomers);
      _nextId = _customers.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
      _persist();
      return;
    }
    try {
      final list = jsonDecode(raw) as List;
      _customers = list.map((e) => Customer.fromJson(e as Map<String, dynamic>)).toList();
      _nextId = _customers.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
    } catch (e) {
      print('Ошибка восстановления данных: $e');
      _customers = List.from(seedCustomers);
      _nextId = _customers.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
      _persist();
    }
  }

  Future<void> _persist() async {
    final jsonData = jsonEncode(_customers.map((c) => c.toJson()).toList());
    await _prefs.setString(_key, jsonData);
  }

  @override
  Future<PageResult<Customer>> find(CustomerQuery q) async {
    await Future.delayed(const Duration(milliseconds: 250));

    var rows = _customers.where((c) => q.includeDeleted || !c.isDeleted).toList();

    if (q.search.trim().isNotEmpty) {
      final needle = q.search.trim().toLowerCase();
      rows = rows.where((c) =>
          c.fullName.toLowerCase().contains(needle) ||
          c.email.toLowerCase().contains(needle) ||
          c.phone.contains(needle)
      ).toList();
    }

    rows.sort((a, b) {
      final result = switch (q.sortField) {
        'email' => a.email.compareTo(b.email),
        'phone' => a.phone.compareTo(b.phone),
        _ => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
      };
      return q.sortAscending ? result : -result;
    });

    final total = rows.length;
    final from = (q.page - 1) * q.size;
    final to = (from + q.size) > total ? total : (from + q.size);
    final items = from >= total ? <Customer>[] : rows.sublist(from, to);

    return PageResult(
      items: items,
      page: q.page,
      size: q.size,
      total: total,
    );
  }

  @override
  Future<Customer?> findById(int id) async {
    try {
      return _customers.firstWhere((c) => c.id == id && !c.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Customer> create(Customer customer) async {
    final newCustomer = Customer(
      id: _nextId++,
      fullName: customer.fullName,
      email: customer.email,
      phone: customer.phone,
      loyaltyCardId: customer.loyaltyCardId,
      loyaltyPoints: customer.loyaltyPoints,
      createdAt: DateTime.now(),
    );
    _customers.add(newCustomer);
    await _persist();
    return newCustomer;
  }

  @override
  Future<Customer> update(Customer customer) async {
    final index = _customers.indexWhere((c) => c.id == customer.id);
    if (index == -1) throw StateError('Покупатель с ID ${customer.id} не найден');
    _customers[index] = customer;
    await _persist();
    return customer;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index == -1) throw StateError('Покупатель с ID $id не найден');
    _customers[index] = _customers[index].copyWith(deletedAt: DateTime.now());
    await _persist();
  }

  @override
  Future<void> hardDelete(int id) async {
    _customers.removeWhere((c) => c.id == id);
    await _persist();
  }

  @override
  Future<void> restore(int id) async {
    final index = _customers.indexWhere((c) => c.id == id);
    if (index == -1) throw StateError('Покупатель с ID $id не найден');
    _customers[index] = _customers[index].copyWith(clearDeletedAt: true);
    await _persist();
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    int count = 0;
    for (final id in ids) {
      final index = _customers.indexWhere((c) => c.id == id && !c.isDeleted);
      if (index != -1) {
        _customers[index] = _customers[index].copyWith(deletedAt: DateTime.now());
        count++;
      }
    }
    await _persist();
    return count;
  }
}