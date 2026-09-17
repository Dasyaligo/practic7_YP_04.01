import 'package:flutter/material.dart';

class CardList<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(T item) cardBuilder;

  const CardList({super.key, required this.items, required this.cardBuilder});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => cardBuilder(items[index]),
    );
  }
}