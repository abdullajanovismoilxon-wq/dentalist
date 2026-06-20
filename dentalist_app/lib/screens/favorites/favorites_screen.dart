import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/favorite_provider.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      setState(() => _error = null);
      await ref.read(favoriteProvider.notifier).loadFavorites();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(favoriteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sevimlilar')),
      body: state.isLoading && state.favorites.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? ErrorView(message: _error!, onRetry: _load)
              : RefreshIndicator(
                  onRefresh: _load,
                  child: state.favorites.isEmpty
                      ? ListView(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.6,
                              child: const EmptyState(
                                icon: Icons.favorite_border,
                                message: "Sevimli shifokorlar yo'q",
                              ),
                            ),
                          ],
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: state.favorites.length,
                          itemBuilder: (_, i) => DoctorCard(doctor: state.favorites[i]),
                        ),
                ),
    );
  }
}
