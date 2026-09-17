import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/supabase_client.dart';
import '../models/page_result.dart';

class SupabaseRepository<T> {
  final String table;
  final T Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(T) toJson;
  final String searchField;
  final String defaultSortField;

  SupabaseRepository({
    required this.table,
    required this.fromJson,
    required this.toJson,
    required this.searchField,
    required this.defaultSortField,
  });

  SupabaseClient get _db => SupabaseClientHolder.client;

  Future<PageResult<T>> find({
    String search = '',
    String sortField = '',
    bool sortAscending = true,
    int page = 1,
    int size = 10,
    bool includeDeleted = false,
  }) async {
    dynamic q = _db.from(table).select();

    if (!includeDeleted) {
      q = q.isFilter('deleted_at', null);
    }
    if (search.trim().isNotEmpty) {
      q = q.ilike(searchField, '%${search.trim()}%');
    }

    final from = (page - 1) * size;
    final to = from + size - 1;

    q = q.order(
      sortField.isEmpty ? defaultSortField : sortField,
      ascending: sortAscending,
    ).range(from, to);

    final data = await q;
    final items = (data as List)
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();

    // Общее количество — отдельным запросом
    dynamic countQ = _db.from(table).select('id');
    if (!includeDeleted) countQ = countQ.isFilter('deleted_at', null);
    if (search.trim().isNotEmpty) {
      countQ = countQ.ilike(searchField, '%${search.trim()}%');
    }
    final countData = await countQ;
    final total = (countData as List).length;

    return PageResult(
      items: items,
      page: page,
      size: size,
      total: total,
    );
  }

  Future<T?> findById(int id) async {
    final data = await _db
        .from(table)
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    if (data == null) return null;
    return fromJson(data);
  }

  Future<T> create(T item) async {
    final data = await _db
        .from(table)
        .insert(toJson(item))
        .select()
        .single();
    return fromJson(data);
  }

  Future<T> update(int id, T item) async {
    final json = toJson(item)..remove('id');
    final data = await _db
        .from(table)
        .update(json)
        .eq('id', id)
        .select()
        .single();
    return fromJson(data);
  }

  Future<void> softDelete(int id) async {
    await _db
        .from(table)
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  Future<void> hardDelete(int id) async {
    await _db.from(table).delete().eq('id', id);
  }

  Future<void> restore(int id) async {
    await _db.from(table).update({'deleted_at': null}).eq('id', id);
  }

  Future<int> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return 0;
    await _db
        .from(table)
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .inFilter('id', ids);
    return ids.length;
  }
}