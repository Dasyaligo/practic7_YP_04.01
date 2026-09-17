import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/supabase_client.dart';
import 'state/auth_notifier.dart';
import 'state/phone_list_notifier.dart';
import 'state/brand_list_notifier.dart';
import 'state/customer_list_notifier.dart';
import 'state/accessory_list_notifier.dart';
import 'state/employee_list_notifier.dart';
import 'state/review_list_notifier.dart';
import 'widgets/inactivity_watcher.dart';
import 'router.dart';

import 'repositories/api_phone_repository.dart';
import 'repositories/api_brand_repository.dart';
import 'repositories/api_customer_repository.dart';
import 'repositories/api_loyalty_card_repository.dart';
import 'repositories/api_order_repository.dart';
import 'repositories/api_accessory_repository.dart';
import 'repositories/api_employee_repository.dart';
import 'repositories/api_review_repository.dart';
import 'repositories/phone_repository.dart';
import 'repositories/brand_repository.dart';
import 'repositories/customer_repository.dart';
import 'repositories/loyalty_card_repository.dart';
import 'repositories/order_repository.dart';
import 'repositories/accessory_repository.dart';
import 'repositories/employee_repository.dart';
import 'repositories/review_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await SupabaseClientHolder.init();

  final prefs = await SharedPreferences.getInstance();

  runApp(ShopApp(prefs: prefs));
}

class ShopApp extends StatefulWidget {
  final SharedPreferences prefs;
  const ShopApp({super.key, required this.prefs});

  @override
  State<ShopApp> createState() => _ShopAppState();
}

class _ShopAppState extends State<ShopApp> {
  late final AuthNotifier _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthNotifier(widget.prefs);
    _auth.restore();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthNotifier>.value(value: _auth),

        Provider<PhoneRepository>(create: (_) => ApiPhoneRepository()),
        Provider<BrandRepository>(create: (_) => ApiBrandRepository()),
        Provider<CustomerRepository>(create: (_) => ApiCustomerRepository()),
        Provider<LoyaltyCardRepository>(create: (_) => ApiLoyaltyCardRepository()),
        Provider<OrderRepository>(create: (_) => ApiOrderRepository()),
        Provider<AccessoryRepository>(create: (_) => ApiAccessoryRepository()),
        Provider<EmployeeRepository>(create: (_) => ApiEmployeeRepository()),
        Provider<ReviewRepository>(create: (_) => ApiReviewRepository()),

        ChangeNotifierProvider(
          create: (context) => PhoneListNotifier(context.read<PhoneRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => BrandListNotifier(context.read<BrandRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CustomerListNotifier(context.read<CustomerRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AccessoryListNotifier(context.read<AccessoryRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => EmployeeListNotifier(context.read<EmployeeRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => ReviewListNotifier(context.read<ReviewRepository>()),
        ),
      ],
      child: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  Timer? _sessionTimer;

  @override
  void initState() {
    super.initState();
    _sessionTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (!mounted) return;
      final auth = context.read<AuthNotifier>();
      if (auth.isAuthenticated && auth.isSessionExpired) {
        auth.logout();
      }
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthNotifier>();
    final router = buildRouter(auth);

    return InactivityWatcher(
      timeout: const Duration(minutes: 5),
      warningBefore: const Duration(seconds: 30),
      onTimeout: () {
        if (auth.isAuthenticated) auth.logout();
      },
      child: MaterialApp.router(
        title: 'OnlyPhones 💗',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.pink.shade300,
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.pink,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.pink, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        routerConfig: router,
      ),
    );
  }
}