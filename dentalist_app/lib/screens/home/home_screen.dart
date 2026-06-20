import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/clinic_provider.dart';
import '../../widgets/doctor_card.dart';
import '../../widgets/clinic_card.dart';
import '../../widgets/empty_state.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _activeFilter = 'Barchasi';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(doctorListProvider.notifier).loadDoctors();
      ref.read(clinicListProvider.notifier).loadClinics();
    });
  }

  void _onFilterChanged(String filter) {
    setState(() => _activeFilter = filter);
    final notifier = ref.read(doctorListProvider.notifier);
    final params = <String, dynamic>{};
    if (filter == 'Ayol doktor') params['gender'] = 'female';
    else if (filter == '24/7') params['is_24_7'] = true;
    else if (filter == 'Eng yaqin') params['ordering'] = 'distance';
    else if (filter == 'Bolalar') params['patient_type'] = 'children';
    notifier.setFilter(params);
  }

  List<String> get _filterChips {
    return ['Barchasi', 'Ayol doktor', '24/7', 'Eng yaqin', 'Bolalar'];
  }

  @override
  Widget build(BuildContext context) {
    final doctorState = ref.watch(doctorListProvider);
    final clinicState = ref.watch(clinicListProvider);
    final doctors = doctorState.doctors;
    final clinics = clinicState.clinics;
    final isLoading = doctorState.isLoading;

    final nearbyDoc = doctors.where((d) => d.distanceKm != null).take(8).toList();
    final topRated = doctors.where((d) => (d.rating ?? 0) > 0).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));
    final femaleDocs = doctors.where((d) => d.isFemale).take(4).toList();
    final roundClock = doctors.where((d) => d.workStart == '00:00' || d.workStart == '0:00')
        .take(4).toList();
    final topClinics = clinics.where((c) => (c.rating ?? 0) > 0).toList()
      ..sort((a, b) => (b.rating ?? 0).compareTo(a.rating ?? 0));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(doctorListProvider.notifier).loadDoctors();
        await ref.read(clinicListProvider.notifier).loadClinics();
      },
      child: CustomScrollView(
        slivers: [
          // Filter Chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _filterChips.length,
                itemBuilder: (_, i) {
                  final f = _filterChips[i];
                  final isActive = _activeFilter == f;
                  final isFemale = f == 'Ayol doktor';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _onFilterChanged(f),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: isActive ? (isFemale ? const Color(0xFFE056C5) : const Color(AppColors.primary)) : (isFemale ? const Color(0xFFFFE0F0) : const Color(AppColors.surface)),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive ? (isFemale ? const Color(0xFFE056C5) : const Color(AppColors.primary)) : (isFemale ? const Color(0xFFE056C5) : const Color(AppColors.border)),
                          ),
                        ),
                        child: Text(
                          f,
                          style: TextStyle(
                            color: isActive ? Colors.white : (isFemale ? const Color(0xFFE056C5) : const Color(AppColors.textSecondary)),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Filtered Doctors section (shown when not "Barchasi")
          if (_activeFilter != 'Barchasi') ...[
            if (isLoading)
              _buildShimmerGrid(4)
            else if (doctors.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: EmptyState(
                    icon: Icons.search_off,
                    message: 'Bu filter bo\'yicha shifokor topilmadi',
                  ),
                ),
              )
            else
              SliverToBoxAdapter(
                child: _SectionHeader(title: _activeFilter),
              ),
            if (!isLoading && doctors.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => DoctorCard(doctor: doctors[i]),
                    childCount: doctors.length,
                  ),
                ),
              ),
          ],

          // Nearby Doctors
          if (nearbyDoc.isNotEmpty || isLoading)
            _buildDoctorSection('Eng yaqin shifokorlar', nearbyDoc, isLoading),

          // Popular Clinics
          _buildClinicsSection('Mashhur klinikalar', topClinics, clinicState.isLoading),

          // Top Rated Doctors
          if (topRated.take(8).isNotEmpty || isLoading)
            _buildDoctorSection('Eng yaxshi shifokorlar', topRated.take(8).toList(), isLoading),

          // 24/7 Doctors
          if (roundClock.isNotEmpty || isLoading)
            _buildDoctorSection('24/7 ishlaydigan', roundClock, isLoading),

          // Female Doctors
          if (femaleDocs.isNotEmpty || isLoading)
            _buildDoctorSection('Ayol shifokorlar', femaleDocs, isLoading),

          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildDoctorSection(String title, List list, bool loading) {
    if (loading) return _buildShimmerGrid(4);
    if (list.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: title, onSeeAll: () => context.go('/doctors')),
          SizedBox(
            height: 280,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8),
              itemCount: list.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(width: 180, child: DoctorCard(doctor: list[i])),
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildClinicsSection(String title, List list, bool loading) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () => context.go('/search'),
                  child: const Text('Barchasi', style: TextStyle(fontSize: 12, color: Color(AppColors.primary), fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
          if (loading)
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16),
                itemCount: 3,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _shimmerCard(width: 180, height: 180),
                ),
              ),
            )
          else if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text('Klinikalar mavjud emas', style: TextStyle(color: Color(AppColors.textSecondary))),
            )
          else
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 16, right: 8),
                itemCount: list.length > 5 ? 5 : list.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: SizedBox(width: 180, child: ClinicCard(clinic: list[i])),
                ),
              ),
            ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildShimmerGrid(int count) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 0.7,
        ),
        delegate: SliverChildBuilderDelegate(
          (_, i) => _shimmerCard(width: double.infinity, height: double.infinity),
          childCount: count,
        ),
      ),
    );
  }

  Widget _shimmerCard({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: const Text('Barchasi', style: TextStyle(fontSize: 12, color: Color(AppColors.primary), fontWeight: FontWeight.w500)),
            ),
        ],
      ),
    );
  }
}
