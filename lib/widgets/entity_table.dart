import 'package:flutter/material.dart';

class TableColumnSpec<T> {
  final String label;
  final String? sortField;
  final bool numeric;
  final Widget Function(T item) build;

  const TableColumnSpec({
    required this.label,
    required this.build,
    this.sortField,
    this.numeric = false,
  });
}

class EntityTable<T> extends StatelessWidget {
  final List<TableColumnSpec<T>> columns;
  final List<T> items;
  final int Function(T item) idOf;
  final Set<int> selected;
  final ValueChanged<int>? onToggleSelect;
  final String? sortField;
  final bool sortAscending;
  final void Function(String field)? onSort;
  final List<Widget> Function(T item)? actions;

  const EntityTable({
    super.key,
    required this.columns,
    required this.items,
    required this.idOf,
    this.selected = const {},
    this.onToggleSelect,
    this.sortField,
    this.sortAscending = true,
    this.onSort,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    
    int? sortIndex;
    if (sortField != null) {
      final idx = columns.indexWhere((c) => c.sortField == sortField);
      if (idx >= 0) sortIndex = idx;
    }

    
    if (items.isEmpty) {
      return const Center(child: Text('Нет данных'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortColumnIndex: sortIndex,        
        sortAscending: sortAscending,
        columns: [
          if (onToggleSelect != null)
            DataColumn(
              label: Checkbox(
                value: items.isNotEmpty && items.every((item) => selected.contains(idOf(item))),
                onChanged: (_) {
                  if (items.isNotEmpty) {
                    final allSelected = items.every((item) => selected.contains(idOf(item)));
                    for (final item in items) {
                      if (allSelected) {
                        selected.remove(idOf(item));
                      } else {
                        selected.add(idOf(item));
                      }
                    }
                    
                  }
                },
              ),
            ),
          ...columns.map((col) => DataColumn(
                label: GestureDetector(
                  onTap: () {
                    if (col.sortField != null && onSort != null) {
                      onSort!(col.sortField!);
                    }
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(col.label),
                      if (sortField == col.sortField)
                        Icon(
                          sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 16,
                        ),
                    ],
                  ),
                ),
              )),
          if (actions != null) DataColumn(label: const Text('Действия')),
        ],
        rows: items.map((item) {
          final id = idOf(item);
          return DataRow(
            selected: selected.contains(id),
            onSelectChanged: onToggleSelect != null
                ? (selected) => onToggleSelect!(id)
                : null,
            cells: [
              if (onToggleSelect != null)
                DataCell(Checkbox(
                  value: selected.contains(id),
                  onChanged: (_) => onToggleSelect!(id),
                )),
              ...columns.map((col) => DataCell(col.build(item))),
              if (actions != null)
                DataCell(Row(
                  mainAxisSize: MainAxisSize.min,
                  children: actions!(item),
                )),
            ],
          );
        }).toList(),
      ),
    );
  }
}