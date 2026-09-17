import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/accessory.dart';
import '../models/page_result.dart';
import '../core/supabase_client.dart';
import 'accessory_repository.dart';

class ApiAccessoryRepository implements AccessoryRepository {
  SupabaseClient get _db => SupabaseClientHolder.client;

  @override
  Future<PageResult<Accessory>> find(AccessoryQuery q) async {
    dynamic query = _db.from('accessories').select();
    if (!q.includeDeleted) query = query.isFilter('deleted_at', null);
    if (q.search.trim().isNotEmpty) {
      query = query.or(
          'name.ilike.%${q.search.trim()}%,category.ilike.%${q.search.trim()}%');
    }
    final from = (q.page - 1) * q.size;
    final to = from + q.size - 1;
    query = query.order(q.sortField, ascending: q.sortAscending).range(from, to);
    final data = await query;
    final items = (data as List)
        .map((e) => Accessory.fromJson(e as Map<String, dynamic>))
        .toList();

    dynamic countQ = _db.from('accessories').select('id');
    if (!q.includeDeleted) countQ = countQ.isFilter('deleted_at', null);
    final countData = await countQ;
    final total = (countData as List).length;

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Accessory?> findById(int id) async {
    final data = await _db
        .from('accessories')
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    if (data == null) return null;
    return Accessory.fromJson(data);
  }

  @override
  Future<Accessory> create(Accessory a) async {
    final data = await _db.from('accessories').insert({
      'name': a.name,
      'category': a.category,
      'price': a.price,
      'description': a.description,
    }).select().single();
    return Accessory.fromJson(data);
  }

  @override
  Future<Accessory> update(Accessory a) async {
    final data = await _db.from('accessories').update({
      'name': a.name,
      'category': a.category,
      'price': a.price,
      'description': a.description,
    }).eq('id', a.id).select().single();
    return Accessory.fromJson(data);
  }

  @override
  Future<void> softDelete(int id) async {
    await _db.from('accessories').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  @override
  Future<void> hardDelete(int id) async {
    await _db.from('accessories').delete().eq('id', id);
  }

  @override
  Future<void> restore(int id) async {
    await _db.from('accessories').update({'deleted_at': null}).eq('id', id);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return 0;
    await _db.from('accessories').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).inFilter('id', ids);
    return ids.length;
  }
}