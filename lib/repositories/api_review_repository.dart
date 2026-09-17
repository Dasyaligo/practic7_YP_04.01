import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/review.dart';
import '../models/page_result.dart';
import '../core/supabase_client.dart';
import 'review_repository.dart';

class ApiReviewRepository implements ReviewRepository {
  SupabaseClient get _db => SupabaseClientHolder.client;

  @override
  Future<PageResult<Review>> find(ReviewQuery q) async {
    dynamic query = _db.from('reviews').select();
    if (!q.includeDeleted) query = query.isFilter('deleted_at', null);
    if (q.search.trim().isNotEmpty) {
      query = query.ilike('comment', '%${q.search.trim()}%');
    }
    final from = (q.page - 1) * q.size;
    final to = from + q.size - 1;
    query = query.order(q.sortField, ascending: q.sortAscending).range(from, to);
    final data = await query;
    final items = (data as List)
        .map((e) => Review.fromJson(e as Map<String, dynamic>))
        .toList();

    dynamic countQ = _db.from('reviews').select('id');
    if (!q.includeDeleted) countQ = countQ.isFilter('deleted_at', null);
    final countData = await countQ;
    final total = (countData as List).length;

    return PageResult(items: items, page: q.page, size: q.size, total: total);
  }

  @override
  Future<Review?> findById(int id) async {
    final data = await _db.from('reviews').select()
        .eq('id', id).isFilter('deleted_at', null).maybeSingle();
    if (data == null) return null;
    return Review.fromJson(data);
  }

  @override
  Future<Review> create(Review r) async {
    final data = await _db.from('reviews').insert({
      'customer_id': r.customerId,
      'phone_id': r.phoneId,
      'rating': r.rating,
      'comment': r.comment,
    }).select().single();
    return Review.fromJson(data);
  }

  @override
  Future<Review> update(Review r) async {
    final data = await _db.from('reviews').update({
      'customer_id': r.customerId,
      'phone_id': r.phoneId,
      'rating': r.rating,
      'comment': r.comment,
    }).eq('id', r.id).select().single();
    return Review.fromJson(data);
  }

  @override
  Future<void> softDelete(int id) async {
    await _db.from('reviews').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  @override
  Future<void> hardDelete(int id) async {
    await _db.from('reviews').delete().eq('id', id);
  }

  @override
  Future<void> restore(int id) async {
    await _db.from('reviews').update({'deleted_at': null}).eq('id', id);
  }

  @override
  Future<int> deleteMany(List<int> ids) async {
    if (ids.isEmpty) return 0;
    await _db.from('reviews').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).inFilter('id', ids);
    return ids.length;
  }
}