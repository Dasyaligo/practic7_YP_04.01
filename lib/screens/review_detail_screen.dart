import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/review_list_notifier.dart';
import '../models/review.dart';
import '../repositories/review_repository.dart';
import '../repositories/customer_repository.dart';
import '../repositories/phone_repository.dart';

class ReviewDetailScreen extends StatefulWidget {
  final int id;
  const ReviewDetailScreen({super.key, required this.id});

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  Review? _review;
  String _customerName = '—';
  String _phoneModel = '—';
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<ReviewRepository>();
      final review = await repo.findById(widget.id);
      if (review == null) {
        if (mounted) {
          setState(() {
            _review = null;
            _isLoading = false;
          });
        }
        return;
      }

      final customerRepo = context.read<CustomerRepository>();
      final phoneRepo = context.read<PhoneRepository>();
      final customer = await customerRepo.findById(review.customerId);
      final phone = await phoneRepo.findById(review.phoneId);

      if (mounted) {
        setState(() {
          _review = review;
          _customerName = customer?.fullName ?? 'Неизвестно';
          _phoneModel = phone?.model ?? 'Неизвестно';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить отзыв: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали отзыва')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали отзыва')),
        body: Center(
            child: Text('Ошибка: $_error',
                style: const TextStyle(color: Colors.red))),
      );
    }
    if (_review == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали отзыва')),
        body: const Center(child: Text('Отзыв не найден')),
      );
    }

    final r = _review!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Отзыв'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/reviews/${r.id}/edit'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Оценка: ${r.rating} / 5',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Покупатель: $_customerName'),
            Text('Телефон: $_phoneModel'),
            Text('Дата: ${r.date.toLocal()}'),
            const SizedBox(height: 8),
            Text('Комментарий: ${r.comment}'),
            if (r.isDeleted)
              Text('Удалён: ${r.deletedAt}',
                  style: const TextStyle(color: Colors.red)),
            const Spacer(),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/reviews/${r.id}/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(width: 8),
                if (r.isDeleted)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final n = context.read<ReviewListNotifier>();
                      await n.restore(r.id);
                      if (!mounted) return;
                      context.go('/reviews');
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Восстановить'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      final n = context.read<ReviewListNotifier>();
                      await n.softDelete(r.id);
                      if (!mounted) return;
                      context.go('/reviews');
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Логическое удаление'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final n = context.read<ReviewListNotifier>();
                      await n.hardDelete(r.id);
                      if (!mounted) return;
                      context.go('/reviews');
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Физическое удаление'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}