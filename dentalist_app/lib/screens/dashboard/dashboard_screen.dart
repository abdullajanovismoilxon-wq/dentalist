import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';

final doctorDashboardProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.read(doctorRepositoryProvider);
  final data = await repo.getDashboard();
  return data ?? {};
});

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(appointmentListProvider.notifier).loadAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final state = ref.watch(appointmentListProvider);
    final dashboardAsync = ref.watch(doctorDashboardProvider);
    final pendingCount = state.appointments.where((a) => a.status == 'pending').length;
    final todayCount = state.appointments.where((a) => a.status == 'confirmed').length;

    if (!authState.isAuthenticated || (authState.user != null && !authState.user!.isDoctor)) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Color(AppColors.textHint)),
              const SizedBox(height: 16),
              const Text('Siz shifokor emassiz', style: TextStyle(color: Color(AppColors.textSecondary))),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Bosh sahifaga qaytish'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: state.error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Color(AppColors.error)),
                  const SizedBox(height: 16),
                  Text(state.error!, style: const TextStyle(color: Color(AppColors.textSecondary))),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.read(appointmentListProvider.notifier).loadAppointments(),
                    child: const Text('Qayta urinish'),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref.read(appointmentListProvider.notifier).loadAppointments(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  dashboardAsync.when(
                    data: (dash) {
                      final totalSlots = dash['total_slots_today'] ?? 0;
                      final bookedSlots = dash['booked_slots_today'] ?? 0;
                      final blockedSlots = dash['blocked_slots_today'] ?? 0;
                      final availableSlots = dash['available_slots_today'] ?? 0;
                      final tomorrow = dash['tomorrow_appointments'] ?? 0;
                      final confirmed = dash['confirmed'] ?? 0;
                      final completed = dash['completed'] ?? 0;
                      final cancelled = dash['cancelled'] ?? 0;
                      final total = dash['total_appointments'] ?? 0;
                      final avgRating = dash['avg_rating'];
                      final reviewCount = dash['review_count'] ?? 0;
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: _statCard(Icons.calendar_today_outlined, 'Kutilayotgan', '$pendingCount', const Color(AppColors.warning))),
                              const SizedBox(width: 8),
                              Expanded(child: _statCard(Icons.check_circle_outlined, 'Bugungi', '$todayCount', const Color(AppColors.primary))),
                              const SizedBox(width: 8),
                              Expanded(child: _statCard(Icons.people_outlined, 'Jami', '$total', const Color(AppColors.secondary))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _statCard(Icons.done_all_outlined, 'Tasdiqlangan', '$confirmed', const Color(AppColors.success))),
                              const SizedBox(width: 8),
                              Expanded(child: _statCard(Icons.task_alt_outlined, 'Yakunlangan', '$completed', const Color(AppColors.primary))),
                              const SizedBox(width: 8),
                              Expanded(child: _statCard(Icons.cancel_outlined, 'Bekor qilingan', '$cancelled', const Color(AppColors.error))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _statCard(Icons.event_available_outlined, "Bugun bo'sh", '$availableSlots', const Color(AppColors.success))),
                              const SizedBox(width: 8),
                              Expanded(child: _statCard(Icons.event_busy_outlined, "Bugun band", '$bookedSlots', const Color(AppColors.error))),
                              const SizedBox(width: 8),
                              Expanded(child: _statCard(Icons.block_outlined, "Bloklangan", '$blockedSlots', const Color(AppColors.textHint))),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _statCard(Icons.arrow_forward_outlined, 'Ertangi', '$tomorrow', const Color(AppColors.warning)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _statCard(Icons.star_outlined, 'Reyting',
                                    avgRating != null ? (avgRating as num).toStringAsFixed(1) : '-' , const Color(0xFFFBBF24)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _statCard(Icons.rate_review_outlined, 'Sharhlar', '$reviewCount', const Color(AppColors.primary)),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                    loading: () => Row(
                      children: [
                        Expanded(child: _statCard(Icons.calendar_today_outlined, 'Kutilayotgan', '$pendingCount', const Color(AppColors.warning))),
                        const SizedBox(width: 8),
                        Expanded(child: _statCard(Icons.check_circle_outlined, 'Bugungi', '$todayCount', const Color(AppColors.primary))),
                        const SizedBox(width: 8),
                        Expanded(child: _statCard(Icons.people_outlined, 'Jami', '${state.appointments.length}', const Color(AppColors.secondary))),
                      ],
                    ),
                    error: (_, __) => Row(
                      children: [
                        Expanded(child: _statCard(Icons.calendar_today_outlined, 'Kutilayotgan', '$pendingCount', const Color(AppColors.warning))),
                        const SizedBox(width: 8),
                        Expanded(child: _statCard(Icons.check_circle_outlined, 'Bugungi', '$todayCount', const Color(AppColors.primary))),
                        const SizedBox(width: 8),
                        Expanded(child: _statCard(Icons.people_outlined, 'Jami', '${state.appointments.length}', const Color(AppColors.secondary))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text('Boshqaruv', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  _menuCard(Icons.schedule_outlined, 'Ish vaqti', 'Ish vaqtini boshqarish', () => context.go('/dashboard/schedule')),
                  const SizedBox(height: 8),
                  _menuCard(Icons.access_time, 'Slotlar', 'Bo\'sh vaqtlarni belgilash', () => context.go('/dashboard/slots')),
                  const SizedBox(height: 8),
                  _menuCard(Icons.medical_services_outlined, 'Xizmatlar', 'Xizmatlar ro\'yxati', () => context.go('/dashboard/services')),
                  const SizedBox(height: 8),
                  _menuCard(Icons.photo_library_outlined, 'Galereya', 'Klinika rasmlari', () => context.go('/dashboard/gallery')),
                  const SizedBox(height: 32),
                  const Text('So\'nggi qabullar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  if (state.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state.appointments.isEmpty)
                    const Card(child: Padding(padding: EdgeInsets.all(24), child: Center(child: Text('Qabullar mavjud emas'))))
                  else
                    ...state.appointments.take(5).map((a) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(AppColors.primary).withOpacity(0.1),
                          child: Text(a.patientName?.isNotEmpty == true ? a.patientName![0].toUpperCase() : 'P',
                              style: const TextStyle(color: Color(AppColors.primary))),
                        ),
                        title: Text(a.patientName ?? 'Bemor', style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text('${a.date.toString().split(' ')[0]} ${a.time}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: a.status == 'pending'
                                ? const Color(AppColors.warning).withOpacity(0.1)
                                : a.status == 'confirmed'
                                    ? const Color(AppColors.primary).withOpacity(0.1)
                                    : const Color(AppColors.success).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            a.statusLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: a.status == 'pending'
                                  ? const Color(AppColors.warning)
                                  : a.status == 'confirmed'
                                      ? const Color(AppColors.primary)
                                      : const Color(AppColors.success),
                            ),
                          ),
                        ),
                      ),
                    )),
                ],
              ),
            ),
    );
  }

  Widget _statCard(IconData icon, String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Color(AppColors.textSecondary))),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(AppColors.primary).withOpacity(0.1),
          child: Icon(icon, color: const Color(AppColors.primary)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
