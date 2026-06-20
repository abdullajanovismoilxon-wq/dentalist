import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/doctor.dart';
import '../repositories/auth_repository.dart';
import 'api_service_provider.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>((ref) {
  return FavoriteRepository(ref.read(apiServiceProvider));
});

class FavoriteState {
  final bool isLoading;
  final List<Doctor> favorites;

  const FavoriteState({
    this.isLoading = false,
    this.favorites = const [],
  });

  FavoriteState copyWith({
    bool? isLoading,
    List<Doctor>? favorites,
  }) {
    return FavoriteState(
      isLoading: isLoading ?? this.isLoading,
      favorites: favorites ?? this.favorites,
    );
  }
}

final favoriteProvider = StateNotifierProvider<FavoriteNotifier, FavoriteState>((ref) {
  return FavoriteNotifier(ref.read(favoriteRepositoryProvider));
});

class FavoriteNotifier extends StateNotifier<FavoriteState> {
  final FavoriteRepository _repository;

  FavoriteNotifier(this._repository) : super(const FavoriteState());

  Future<void> loadFavorites() async {
    state = state.copyWith(isLoading: true);
    final favorites = await _repository.getFavorites();
    state = state.copyWith(isLoading: false, favorites: favorites);
  }

  Future<void> toggleFavorite(int doctorId) async {
    final isFavorite = state.favorites.any((d) => d.id == doctorId);
    if (isFavorite) {
      await _repository.removeFavorite(doctorId);
      state = state.copyWith(
        favorites: state.favorites.where((d) => d.id != doctorId).toList(),
      );
    } else {
      await _repository.addFavorite(doctorId);
      await loadFavorites();
    }
  }

  bool isFavorite(int doctorId) {
    return state.favorites.any((d) => d.id == doctorId);
  }
}
