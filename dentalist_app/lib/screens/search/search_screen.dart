import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../models/search_results.dart';
import '../../repositories/search_repository.dart';
import '../../providers/api_service_provider.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/clinic_card.dart';
import '../../widgets/empty_state.dart';

final searchResultsProvider = FutureProvider.family<SearchResults?, String>((ref, query) async {
  if (query.length < 2) return null;
  final repo = SearchRepository(ref.read(apiServiceProvider));
  return repo.search(query);
});

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;
  String _query = '';
  String _activeTab = 'doctors';
  bool _showResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _query = value;
        _showResults = value.length >= 2;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final searchAsync = ref.watch(searchResultsProvider(_query));

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Shifokor, klinika yoki mutaxassislik...',
                  prefixIcon: const Icon(Icons.search, size: 20, color: Color(AppColors.textHint)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _query = '';
                              _showResults = false;
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(AppColors.background),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(AppColors.border)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(AppColors.border)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(AppColors.primary)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Results area
            Expanded(
              child: !_showResults
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 48, color: Color(AppColors.textHint)),
                          SizedBox(height: 12),
                          Text('Qidirish uchun kamida 2 ta harf kiriting',
                              style: TextStyle(color: Color(AppColors.textSecondary))),
                        ],
                      ),
                    )
                  : searchAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (_, __) => const Center(child: Text('Xatolik yuz berdi')),
                      data: (results) {
                        if (results == null) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final tabs = [
                          _TabItem('Shifokorlar', 'doctors', results.doctors.length),
                          _TabItem('Klinikalar', 'clinics', results.clinics.length),
                          _TabItem('Mutaxassislik', 'specializations', results.specializations.length),
                        ];

                        return Column(
                          children: [
                            // Tabs
                            Container(
                              margin: const EdgeInsets.symmetric(horizontal: 16),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: const Color(AppColors.background),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                children: tabs.map((tab) => Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _activeTab = tab.key),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      decoration: BoxDecoration(
                                        color: _activeTab == tab.key ? const Color(AppColors.surface) : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${tab.label} (${tab.count})',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: _activeTab == tab.key ? const Color(AppColors.textPrimary) : const Color(AppColors.textSecondary),
                                        ),
                                      ),
                                    ),
                                  ),
                                )).toList(),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Tab content
                            Expanded(
                              child: _buildTabContent(results),
                            ),
                          ],
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(SearchResults results) {
    if (_activeTab == 'doctors') {
      if (results.doctors.isEmpty) {
        return const EmptyState(icon: Icons.person_search, message: 'Shifokor topilmadi');
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: results.doctors.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: DoctorCard(doctor: results.doctors[i]),
        ),
      );
    }

    if (_activeTab == 'clinics') {
      if (results.clinics.isEmpty) {
        return const EmptyState(icon: Icons.local_hospital, message: 'Klinika topilmadi');
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: results.clinics.length,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: ClinicCard(clinic: results.clinics[i]),
        ),
      );
    }

    // specializations
    if (results.specializations.isEmpty) {
      return const EmptyState(icon: Icons.category, message: 'Mutaxassislik topilmadi');
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: results.specializations.map((spec) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(AppColors.surface),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(AppColors.border)),
          ),
          child: Text(spec.name, style: const TextStyle(fontSize: 14)),
        )).toList(),
      ),
    );
  }
}

class _TabItem {
  final String label;
  final String key;
  final int count;
  _TabItem(this.label, this.key, this.count);
}
