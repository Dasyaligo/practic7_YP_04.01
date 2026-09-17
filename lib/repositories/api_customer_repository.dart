import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/customer.dart';
import '../models/page_result.dart';
import '../core/supabase_client.dart';
import 'customer_repository.dart';

class ApiCustomerRepository implements CustomerRepository {
  SupabaseClient get _db => SupabaseClientHolder.client;

  @override
  Future<PageResult<Customer>> find(CustomerQuery q) async {
    dynamic query = _db.from('customers').select();
    if (!q.includeDeleted) query = query.isFilter('deleted_at', null);
    if (q.search.trim().isNotEmpty) {
      final s = q.search.trim();
      query = query.or('full_name.ilike.%$s%,email.ilike.%$s%,phone.ilike.%$s%');
    }
    final from = (q.page - 1) * q.size;
    final to = from + q.size - 1;
    query = query.order(q.sortField, ascending: q.sortAscending).range(from, to);
    final data = await query;
    final items = (data as List)
        .map((e) => Customer.fromJson(e as Map<String, dynamic>))
        .toList();

    dynamic countQ = _db.from('customers').select('id');
    if (!q.includeDeleted) countQ = countQ.isFilter('deleted_at', null);
    final countData = await countQ;
    final total = (countData as List).length;

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Customer?> findById(int id) async {
    final data = await _db
        .from('customers')
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    if (data == null) return null;
    return Customer.fromJson(data);
  }

  @override
  Future<Customer> create(Customer c) async {
    final data = await _db.from('customers').insert({
      'full_name': c.fullName,
      'email': c.email,
      'phone': c.phone,
    }).select().single();
    return Customer.fromJson(data);
  }

  @override
  Future<Customer> update(Customer c) async {
    final data = await _db.from('customers').update({
      'full_name': c.fullName,
      'email': c.email,
      'phone': c.phone,
    }).eq('id', c.id).select().single();
    return Customer.fromJson(data);
  }

  @override
  Future<void> softDelete(int id) async {
    await _db.from('customers').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  @override
  Future<void> hardDelete(int id) async {
    await _db.from('customers').delete().eq('id', id);
  }

  @override
  Future<void> restore(int id) async {
    await _db.from('customers').update({'deleted_at': null}).eq('id', id);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return 0;
    await _db.from('customers').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).inFilter('id', ids);
    return ids.length;
  }
}