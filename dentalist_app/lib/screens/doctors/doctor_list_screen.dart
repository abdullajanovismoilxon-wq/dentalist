import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/doctor_provider.dart';
import '../../widgets/doctor_card.dart';

class DoctorListScreen extends ConsumerStatefulWidget {
  const DoctorListScreen({super.key});

  @override
  ConsumerState<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends ConsumerState<DoctorListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(doctorListProvider.notifier).loadDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(doctorListProvider);
    final specializations = ref.watch(specializationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Shifokorlar')),
      body: Column(
        children: [
          specializations.when(
            data: (specs) => SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildFilterChip(null, 'Barchasi', state.selectedSpecialization == null),
                  ...specs.map((s) => _buildFilterChip(s.id, s.name, state.selectedSpecialization == s.id)),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 50),
            error: (_, __) => const SizedBox(height: 50),
          ),
          Expanded(
            child: state.isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 5,
                    itemBuilder: (_, __) => const DoctorCardShimmer(),
                  )
                : state.doctors.isEmpty
                    ? const Center(child: Text('Shifokor topilmadi', style: TextStyle(color: Color(AppColors.textSecondary))))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.doctors.length,
                        itemBuilder: (_, i) => DoctorCard(doctor: state.doctors[i]),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(int? id, String label, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => ref.read(doctorListProvider.notifier).setSpecialization(id),
      ),
    );
  }
}
