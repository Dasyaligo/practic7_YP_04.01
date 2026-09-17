import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/phone.dart';
import '../models/phone_query.dart';
import '../models/page_result.dart';
import '../core/supabase_client.dart';
import 'phone_repository.dart';

class ApiPhoneRepository implements PhoneRepository {
  SupabaseClient get _db => SupabaseClientHolder.client;

  @override
  Future<PageResult<Phone>> find(PhoneQuery q) async {
    dynamic query = _db.from('phones').select();
    if (!q.includeDeleted) query = query.isFilter('deleted_at', null);
    if (q.search.trim().isNotEmpty) {
      query = query.ilike('model', '%${q.search.trim()}%');
    }
    if (q.brandId != null) query = query.eq('brand_id', q.brandId!);
    if (q.priceFrom != null) query = query.gte('price', q.priceFrom!);
    if (q.priceTo != null) query = query.lte('price', q.priceTo!);
    if (q.storage != null) query = query.eq('storage', q.storage!);

    final from = (q.page - 1) * q.size;
    final to = from + q.size - 1;
    query = query.order(q.sortField, ascending: q.sortAscending).range(from, to);
    final data = await query;
    final items = (data as List)
        .map((e) => Phone.fromJson(e as Map<String, dynamic>))
        .toList();

    dynamic countQ = _db.from('phones').select('id');
    if (!q.includeDeleted) countQ = countQ.isFilter('deleted_at', null);
    final countData = await countQ;
    final total = (countData as List).length;

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Phone?> findById(int id) async {
    final data = await _db.from('phones').select()
        .eq('id', id).isFilter('deleted_at', null).maybeSingle();
    if (data == null) return null;
    return Phone.fromJson(data);
  }

  @override
  Future<Phone> create(Phone p) async {
    final data = await _db.from('phones').insert({
      'model': p.model,
      'brand_id': p.brandId,
      'price': p.price,
      'storage': p.storage,
      'ram': p.ram,
      'color': p.color,
      'screen_size': p.screenSize,
      'stock': p.stock,
    }).select().single();
    return Phone.fromJson(data);
  }

  @override
  Future<Phone> update(Phone p) async {
    final data = await _db.from('phones').update({
      'model': p.model,
      'brand_id': p.brandId,
      'price': p.price,
      'storage': p.storage,
      'ram': p.ram,
      'color': p.color,
      'screen_size': p.screenSize,
      'stock': p.stock,
    }).eq('id', p.id).select().single();
    return Phone.fromJson(data);
  }

  @override
  Future<void> softDelete(int id) async {
    await _db.from('phones').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  @override
  Future<void> hardDelete(int id) async {
    await _db.from('phones').delete().eq('id', id);
  }

  @override
  Future<void> restore(int id) async {
    await _db.from('phones').update({'deleted_at': null}).eq('id', id);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return 0;
    await _db.from('phones').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).inFilter('id', ids);
    return ids.length;
  }
}