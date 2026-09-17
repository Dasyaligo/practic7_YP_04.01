import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../state/phone_list_notifier.dart';
import '../state/auth_notifier.dart';
import '../state/load_status.dart';
import '../models/phone.dart';
import '../models/app_user.dart';
import '../widgets/entity_table.dart';
import '../widgets/pagination_controls.dart';
import '../widgets/search_field.dart';
import '../widgets/filter_panel.dart';

class PhoneListScreen extends StatefulWidget {
  const PhoneListScreen({super.key});

  @override
  State<PhoneListScreen> createState() => _PhoneListScreenState();
}

class _PhoneListScreenState extends State<PhoneListScreen> {
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
    final notifier = context.read<PhoneListNotifier>();
    final currentQuery = notifier.query;

    final search = params['search'] ?? currentQuery.search;
    final brandId = params.containsKey('brandId')
        ? int.tryParse(params['brandId']!)
        : currentQuery.brandId;
    final priceFrom = params.containsKey('priceFrom')
        ? double.tryParse(params['priceFrom']!)
        : currentQuery.priceFrom;
    final priceTo = params.containsKey('priceTo')
        ? double.tryParse(params['priceTo']!)
        : currentQuery.priceTo;
    final storage = params.containsKey('storage')
        ? int.tryParse(params['storage']!)
        : currentQuery.storage;
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
      brandId: brandId,
      priceFrom: priceFrom,
      priceTo: priceTo,
      storage: storage,
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
    final notifier = context.watch<PhoneListNotifier>();
    final auth = context.watch<AuthNotifier>();
    final isWide = MediaQuery.of(context).size.width > 600;

    // 🔐 Права
    final canEdit = auth.has(Role.manager);
    final canHardDelete = auth.has(Role.admin);

    debugPrint('📱 PhoneListScreen: role=${auth.user?.role.name}, canEdit=$canEdit, canHardDelete=$canHardDelete');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Телефоны 💗'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
          tooltip: 'На главную',
        ),
        actions: [
          // 👇 Кнопка «➕» — только для manager и admin
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                debugPrint('🔘 Нажата кнопка +, переход на /phones/new');
                context.go('/phones/new');
              },
              tooltip: 'Добавить телефон',
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
          if (notifier.hasSelection && canEdit)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _confirmDeleteSelected(context, notifier),
            ),
          IconButton(
            icon: const Icon(Icons.branding_watermark),
            onPressed: () => context.go('/brands'),
            tooltip: 'Бренды',
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
          FilterPanel(
            onApply: (brandId, priceFrom, priceTo, storage) {
              notifier.applyQuery(notifier.query.copyWith(
                brandId: brandId,
                priceFrom: priceFrom,
                priceTo: priceTo,
                storage: storage,
                page: 1,
              ));
            },
          ),
          Expanded(
            child: _buildContent(context, notifier, isWide, canEdit, canHardDelete),
          ),
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
    PhoneListNotifier notifier,
    bool isWide,
    bool canEdit,
    bool canHardDelete,
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
              Text(
                'Ошибка: ${notifier.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
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
      return EntityTable<Phone>(
        columns: [
          TableColumnSpec(
            label: 'Модель',
            sortField: 'model',
            build: (p) => Text(p.model),
          ),
          TableColumnSpec(
            label: 'Цена',
            sortField: 'price',
            numeric: true,
            build: (p) => Text('${p.price} \$'),
          ),
          TableColumnSpec(
            label: 'Память',
            sortField: 'storage',
            numeric: true,
            build: (p) => Text('${p.storage ?? '-'} ГБ'),
          ),
          TableColumnSpec(
            label: 'В наличии',
            build: (p) => Text('${p.stock} шт.'),
          ),
        ],
        items: notifier.result.items,
        idOf: (p) => p.id,
        selected: notifier.selected,
        onToggleSelect: canEdit ? notifier.toggleSelection : null,
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
        actions: (p) => [
          // Редактирование — только manager+
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => context.go('/phones/${p.id}/edit'),
              tooltip: 'Редактировать',
            ),
          if (canEdit) ...[
            if (p.isDeleted)
              // Восстановление — только admin
              if (canHardDelete)
                IconButton(
                  icon: const Icon(Icons.restore),
                  onPressed: () => notifier.restore(p.id),
                  tooltip: 'Восстановить',
                )
              else
                const SizedBox.shrink()
            else
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(
                    context, notifier, p.id, canHardDelete),
                tooltip: 'Удалить',
              ),
          ],
        ],
      );
    } else {
      return ListView.builder(
        itemCount: notifier.result.items.length,
        itemBuilder: (context, index) {
          final p = notifier.result.items[index];
          return Card(
            child: ListTile(
              title: Text(p.model),
              subtitle: Text(
                '${p.price} \$ | ${p.storage ?? '-'} ГБ | В наличии: ${p.stock}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (canEdit)
                    Checkbox(
                      value: notifier.selected.contains(p.id),
                      onChanged: (_) => notifier.toggleSelection(p.id),
                    ),
                  if (canEdit)
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => context.go('/phones/${p.id}/edit'),
                    ),
                  if (canEdit) ...[
                    if (p.isDeleted)
                      if (canHardDelete)
                        IconButton(
                          icon: const Icon(Icons.restore),
                          onPressed: () => notifier.restore(p.id),
                        )
                      else
                        const SizedBox.shrink()
                    else
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _confirmDelete(
                            context, notifier, p.id, canHardDelete),
                      ),
                  ],
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
    PhoneListNotifier notifier,
    int id,
    bool canHardDelete,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить телефон?'),
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
          if (canHardDelete)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                notifier.hardDelete(id);
              },
              child: const Text(
                'Физическое удаление',
                style: TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDeleteSelected(
    BuildContext context,
    PhoneListNotifier notifier,
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