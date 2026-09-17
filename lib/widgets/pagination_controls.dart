import 'package:flutter/material.dart';

class PaginationControls extends StatelessWidget {
  final int page;
  final int totalPages;
  final int total;
  final int size;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onSizeChanged;

  const PaginationControls({
    super.key,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.size,
    required this.onPageChanged,
    required this.onSizeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Всего записей: $total'),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.first_page),
                onPressed: page > 1 ? () => onPageChanged(1) : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: page > 1 ? () => onPageChanged(page - 1) : null,
              ),
              Text('$page / $totalPages'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: page < totalPages ? () => onPageChanged(page + 1) : null,
              ),
              IconButton(
                icon: const Icon(Icons.last_page),
                onPressed: page < totalPages ? () => onPageChanged(totalPages) : null,
              ),
            ],
          ),
          Row(
            children: [
              const Text('Показывать:'),
              const SizedBox(width: 8),
              DropdownButton<int>(
                value: size,
                items: const [10, 25, 50].map((s) => DropdownMenuItem(value: s, child: Text('$s'))).toList(),
                onChanged: (value) => onSizeChanged(value!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}