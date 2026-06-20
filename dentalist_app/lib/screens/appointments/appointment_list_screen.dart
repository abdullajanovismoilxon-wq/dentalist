import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';

class AppointmentListScreen extends ConsumerStatefulWidget {
  const AppointmentListScreen({super.key});

  @override
  ConsumerState<AppointmentListScreen> createState() => _AppointmentListScreenState();
}

class _AppointmentListScreenState extends ConsumerState<AppointmentListScreen> {
  String _filter = 'all';
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadAppointments);
  }

  Future<void> _loadAppointments() async {
    try {
      setState(() => _error = null);
      await ref.read(appointmentListProvider.notifier).loadAppointments(
        status: _filter == 'all' ? null : _filter,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  void _onFilterChanged(String value) {
    setState(() => _filter = value);
    Future.microtask(() {
      ref.read(appointmentListProvider.notifier).loadAppointments(
        status: value == 'all' ? null : value,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Qabullarim')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _filterChip('all', 'Barchasi'),
                  const SizedBox(width: 8),
                  _filterChip('pending', 'Kutilayotgan'),
                  const SizedBox(width: 8),
                  _filterChip('confirmed', 'Tasdiqlangan'),
                  const SizedBox(width: 8),
                  _filterChip('completed', 'Yakunlangan'),
                  const SizedBox(width: 8),
                  _filterChip('cancelled', 'Bekor qilingan'),
                ],
              ),
            ),
          ),
          Expanded(
            child: state.isLoading && state.appointments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? ErrorView(message: _error!, onRetry: _loadAppointments)
                    : RefreshIndicator(
                        onRefresh: _loadAppointments,
                        child: state.appointments.isEmpty
                            ? ListView(
                                children: [
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height * 0.5,
                                    child: EmptyState(
                                      icon: Icons.calendar_today_outlined,
                                      message: 'Qabullar mavjud emas',
                                      actionLabel: 'Qabulga yozilish',
                                      onAction: () => context.go('/appointments/book'),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: state.appointments.length,
                                itemBuilder: (_, i) => _appointmentCard(state.appointments[i]),
                              ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String value, String label) {
    final selected = _filter == value;
    return GestureDetector(
      onTap: () => _onFilterChanged(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(AppColors.primary) : const Color(AppColors.background),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? const Color(AppColors.primary) : const Color(AppColors.border)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : const Color(AppColors.textSecondary),
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _appointmentCard(Appointment appointment) {
    final statusColors = {
      'pending': const Color(AppColors.warning),
      'confirmed': const Color(AppColors.success),
      'completed': const Color(AppColors.primary),
      'cancelled': const Color(AppColors.error),
    };

    final statusBgColors = {
      'pending': const Color(AppColors.warning).withValues(alpha: 0.1),
      'confirmed': const Color(AppColors.success).withValues(alpha: 0.1),
      'completed': const Color(AppColors.primary).withValues(alpha: 0.1),
      'cancelled': const Color(AppColors.error).withValues(alpha: 0.1),
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    appointment.doctorName ?? 'Shifokor',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColors[appointment.status] ?? const Color(AppColors.textSecondary).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    appointment.statusLabel,
                    style: TextStyle(
                      color: statusColors[appointment.status] ?? const Color(AppColors.textSecondary),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (appointment.clinicName != null && appointment.clinicName!.isNotEmpty) ...[
              _row(Icons.location_on_outlined, appointment.clinicName!),
              const SizedBox(height: 4),
            ],
            _row(Icons.calendar_today_outlined, DateFormat('dd.MM.yyyy').format(appointment.date)),
            const SizedBox(height: 4),
            _row(Icons.access_time, appointment.time),
            if (appointment.notes != null && appointment.notes!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _row(Icons.chat_bubble_outline, appointment.notes!),
            ],
            if (appointment.status == 'pending') ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _cancelDialog(appointment),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(AppColors.error),
                    side: const BorderSide(color: Color(AppColors.error)),
                  ),
                  child: const Text('Bekor qilish'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(AppColors.textSecondary)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 14)),
        ),
      ],
    );
  }

  void _cancelDialog(Appointment appointment) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Qabulni bekor qilish'),
        content: const Text('Siz haqiqatan ham qabulni bekor qilmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Yo'q")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(appointmentListProvider.notifier).cancelAppointment(appointment.id);
            },
            child: const Text('Ha', style: TextStyle(color: Color(AppColors.error))),
          ),
        ],
      ),
    );
  }
}
