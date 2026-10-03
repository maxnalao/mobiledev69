import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final tokenStore = TokenStore();
    final apiClient = ApiClient(tokenStore: tokenStore);
    final oidcService = OidcService(tokenStore: tokenStore);

    return MultiProvider(
      providers: [
        Provider<ApiClient>(create: (_) => apiClient),
        Provider<AuthRepository>(create: (_) => AuthRepository(apiClient: apiClient, tokenStore: tokenStore)),
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
        ChangeNotifierProvider(create: (_) => AuthViewModel(oidcService: oidcService, tokenStore: tokenStore)),
        ChangeNotifierProvider(create: (_) => TransactionViewModel(repository: TransactionRepository(apiClient: apiClient))),
        ChangeNotifierProvider(create: (_) => CategoryViewModel(repository: CategoryRepository(apiClient: apiClient))),
      ],
      child: Builder(
        builder: (context) {
          final authViewModel = context.watch<AuthViewModel>();
          final themeViewModel = context.watch<ThemeViewModel>();

          if (authViewModel.status == AuthStatus.unknown) {
            return MaterialApp(
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
            routerConfig: buildAppRouter(authViewModel),
          );
        },
      ),
    );
  }
}