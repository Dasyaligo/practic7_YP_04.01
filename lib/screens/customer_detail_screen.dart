import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/customer_list_notifier.dart';
import '../models/customer.dart';
import '../repositories/customer_repository.dart';

class CustomerDetailScreen extends StatefulWidget {
  final int id;
  const CustomerDetailScreen({super.key, required this.id});

  @override
  State<CustomerDetailScreen> createState() => _CustomerDetailScreenState();
}

class _CustomerDetailScreenState extends State<CustomerDetailScreen> {
  Customer? _customer;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<CustomerRepository>();
      final customer = await repo.findById(widget.id);
      if (mounted) {
        setState(() {
          _customer = customer;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить покупателя: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали покупателя')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали покупателя')),
        body: Center(child: Text('Ошибка: $_error', style: const TextStyle(color: Colors.red))),
      );
    }
    if (_customer == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали покупателя')),
        body: const Center(child: Text('Покупатель не найден')),
      );
    }

    final c = _customer!;

    return Scaffold(
      appBar: AppBar(
        title: Text(c.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/customers/${c.id}/edit'),
            tooltip: 'Редактировать',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ФИО: ${c.fullName}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Email: ${c.email}'),
            Text('Телефон: ${c.phone}'),
            Text('Баллы: ${c.loyaltyPoints}'),
            if (c.loyaltyCardId != null) Text('ID карты: ${c.loyaltyCardId}'),
            Text('Добавлен: ${c.createdAt.toLocal()}'),
            if (c.isDeleted) Text('Удалён: ${c.deletedAt}', style: const TextStyle(color: Colors.red)),
            const Spacer(),
            Row(
              children: [
                // 👇 КНОПКА РЕДАКТИРОВАНИЯ
                ElevatedButton.icon(
                  onPressed: () => context.go('/customers/${c.id}/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(width: 8),
                if (c.isDeleted)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final notifier = context.read<CustomerListNotifier>();
                      await notifier.restore(c.id);
                      if (!mounted) return;
                      context.go('/customers');
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Восстановить'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      final notifier = context.read<CustomerListNotifier>();
                      await notifier.softDelete(c.id);
                      if (!mounted) return;
                      context.go('/customers');
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Логическое удаление'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final notifier = context.read<CustomerListNotifier>();
                      await notifier.hardDelete(c.id);
                      if (!mounted) return;
                      context.go('/customers');
                    },
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Физическое удаление'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
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