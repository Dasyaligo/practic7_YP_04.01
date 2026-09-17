import '../models/loyalty_card.dart';
import '../models/page_result.dart';
import 'loyalty_card_repository.dart';
import 'seed_data.dart';

class InMemoryLoyaltyCardRepository implements LoyaltyCardRepository {
  final List<LoyaltyCard> _cards = [];
  int _nextId = 1;

  InMemoryLoyaltyCardRepository() {
    _cards.addAll(seedLoyaltyCards);
    _nextId = _cards.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;
  }

  @override
  Future<PageResult<LoyaltyCard>> find() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final items = _cards.where((c) => !c.isDeleted).toList();
    return PageResult(
      items: items,
      page: 1,
      size: items.length,
      total: items.length,
    );
  }

  @override
  Future<LoyaltyCard?> findById(int id) async {
    try {
      return _cards.firstWhere((c) => c.id == id && !c.isDeleted);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<LoyaltyCard> create(LoyaltyCard card) async {
    final newCard = LoyaltyCard(
      id: _nextId++,
      customerId: card.customerId,
      cardNumber: card.cardNumber,
      points: card.points,
      issuedAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(days: 365)),
    );
    _cards.add(newCard);
    return newCard;
  }

  @override
  Future<LoyaltyCard> update(LoyaltyCard card) async {
    final index = _cards.indexWhere((c) => c.id == card.id);
    if (index == -1) throw StateError('Карта не найдена');
    _cards[index] = card;
    return card;
  }

  @override
  Future<void> softDelete(int id) async {
    final index = _cards.indexWhere((c) => c.id == id);
    if (index == -1) throw StateError('Карта не найдена');
    _cards[index] = _cards[index].copyWith(deletedAt: DateTime.now());
  }

  @override
  Future<void> hardDelete(int id) async {
    _cards.removeWhere((c) => c.id == id);
  }

  @override
  Future<void> restore(int id) async {
    final index = _cards.indexWhere((c) => c.id == id);
    if (index == -1) throw StateError('Карта не найдена');
    _cards[index] = _cards[index].copyWith(clearDeletedAt: true);
  }
}