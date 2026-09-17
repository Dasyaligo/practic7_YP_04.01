import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/brand_list_notifier.dart';
import '../models/brand.dart';
import '../repositories/brand_repository.dart';

class BrandDetailScreen extends StatefulWidget {
  final int id;
  const BrandDetailScreen({super.key, required this.id});

  @override
  State<BrandDetailScreen> createState() => _BrandDetailScreenState();
}

class _BrandDetailScreenState extends State<BrandDetailScreen> {
  Brand? _brand;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBrand();
  }

  Future<void> _loadBrand() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = context.read<BrandRepository>();
      final brand = await repo.findById(widget.id);
      if (mounted) {
        setState(() {
          _brand = brand;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить бренд: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали бренда')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали бренда')),
        body: Center(child: Text('Ошибка: $_error', style: const TextStyle(color: Colors.red))),
      );
    }
    if (_brand == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали бренда')),
        body: const Center(child: Text('Бренд не найден')),
      );
    }

    final b = _brand!;

    return Scaffold(
      appBar: AppBar(
        title: Text(b.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/brands/${b.id}/edit'),
            tooltip: 'Редактировать',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Название: ${b.name}', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Страна: ${b.country}'),
            Text('Год основания: ${b.foundedYear ?? '-'}'),
            if (b.isDeleted) Text('Удалён: ${b.deletedAt}', style: const TextStyle(color: Colors.red)),
            const Spacer(),
            Row(
              children: [
                // 👇 КНОПКА РЕДАКТИРОВАНИЯ
                ElevatedButton.icon(
                  onPressed: () => context.go('/brands/${b.id}/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(width: 8),
                if (b.isDeleted)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final notifier = context.read<BrandListNotifier>();
                      await notifier.restore(b.id);
                      if (!mounted) return;
                      context.go('/brands');
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Восстановить'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      final notifier = context.read<BrandListNotifier>();
                      await notifier.softDelete(b.id);
                      if (!mounted) return;
                      context.go('/brands');
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Логическое удаление'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final notifier = context.read<BrandListNotifier>();
                      await notifier.hardDelete(b.id);
                      if (!mounted) return;
                      context.go('/brands');
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