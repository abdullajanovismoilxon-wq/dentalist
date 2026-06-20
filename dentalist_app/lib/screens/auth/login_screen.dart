import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    debugPrint('[LoginScreen] login button pressed');
    final success = await ref.read(authStateProvider.notifier).login(
      _phoneController.text.trim(),
      _passwordController.text,
    );

    debugPrint('[LoginScreen] login result: $success');
    if (success && mounted) {
      final authState = ref.read(authStateProvider);
      debugPrint('[LoginScreen] auth state after login: isAuthenticated=${authState.isAuthenticated}');
      if (authState.isAuthenticated) {
        context.go('/profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    size: 32,
                    color: Color(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Kirish',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(AppColors.textPrimary),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hisobingizga kiring',
                  style: TextStyle(fontSize: 16, color: Color(AppColors.textSecondary)),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    hintText: '+998 90 123 45 67',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Telefon kiritilmadi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Parol',
                    prefixIcon: Icon(Icons.lock_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Parol kiritilmadi';
                    return null;
                  },
                ),
                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            authState.error!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _login,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20, height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Kirish'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Hisobingiz yo\'qmi?', style: TextStyle(color: Color(AppColors.textSecondary))),
                    TextButton(
                      onPressed: () => context.go('/auth/register'),
                      child: const Text('Ro\'yxatdan o\'tish'),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Shifokormisiz?', style: TextStyle(color: Color(AppColors.textSecondary))),
                    TextButton(
                      onPressed: () => context.go('/auth/register-doctor'),
                      child: const Text('Shifokor sifatida'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
