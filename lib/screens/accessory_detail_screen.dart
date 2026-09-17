import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/accessory_list_notifier.dart';
import '../models/accessory.dart';
import '../repositories/accessory_repository.dart';

class AccessoryDetailScreen extends StatefulWidget {
  final int id;
  const AccessoryDetailScreen({super.key, required this.id});

  @override
  State<AccessoryDetailScreen> createState() => _AccessoryDetailScreenState();
}

class _AccessoryDetailScreenState extends State<AccessoryDetailScreen> {
  Accessory? _accessory;
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
      final repo = context.read<AccessoryRepository>();
      final item = await repo.findById(widget.id);
      if (mounted) {
        setState(() {
          _accessory = item;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить аксессуар: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали аксессуара')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали аксессуара')),
        body: Center(
            child: Text('Ошибка: $_error',
                style: const TextStyle(color: Colors.red))),
      );
    }
    if (_accessory == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали аксессуара')),
        body: const Center(child: Text('Аксессуар не найден')),
      );
    }

    final a = _accessory!;

    return Scaffold(
      appBar: AppBar(
        title: Text(a.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/accessories/${a.id}/edit'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Название: ${a.name}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Категория: ${a.category}'),
            Text('Цена: ${a.price} \$'),
            if (a.description != null && a.description!.isNotEmpty)
              Text('Описание: ${a.description}'),
            if (a.isDeleted)
              Text('Удалён: ${a.deletedAt}',
                  style: const TextStyle(color: Colors.red)),
            const Spacer(),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/accessories/${a.id}/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(width: 8),
                if (a.isDeleted)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final n = context.read<AccessoryListNotifier>();
                      await n.restore(a.id);
                      if (!mounted) return;
                      context.go('/accessories');
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Восстановить'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      final n = context.read<AccessoryListNotifier>();
                      await n.softDelete(a.id);
                      if (!mounted) return;
                      context.go('/accessories');
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Логическое удаление'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final n = context.read<AccessoryListNotifier>();
                      await n.hardDelete(a.id);
                      if (!mounted) return;
                      context.go('/accessories');
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