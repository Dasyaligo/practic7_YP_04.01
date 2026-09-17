import 'dart:async';  // 👈 ДОБАВЬТЕ ЭТУ СТРОКУ
import 'package:flutter/material.dart';

class SearchField extends StatefulWidget {
  final String initialValue;
  final ValueChanged<String> onChanged;
  final Duration debounce;

  const SearchField({
    super.key,
    required this.onChanged,
    this.initialValue = '',
    this.debounce = const Duration(milliseconds: 300),
  });

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.initialValue;
    _controller.addListener(_onChanged);
  }

  void _onChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounce, () {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: const InputDecoration(
        hintText: 'Поиск...',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }
}