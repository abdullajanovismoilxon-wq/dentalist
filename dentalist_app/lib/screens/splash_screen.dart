import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[SplashScreen] initState');
    debugPrint('[SplashScreen] API_BASE_URL=${ApiConstants.baseUrl}');
    debugPrint('[SplashScreen] REGISTER_URL=${ApiConstants.register}');
    debugPrint('[SplashScreen] LOGIN_URL=${ApiConstants.login}');
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(milliseconds: 500));

    debugPrint('[SplashScreen] checking auth...');
    await ref.read(authStateProvider.notifier).checkAuth();

    if (!mounted) return;

    final authState = ref.read(authStateProvider);
    debugPrint('[SplashScreen] auth check done: isAuthenticated=${authState.isAuthenticated}');

    setState(() => _checked = true);

    if (authState.isAuthenticated) {
      debugPrint('[SplashScreen] navigating to /');
      context.go('/');
    } else {
      debugPrint('[SplashScreen] navigating to /auth/login');
      context.go('/auth/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.primary),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.medical_services_outlined,
                size: 60,
                color: Color(AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Dentalist',
              style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Stomatologik xizmatlar',
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
