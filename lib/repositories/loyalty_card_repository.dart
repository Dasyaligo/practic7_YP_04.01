import '../models/loyalty_card.dart';
import '../models/page_result.dart';

abstract interface class LoyaltyCardRepository {
  Future<PageResult<LoyaltyCard>> find();
  Future<LoyaltyCard?> findById(int id);
  Future<LoyaltyCard> create(LoyaltyCard card);
  Future<LoyaltyCard> update(LoyaltyCard card);
  Future<void> softDelete(int id);
  Future<void> hardDelete(int id);
  Future<void> restore(int id);
}