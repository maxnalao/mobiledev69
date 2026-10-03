import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import 'auth_viewmodel.dart';

/// Login goes through the OIDC Server (Authorization Code Flow + PKCE) —
/// the app itself never sees or stores the user's password.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AuthViewModel>();
    final mutedStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
        );

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(color: AppColors.jade, borderRadius: BorderRadius.circular(24)),
                  child: const Icon(Icons.savings_rounded, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text('บันทึกรายรับ-รายจ่าย', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text('เข้าสู่ระบบอย่างปลอดภัยผ่าน OIDC Server', textAlign: TextAlign.center, style: mutedStyle),
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 24),
                  _ErrorBanner(message: viewModel.errorMessage!, onClose: viewModel.clearError),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: viewModel.isBusy ? null : viewModel.login,
                    icon: viewModel.isBusy
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.login_rounded),
                    label: const Text('เข้าสู่ระบบด้วย OIDC'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: () => context.go('/signup'), child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _ErrorBanner({required this.message, required this.onClose});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 4, 8),
      decoration: BoxDecoration(color: colors.errorContainer, borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colors.onErrorContainer),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: TextStyle(color: colors.onErrorContainer))),
          IconButton(onPressed: onClose, icon: Icon(Icons.close_rounded, color: colors.onErrorContainer, size: 18)),
        ],
      ),
    );
  }
}
