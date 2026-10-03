import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'core/auth/oidc_service.dart';
import 'core/auth/token_store.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_viewmodel.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/auth_viewmodel.dart';
import 'features/expense/data/repositories/category_repository.dart';
import 'features/expense/data/repositories/transaction_repository.dart';
import 'features/expense/presentation/viewmodels/category_viewmodel.dart';
import 'features/expense/presentation/viewmodels/transaction_viewmodel.dart';
import 'features/expense/router/app_router.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // Services and the router are created once for the app's lifetime.
  late final TokenStore _tokenStore = TokenStore();
  late final ApiClient _apiClient = ApiClient(tokenStore: _tokenStore);
  late final AuthViewModel _authViewModel = AuthViewModel(
    repository: AuthRepository(
      oidcService: OidcService(tokenStore: _tokenStore),
      tokenStore: _tokenStore,
      apiClient: _apiClient,
    ),
  );
  late final GoRouter _router = buildAppRouter(_authViewModel);

  @override
  void initState() {
    super.initState();
    _apiClient.onUnauthorized = _authViewModel.handleSessionExpired;
  }

  @override
  void dispose() {
    _authViewModel.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>.value(value: _apiClient),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider.value(value: _authViewModel),
        ChangeNotifierProvider(create: (_) => TransactionViewModel(repository: TransactionRepository(apiClient: _apiClient))),
        ChangeNotifierProvider(create: (_) => CategoryViewModel(repository: CategoryRepository(apiClient: _apiClient))),
      ],
      child: Builder(
        builder: (context) {
          final authStatus = context.select<AuthViewModel, AuthStatus>((vm) => vm.status);
          final themeViewModel = context.watch<ThemeViewModel>();

          if (authStatus == AuthStatus.unknown) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: themeViewModel.mode,
              home: const Scaffold(body: Center(child: CircularProgressIndicator())),
            );
          }

          return MaterialApp.router(
            title: 'บันทึกรายรับ-รายจ่าย',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeViewModel.mode,
            locale: const Locale('th'),
            supportedLocales: const [Locale('th'), Locale('en')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
