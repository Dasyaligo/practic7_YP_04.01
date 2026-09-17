import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';
import '../models/page_result.dart';
import '../core/supabase_client.dart';
import 'employee_repository.dart';

class ApiEmployeeRepository implements EmployeeRepository {
  SupabaseClient get _db => SupabaseClientHolder.client;

  @override
  Future<PageResult<Employee>> find(EmployeeQuery q) async {
    dynamic query = _db.from('employees').select();
    if (!q.includeDeleted) query = query.isFilter('deleted_at', null);
    if (q.search.trim().isNotEmpty) {
      query = query.or('full_name.ilike.%${q.search.trim()}%,position.ilike.%${q.search.trim()}%,email.ilike.%${q.search.trim()}%');
    }
    final from = (q.page - 1) * q.size;
    final to = from + q.size - 1;
    query = query.order(q.sortField, ascending: q.sortAscending).range(from, to);
    final data = await query;
    final items = (data as List)
        .map((e) => Employee.fromJson(e as Map<String, dynamic>))
        .toList();

    dynamic countQ = _db.from('employees').select('id');
    if (!q.includeDeleted) countQ = countQ.isFilter('deleted_at', null);
    final countData = await countQ;
    final total = (countData as List).length;

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Employee?> findById(int id) async {
    final data = await _db.from('employees').select()
        .eq('id', id).isFilter('deleted_at', null).maybeSingle();
    if (data == null) return null;
    return Employee.fromJson(data);
  }

  @override
  Future<Employee> create(Employee e) async {
    final data = await _db.from('employees').insert({
      'full_name': e.fullName,
      'position': e.position,
      'email': e.email,
      'salary': e.salary,
      'hired_at': e.hiredAt.toIso8601String(),
    }).select().single();
    return Employee.fromJson(data);
  }

  @override
  Future<Employee> update(Employee e) async {
    final data = await _db.from('employees').update({
      'full_name': e.fullName,
      'position': e.position,
      'email': e.email,
      'salary': e.salary,
      'hired_at': e.hiredAt.toIso8601String(),
    }).eq('id', e.id).select().single();
    return Employee.fromJson(data);
  }

  @override
  Future<void> softDelete(int id) async {
    await _db.from('employees').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  @override
  Future<void> hardDelete(int id) async {
    await _db.from('employees').delete().eq('id', id);
  }

  @override
  Future<void> restore(int id) async {
    await _db.from('employees').update({'deleted_at': null}).eq('id', id);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return 0;
    await _db.from('employees').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).inFilter('id', ids);
    return ids.length;
  }
}