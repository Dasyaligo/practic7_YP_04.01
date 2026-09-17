import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/phone_list_notifier.dart';
import '../models/phone.dart';
import '../models/brand.dart';
import '../repositories/seed_data.dart';
import '../repositories/phone_repository.dart';

class PhoneDetailScreen extends StatefulWidget {
  final int id;
  const PhoneDetailScreen({super.key, required this.id});

  @override
  State<PhoneDetailScreen> createState() => _PhoneDetailScreenState();
}

class _PhoneDetailScreenState extends State<PhoneDetailScreen> {
  Phone? _phone;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPhone();
  }

  Future<void> _loadPhone() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<PhoneRepository>();
      final phone = await repo.findById(widget.id);
      if (mounted) {
        setState(() {
          _phone = phone;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить телефон: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали телефона')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали телефона')),
        body: Center(child: Text('Ошибка: $_error', style: const TextStyle(color: Colors.red))),
      );
    }
    if (_phone == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали телефона')),
        body: const Center(child: Text('Телефон не найден')),
      );
    }

    final p = _phone!;
    final brand = seedBrands.firstWhere(
      (b) => b.id == p.brandId,
      orElse: () => Brand(id: 0, name: 'Неизвестно', country: ''),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(p.model),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/phones/${p.id}/edit'),
            tooltip: 'Редактировать',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Модель: ${p.model}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Бренд: ${brand.name} (${brand.country})'),
            Text('Цена: ${p.price} \$'),
            Text('Память: ${p.storage ?? '-'} ГБ'),
            Text('ОЗУ: ${p.ram ?? '-'} ГБ'),
            Text('Цвет: ${p.color ?? '-'}'),
            Text('Экран: ${p.screenSize ?? '-'} дюймов'),
            Text('В наличии: ${p.stock} шт.'),
            Text('Добавлен: ${p.createdAt.toLocal()}'),
            if (p.isDeleted) Text('Удалён: ${p.deletedAt}', style: const TextStyle(color: Colors.red)),
            const Spacer(),
            Row(
              children: [
                // 👇 КНОПКА РЕДАКТИРОВАНИЯ
                ElevatedButton.icon(
                  onPressed: () => context.go('/phones/${p.id}/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(width: 8),
                if (p.isDeleted)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final notifier = context.read<PhoneListNotifier>();
                      await notifier.restore(p.id);
                      if (!mounted) return;
                      context.go('/phones');
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Восстановить'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      final notifier = context.read<PhoneListNotifier>();
                      await notifier.softDelete(p.id);
                      if (!mounted) return;
                      context.go('/phones');
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Логическое удаление'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final notifier = context.read<PhoneListNotifier>();
                      await notifier.hardDelete(p.id);
                      if (!mounted) return;
                      context.go('/phones');
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