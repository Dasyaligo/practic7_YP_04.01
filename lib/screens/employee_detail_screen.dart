import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/employee_list_notifier.dart';
import '../models/employee.dart';
import '../repositories/employee_repository.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int id;
  const EmployeeDetailScreen({super.key, required this.id});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  Employee? _employee;
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
      final repo = context.read<EmployeeRepository>();
      final item = await repo.findById(widget.id);
      if (mounted) {
        setState(() {
          _employee = item;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Не удалось загрузить сотрудника: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали сотрудника')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали сотрудника')),
        body: Center(
            child: Text('Ошибка: $_error',
                style: const TextStyle(color: Colors.red))),
      );
    }
    if (_employee == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Детали сотрудника')),
        body: const Center(child: Text('Сотрудник не найден')),
      );
    }

    final e = _employee!;

    return Scaffold(
      appBar: AppBar(
        title: Text(e.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/employees/${e.id}/edit'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ФИО: ${e.fullName}',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Должность: ${e.position}'),
            Text('Email: ${e.email}'),
            Text('Зарплата: ${e.salary} ₽'),
            Text('Нанят: ${e.hiredAt.toLocal()}'),
            if (e.isDeleted)
              Text('Удалён: ${e.deletedAt}',
                  style: const TextStyle(color: Colors.red)),
            const Spacer(),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/employees/${e.id}/edit'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Редактировать'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
                const SizedBox(width: 8),
                if (e.isDeleted)
                  ElevatedButton.icon(
                    onPressed: () async {
                      final n = context.read<EmployeeListNotifier>();
                      await n.restore(e.id);
                      if (!mounted) return;
                      context.go('/employees');
                    },
                    icon: const Icon(Icons.restore),
                    label: const Text('Восстановить'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  )
                else ...[
                  ElevatedButton.icon(
                    onPressed: () async {
                      final n = context.read<EmployeeListNotifier>();
                      await n.softDelete(e.id);
                      if (!mounted) return;
                      context.go('/employees');
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Логическое удаление'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final n = context.read<EmployeeListNotifier>();
                      await n.hardDelete(e.id);
                      if (!mounted) return;
                      context.go('/employees');
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