import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.read(authServiceProvider));
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

class AuthState {
  final bool isLoading;
  final User? user;
  final bool isAuthenticated;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.user,
    this.isAuthenticated = false,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    User? user,
    bool? isAuthenticated,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> checkAuth() async {
    debugPrint('[AuthNotifier] checkAuth: start');
    final isLoggedIn = await _repository.isLoggedIn();
    debugPrint('[AuthNotifier] checkAuth: hasToken=$isLoggedIn');
    if (isLoggedIn) {
      final user = await _repository.getProfile();
      debugPrint('[AuthNotifier] checkAuth: profile=${user?.phone}');
      if (user != null) {
        state = AuthState(isAuthenticated: true, user: user);
        debugPrint('[AuthNotifier] checkAuth: authenticated as ${user.phone}');
        return;
      }
      debugPrint('[AuthNotifier] checkAuth: profile fetch FAILED, clearing auth');
    }
    state = const AuthState();
    debugPrint('[AuthNotifier] checkAuth: not authenticated');
  }

  Future<bool> login(String phone, String password) async {
    debugPrint('[AuthNotifier] login: phone=$phone');
    state = state.copyWith(isLoading: true, error: null);
    final user = await _repository.login(phone, password);
    if (user != null) {
      state = AuthState(isAuthenticated: true, user: user);
      debugPrint('[AuthNotifier] login SUCCESS: user=${user.phone}');
      return true;
    }
    state = state.copyWith(isLoading: false, error: _repository.lastError ?? 'Telefon yoki parol noto\'g\'ri');
    debugPrint('[AuthNotifier] login FAILED: ${_repository.lastError}');
    return false;
  }

  Future<bool> register({
    required String phone,
    required String password,
    String? firstName,
    String? lastName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final user = await _repository.register(
      phone: phone,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );
    if (user != null) {
      state = AuthState(isAuthenticated: true, user: user);
      return true;
    }
    state = state.copyWith(isLoading: false, error: _repository.lastError ?? 'Ro\'yxatdan o\'tishda xatolik');
    return false;
  }

  Future<bool> registerDoctor({
    required String phone,
    required String password,
    String? firstName,
    String? lastName,
    String? gender,
    int? experienceYears,
    String? clinicName,
    String? patientType,
    List<String>? specializations,
    String? clinicAddress,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    final user = await _repository.registerDoctor(
      phone: phone,
      password: password,
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      experienceYears: experienceYears,
      clinicName: clinicName,
      patientType: patientType,
      specializations: specializations,
      clinicAddress: clinicAddress,
    );
    if (user != null) {
      state = AuthState(isAuthenticated: true, user: user);
      return true;
    }
    state = state.copyWith(isLoading: false, error: _repository.lastError ?? 'Ro\'yxatdan o\'tishda xatolik');
    return false;
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = await _repository.updateProfile(data);
    if (user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<void> uploadAvatar(String filePath) async {
    final success = await _repository.uploadAvatar(filePath);
    if (success) {
      await _repository.getProfile().then((user) {
        if (user != null) state = state.copyWith(user: user);
      });
    }
  }

  Future<void> deleteAvatar() async {
    final success = await _repository.deleteAvatar();
    if (success) {
      state = state.copyWith(user: state.user?.copyWith(avatar: null));
    }
  }

  Future<void> logout() async {
    debugPrint('[AuthNotifier] logout');
    await _repository.logout();
    state = const AuthState();
    debugPrint('[AuthNotifier] logout: state cleared');
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
