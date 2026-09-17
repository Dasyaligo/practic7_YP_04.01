import 'package:go_router/go_router.dart';
import 'state/auth_notifier.dart';
import 'models/app_user.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/forbidden_screen.dart';
import 'screens/home_screen.dart';
import 'screens/phone_list_screen.dart';
import 'screens/phone_detail_screen.dart';
import 'screens/phone_form_screen.dart';
import 'screens/brand_list_screen.dart';
import 'screens/brand_detail_screen.dart';
import 'screens/brand_form_screen.dart';
import 'screens/customer_list_screen.dart';
import 'screens/customer_detail_screen.dart';
import 'screens/customer_form_screen.dart';
import 'screens/order_list_screen.dart';
import 'screens/order_form_screen.dart';
import 'screens/accessory_list_screen.dart';
import 'screens/accessory_detail_screen.dart';
import 'screens/accessory_form_screen.dart';
import 'screens/employee_list_screen.dart';
import 'screens/employee_detail_screen.dart';
import 'screens/employee_form_screen.dart';
import 'screens/review_list_screen.dart';
import 'screens/review_detail_screen.dart';
import 'screens/review_form_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/admin_dashboard_screen.dart';

GoRouter buildRouter(AuthNotifier auth) {
  return GoRouter(
    refreshListenable: auth,
    initialLocation: '/',
    redirect: (context, state) {
      final loggedIn = auth.isAuthenticated;
      final target = state.matchedLocation;
      final isPublic = target == '/login' || target == '/register';

      if (!loggedIn && !isPublic) {
        return '/login?from=${Uri.encodeComponent(state.uri.toString())}';
      }

      if (loggedIn && isPublic) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          from: state.uri.queryParameters['from'],
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forbidden',
        builder: (context, state) => const ForbiddenScreen(),
      ),

      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),

      // ─── PHONES ───
      GoRoute(
        path: '/phones',
        builder: (context, state) => const PhoneListScreen(),
      ),
      GoRoute(
        path: '/phones/new',
        builder: (context, state) => const PhoneFormScreen(),
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/phones/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const PhoneListScreen();
          return PhoneDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/phones/:id/edit',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const PhoneListScreen();
          return PhoneFormScreen(id: id);
        },
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),

      // ─── BRANDS ───
      GoRoute(
        path: '/brands',
        builder: (context, state) => const BrandListScreen(),
      ),
      GoRoute(
        path: '/brands/new',
        builder: (context, state) => const BrandFormScreen(),
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/brands/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const BrandListScreen();
          return BrandDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/brands/:id/edit',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const BrandListScreen();
          return BrandFormScreen(id: id);
        },
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),

      // ─── CUSTOMERS ───
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerListScreen(),
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/customers/new',
        builder: (context, state) => const CustomerFormScreen(),
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const CustomerListScreen();
          return CustomerDetailScreen(id: id);
        },
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/customers/:id/edit',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const CustomerListScreen();
          return CustomerFormScreen(id: id);
        },
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),

      // ─── ORDERS ───
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderListScreen(),
      ),
      GoRoute(
        path: '/orders/new',
        builder: (context, state) => const OrderFormScreen(),
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),

      // ─── ACCESSORIES ───
      GoRoute(
        path: '/accessories',
        builder: (context, state) => const AccessoryListScreen(),
      ),
      GoRoute(
        path: '/accessories/new',
        builder: (context, state) => const AccessoryFormScreen(),
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/accessories/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const AccessoryListScreen();
          return AccessoryDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/accessories/:id/edit',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const AccessoryListScreen();
          return AccessoryFormScreen(id: id);
        },
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),

      // ─── EMPLOYEES ───
      GoRoute(
        path: '/employees',
        builder: (context, state) => const EmployeeListScreen(),
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/employees/new',
        builder: (context, state) => const EmployeeFormScreen(),
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/employees/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const EmployeeListScreen();
          return EmployeeDetailScreen(id: id);
        },
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/employees/:id/edit',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const EmployeeListScreen();
          return EmployeeFormScreen(id: id);
        },
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),

      // ─── REVIEWS ───
      GoRoute(
        path: '/reviews',
        builder: (context, state) => const ReviewListScreen(),
      ),
      GoRoute(
        path: '/reviews/new',
        builder: (context, state) => const ReviewFormScreen(),
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),
      GoRoute(
        path: '/reviews/:id',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const ReviewListScreen();
          return ReviewDetailScreen(id: id);
        },
      ),
      GoRoute(
        path: '/reviews/:id/edit',
        builder: (context, state) {
          final idStr = state.pathParameters['id'];
          final id = int.tryParse(idStr ?? '');
          if (id == null) return const ReviewListScreen();
          return ReviewFormScreen(id: id);
        },
        redirect: (context, state) =>
            auth.has(Role.manager) ? null : '/forbidden',
      ),

      // ─── ADMIN ───
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardScreen(),
        redirect: (context, state) =>
            auth.has(Role.admin) ? null : '/forbidden',
      ),
    ],
    errorBuilder: (context, state) =>
        NotFoundScreen(location: state.uri.toString()),
  );
}