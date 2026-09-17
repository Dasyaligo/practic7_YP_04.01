import 'package:flutter/material.dart';
import '../repositories/seed_data.dart';

class FilterPanel extends StatefulWidget {
  final Function(int? brandId, double? priceFrom, double? priceTo, int? storage) onApply;

  const FilterPanel({super.key, required this.onApply});

  @override
  State<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends State<FilterPanel> {
  int? _brandId;
  final TextEditingController _priceFromController = TextEditingController();
  final TextEditingController _priceToController = TextEditingController();
  int? _storage;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.start,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Бренд'),
                items: seedBrands.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name))).toList(),
                onChanged: (value) => setState(() => _brandId = value),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 80, maxWidth: 110),
              child: TextField(
                controller: _priceFromController,
                decoration: const InputDecoration(labelText: 'Цена от'),
                keyboardType: TextInputType.number,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 80, maxWidth: 110),
              child: TextField(
                controller: _priceToController,
                decoration: const InputDecoration(labelText: 'Цена до'),
                keyboardType: TextInputType.number,
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 100, maxWidth: 150),
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(labelText: 'Память (ГБ)'),
                items: [null, 64, 128, 256, 512].map((s) => DropdownMenuItem(value: s, child: Text(s?.toString() ?? 'Все'))).toList(),
                onChanged: (value) => setState(() => _storage = value),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final priceFrom = double.tryParse(_priceFromController.text.trim());
                final priceTo = double.tryParse(_priceToController.text.trim());
                widget.onApply(_brandId, priceFrom, priceTo, _storage);
              },
              child: const Text('Применить'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _brandId = null;
                  _priceFromController.clear();
                  _priceToController.clear();
                  _storage = null;
                });
                widget.onApply(null, null, null, null);
              },
              child: const Text('Сбросить'),
            ),
          ],
        ),
      ),
    );
  }
}