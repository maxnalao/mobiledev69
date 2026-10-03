import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../data/auth_repository.dart';
import 'auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSaving = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final repository = context.read<AuthRepository>();
      final error = await repository.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;

      if (error == null) {
        await context.read<AuthViewModel>().completeManualLogin();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
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
                Text(
                  'เข้าสู่ระบบด้วยบัญชีที่คุณสมัครไว้',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'ชื่อผู้ใช้'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'กรุณาระบุชื่อผู้ใช้' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'รหัสผ่าน'),
                  obscureText: true,
                  validator: (v) => (v == null || v.isEmpty) ? 'กรุณาระบุรหัสผ่าน' : null,
                  onFieldSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSaving ? null : _submit,
                    child: _isSaving
                        ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('เข้าสู่ระบบ'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: () => context.go('/signup'), child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก')),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => context.read<AuthViewModel>().loginWithOidc(),
                  icon: const Icon(Icons.login_rounded, size: 18),
                  label: const Text('หรือเข้าสู่ระบบด้วย OIDC'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}