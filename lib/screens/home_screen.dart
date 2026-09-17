import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/auth_notifier.dart';
import '../models/app_user.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isManager = auth.has(Role.manager);
    final isAdmin = auth.has(Role.admin);

    return Scaffold(
      appBar: AppBar(
        title: const Text('OnlyPhones 💗'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () async {
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (c) => AlertDialog(
                  title: const Text('Выйти из системы?'),
                  content: const Text('Вы уверены, что хотите выйти?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(c).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(c).pop(true),
                      child: const Text('Выйти'),
                    ),
                  ],
                ),
              );
              if (confirmed == true && context.mounted) {
                await context.read<AuthNotifier>().logout();
                if (context.mounted) context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.pink.shade50, Colors.white],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.pink.shade100,
                              child: const Icon(
                                Icons.person,
                                size: 32,
                                color: Colors.pink,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Добро пожаловать!',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                  Text(
                                    user.fullName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Роль: ${_roleName(user.role)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.pink),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    _MenuButton(
                      icon: Icons.phone_android,
                      label: 'Каталог телефонов',
                      onPressed: () => context.go('/phones'),
                    ),
                    const SizedBox(height: 12),
                    _MenuButton(
                      icon: Icons.branding_watermark,
                      label: 'Бренды',
                      onPressed: () => context.go('/brands'),
                    ),
                    const SizedBox(height: 12),
                    _MenuButton(
                      icon: Icons.shopping_bag,
                      label: 'Мои заказы',
                      onPressed: () => context.go('/orders'),
                    ),
                    const SizedBox(height: 12),
                    _MenuButton(
                      icon: Icons.headphones,
                      label: 'Аксессуары',
                      onPressed: () => context.go('/accessories'),
                    ),
                    const SizedBox(height: 12),
                    _MenuButton(
                      icon: Icons.rate_review,
                      label: 'Отзывы',
                      onPressed: () => context.go('/reviews'),
                    ),

                    if (isManager) ...[
                      const SizedBox(height: 12),
                      _MenuButton(
                        icon: Icons.people,
                        label: 'Покупатели',
                        onPressed: () => context.go('/customers'),
                      ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        icon: Icons.badge,
                        label: 'Сотрудники',
                        onPressed: () => context.go('/employees'),
                      ),
                    ],

                    if (isAdmin) ...[
                      const SizedBox(height: 12),
                      _MenuButton(
                        icon: Icons.admin_panel_settings,
                        label: 'Администрирование',
                        color: Colors.deepPurple,
                        onPressed: () => context.go('/admin'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _roleName(Role role) {
    return switch (role) {
      Role.customer => 'Покупатель',
      Role.manager => 'Менеджер',
      Role.admin => 'Администратор',
    };
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.pink,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}