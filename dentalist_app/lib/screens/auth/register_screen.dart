import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    debugPrint('[RegisterScreen] body: {phone: $phone, password: [hidden], password2: [hidden], first_name: $firstName, last_name: $lastName}');
    final success = await ref.read(authStateProvider.notifier).register(
      phone: phone,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    debugPrint('[RegisterScreen] register result: $success');
    if (success && mounted) {
      final authState = ref.read(authStateProvider);
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
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/auth/login'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ro\'yxatdan o\'tish',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(AppColors.textPrimary)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Yangi hisob yarating',
                  style: TextStyle(fontSize: 16, color: Color(AppColors.textSecondary)),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'Ism', prefixIcon: Icon(Icons.person_outlined)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Familiya', prefixIcon: Icon(Icons.person_outlined)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                  decoration: const InputDecoration(labelText: 'Parol', prefixIcon: Icon(Icons.lock_outlined)),
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Kamida 8 belgi';
                    return null;
                  },
                ),
                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(authState.error!, style: const TextStyle(color: Colors.red)),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _register,
                    child: authState.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Ro\'yxatdan o\'tish'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
