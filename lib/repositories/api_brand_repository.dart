import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/brand.dart';
import '../models/page_result.dart';
import '../core/supabase_client.dart';
import 'brand_repository.dart';

class ApiBrandRepository implements BrandRepository {
  SupabaseClient get _db => SupabaseClientHolder.client;

  @override
  Future<PageResult<Brand>> find(BrandQuery q) async {
    dynamic query = _db.from('brands').select();
    if (!q.includeDeleted) query = query.isFilter('deleted_at', null);
    if (q.search.trim().isNotEmpty) {
      query = query.ilike('name', '%${q.search.trim()}%');
    }
    final from = (q.page - 1) * q.size;
    final to = from + q.size - 1;
    query = query.order(q.sortField, ascending: q.sortAscending).range(from, to);
    final data = await query;
    final items = (data as List)
        .map((e) => Brand.fromJson(e as Map<String, dynamic>))
        .toList();

    dynamic countQ = _db.from('brands').select('id');
    if (!q.includeDeleted) countQ = countQ.isFilter('deleted_at', null);
    if (q.search.trim().isNotEmpty) {
      countQ = countQ.ilike('name', '%${q.search.trim()}%');
    }
    final countData = await countQ;
    final total = (countData as List).length;

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Brand?> findById(int id) async {
    final data = await _db
        .from('brands')
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    if (data == null) return null;
    return Brand.fromJson(data);
  }

  @override
  Future<Brand> create(Brand brand) async {
    final data = await _db.from('brands').insert({
      'name': brand.name,
      'country': brand.country,
      'founded_year': brand.foundedYear,
    }).select().single();
    return Brand.fromJson(data);
  }

  @override
  Future<Brand> update(Brand brand) async {
    final data = await _db.from('brands').update({
      'name': brand.name,
      'country': brand.country,
      'founded_year': brand.foundedYear,
    }).eq('id', brand.id).select().single();
    return Brand.fromJson(data);
  }

  @override
  Future<void> softDelete(int id) async {
    await _db.from('brands').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  @override
  Future<void> hardDelete(int id) async {
    await _db.from('brands').delete().eq('id', id);
  }

  @override
  Future<void> restore(int id) async {
    await _db.from('brands').update({'deleted_at': null}).eq('id', id);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return 0;
    await _db.from('brands').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).inFilter('id', ids);
    return ids.length;
  }
}