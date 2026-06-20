import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../providers/clinic_provider.dart';
import '../../widgets/clinic_card.dart';

class ClinicListScreen extends ConsumerStatefulWidget {
  const ClinicListScreen({super.key});

  @override
  ConsumerState<ClinicListScreen> createState() => _ClinicListScreenState();
}

class _ClinicListScreenState extends ConsumerState<ClinicListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(clinicListProvider.notifier).loadClinics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clinicListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Klinikalar')),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.clinics.isEmpty
              ? const Center(child: Text('Klinika topilmadi', style: TextStyle(color: Color(AppColors.textSecondary))))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.clinics.length,
                  itemBuilder: (_, i) => ClinicCard(clinic: state.clinics[i]),
                ),
    );
  }
}
