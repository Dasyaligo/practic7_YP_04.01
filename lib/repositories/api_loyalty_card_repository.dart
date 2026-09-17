import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/loyalty_card.dart';
import '../models/page_result.dart';
import '../core/supabase_client.dart';
import 'loyalty_card_repository.dart';

class ApiLoyaltyCardRepository implements LoyaltyCardRepository {
  SupabaseClient get _db => SupabaseClientHolder.client;

  @override
  Future<PageResult<LoyaltyCard>> find() async {
    final data = await _db
        .from('loyalty_cards')
        .select()
        .isFilter('deleted_at', null);
    final items = (data as List)
        .map((e) => LoyaltyCard.fromJson(e as Map<String, dynamic>))
        .toList();
    return PageResult(
      items: items,
      page: 1,
      size: items.length,
      total: items.length,
    );
  }

  @override
  Future<LoyaltyCard?> findById(int id) async {
    final data = await _db
        .from('loyalty_cards')
        .select()
        .eq('id', id)
        .isFilter('deleted_at', null)
        .maybeSingle();
    if (data == null) return null;
    return LoyaltyCard.fromJson(data);
  }

  @override
  Future<LoyaltyCard> create(LoyaltyCard card) async {
    final data = await _db.from('loyalty_cards').insert({
      'customer_id': card.customerId,
      'card_number': card.cardNumber,
      'points': card.points,
    }).select().single();
    return LoyaltyCard.fromJson(data);
  }

  @override
  Future<LoyaltyCard> update(LoyaltyCard card) async {
    final data = await _db.from('loyalty_cards').update({
      'customer_id': card.customerId,
      'card_number': card.cardNumber,
      'points': card.points,
    }).eq('id', card.id).select().single();
    return LoyaltyCard.fromJson(data);
  }

  @override
  Future<void> softDelete(int id) async {
    await _db.from('loyalty_cards').update({
      'deleted_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  @override
  Future<void> hardDelete(int id) async {
    await _db.from('loyalty_cards').delete().eq('id', id);
  }

  @override
  Future<void> restore(int id) async {
    await _db.from('loyalty_cards').update({'deleted_at': null}).eq('id', id);
  }
}