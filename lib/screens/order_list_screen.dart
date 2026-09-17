import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Заказы 💗'),
        actions: [
          IconButton(
            icon: const Icon(Icons.phone_android),
            onPressed: () => context.go('/phones'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => context.go('/customers'),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Список заказов\n(будет реализован в следующих практиках)',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}