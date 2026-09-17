import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/employee_list_notifier.dart';
import '../state/load_status.dart';
import '../models/employee.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_field.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncQueryFromUrl();
    });
  }

  void _syncQueryFromUrl() {
    if (!mounted) return;
    final uri = Uri.base;
    final params = uri.queryParameters;
    final notifier = context.read<EmployeeListNotifier>();
    final currentQuery = notifier.query;

    final search = params['search'] ?? currentQuery.search;
    final sortField = params['sort']?.split(',')[0] ?? currentQuery.sortField;
    final sortAscending = params['sort']?.split(',').length == 2
        ? params['sort']!.split(',')[1] == 'asc'
        : currentQuery.sortAscending;
    final page = params.containsKey('page')
        ? int.tryParse(params['page']!) ?? 1
        : currentQuery.page;
    final size = params.containsKey('size')
        ? int.tryParse(params['size']!) ?? 10
        : currentQuery.size;
    final includeDeleted = params['includeDeleted'] == 'true';

    final newQuery = currentQuery.copyWith(
      search: search,
      sortField: sortField,
      sortAscending: sortAscending,
      page: page,
      size: size,
      includeDeleted: includeDeleted,
    );

    if (newQuery != currentQuery) {
      notifier.applyQuery(newQuery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = context.watch<EmployeeListNotifier>();
    final isWide = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Сотрудники 💗'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'На главную',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/employees/new'),
            tooltip: 'Добавить сотрудника',
          ),
          if (notifier.hasSelection)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Center(
                child: Text(
                  'Выбрано: ${notifier.selected.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          if (notifier.hasSelection)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDeleteSelected(context, notifier),
            ),
          IconButton(
            icon: Icon(
              notifier.query.includeDeleted
                  ? Icons.visibility
                  : Icons.visibility_off,
            ),
            onPressed: () {
              notifier.applyQuery(notifier.query.copyWith(
                includeDeleted: !notifier.query.includeDeleted,
                page: 1,
              ));
            },
            tooltip: 'Показать удалённые',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: SearchField(
                    initialValue: notifier.query.search,
                    onChanged: (value) {
                      notifier.applyQuery(
                        notifier.query.copyWith(search: value, page: 1),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildContent(context, notifier, isWide)),
          if (notifier.status == LoadStatus.success &&
              notifier.result.items.isNotEmpty)
            PaginationControls(
              page: notifier.query.page,
              totalPages: notifier.result.totalPages,
              total: notifier.result.total,
              size: notifier.query.size,
              onPageChanged: (page) {
                notifier.applyQuery(notifier.query.copyWith(page: page));
              },
              onSizeChanged: (size) {
                notifier.applyQuery(
                  notifier.query.copyWith(size: size, page: 1),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    EmployeeListNotifier notifier,
    bool isWide,
  ) {
    final status = notifier.status;
    if (status == LoadStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (status == LoadStatus.error) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Ошибка: ${notifier.error}',
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => notifier.applyQuery(notifier.query),
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить'),
              ),
            ],
          ),
        ),
      );
    }
    if (notifier.result.items.isEmpty) {
      return const Center(child: Text('Нет данных'));
    }

    if (isWide) {
      return EntityTable<Employee>(
        columns: [
          TableColumnSpec(
            label: 'ФИО',
            sortField: 'fullName',
            build: (e) => Text(e.fullName),
          ),
          TableColumnSpec(
            label: 'Должность',
            sortField: 'position',
            build: (e) => Text(e.position),
          ),
          TableColumnSpec(
            label: 'Email',
            sortField: 'email',
            build: (e) => Text(e.email),
          ),
          TableColumnSpec(
            label: 'Зарплата',
            sortField: 'salary',
            numeric: true,
            build: (e) => Text('${e.salary} ₽'),
          ),
        ],
        items: notifier.result.items,
        idOf: (e) => e.id,
        selected: notifier.selected,
        onToggleSelect: notifier.toggleSelection,
        sortField: notifier.query.sortField,
        sortAscending: notifier.query.sortAscending,
        onSort: (field) {
          notifier.applyQuery(notifier.query.copyWith(
            sortField: field,
            sortAscending: field == notifier.query.sortField
                ? !notifier.query.sortAscending
                : true,
          ));
        },
        actions: (e) => [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/employees/${e.id}/edit'),
          ),
          if (e.isDeleted)
            IconButton(
              icon: const Icon(Icons.restore),
              onPressed: () => notifier.restore(e.id),
            )
          else
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDelete(context, notifier, e.id),
            ),
        ],
      );
    } else {
      return ListView.builder(
        itemCount: notifier.result.items.length,
        itemBuilder: (context, index) {
          final e = notifier.result.items[index];
          return Card(
            child: ListTile(
              title: Text(e.fullName),
              subtitle: Text('${e.position} | ${e.email}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: notifier.selected.contains(e.id),
                    onChanged: (_) => notifier.toggleSelection(e.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => context.go('/employees/${e.id}/edit'),
                  ),
                  if (e.isDeleted)
                    IconButton(
                      icon: const Icon(Icons.restore),
                      onPressed: () => notifier.restore(e.id),
                    )
                  else
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _confirmDelete(context, notifier, e.id),
                    ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  void _confirmDelete(
    BuildContext context,
    EmployeeListNotifier notifier,
    int id,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить сотрудника?'),
        content: const Text('Вы уверены?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.softDelete(id);
            },
            child: const Text('Логическое удаление'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.hardDelete(id);
            },
            child: const Text('Физическое удаление',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSelected(
    BuildContext context,
    EmployeeListNotifier notifier,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить выбранные?'),
        content: Text('Выбрано записей: ${notifier.selected.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              notifier.deleteSelected();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}