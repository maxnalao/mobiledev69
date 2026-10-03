import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../auth/presentation/auth_viewmodel.dart';
import '../../auth/presentation/login_screen.dart';
import '../../auth/presentation/signup_screen.dart';
import '../domain/models/transaction_kind.dart';
import '../domain/models/transaction_model.dart';
import '../presentation/screens/category_summary_screen.dart';
import '../presentation/screens/home_screen.dart';
import '../presentation/screens/summary_chart_screen.dart';
import '../presentation/screens/transaction_detail_screen.dart';
import '../presentation/screens/transaction_form_screen.dart';
import '../presentation/viewmodels/transaction_viewmodel.dart';

/// Route Guard: every route except /login and /signup requires a session.
GoRouter buildAppRouter(AuthViewModel authViewModel) {
  return GoRouter(
    refreshListenable: authViewModel,
    initialLocation: '/',
    redirect: (context, state) {
      if (authViewModel.status == AuthStatus.unknown) return null;

      final publicRoute = state.matchedLocation == '/login' || state.matchedLocation == '/signup';
      final isAuthenticated = authViewModel.status == AuthStatus.authenticated;
      if (!isAuthenticated && !publicRoute) return '/login';
      if (isAuthenticated && publicRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/summary', builder: (context, state) => const SummaryChartScreen()),
      GoRoute(path: '/income', builder: (context, state) => const CategorySummaryScreen(kind: TransactionKind.income)),
      GoRoute(path: '/expense', builder: (context, state) => const CategorySummaryScreen(kind: TransactionKind.expense)),
      GoRoute(path: '/transactions/new', builder: (context, state) => const TransactionFormScreen()),
      GoRoute(
        path: '/transactions/:id',
        builder: (context, state) => TransactionDetailScreen(id: int.parse(state.pathParameters['id']!)),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              final transaction = state.extra as TransactionModel? ?? context.read<TransactionViewModel>().findById(id);
              // Page was refreshed before the list loaded: show detail, which loads it.
              if (transaction == null) return TransactionDetailScreen(id: id);
              return TransactionFormScreen(transaction: transaction);
            },
          ),
        ],
      ),
    ],
  );
}
