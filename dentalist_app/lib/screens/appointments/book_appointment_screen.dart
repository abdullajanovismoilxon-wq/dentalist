import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../../models/doctor.dart';
import '../../models/slot.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/appointment_provider.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final int? doctorId;

  const BookAppointmentScreen({super.key, this.doctorId});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  Doctor? _selectedDoctor;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String? _selectedTime;
  final _notesController = TextEditingController();
  bool _loading = true;
  bool _submitting = false;
  List<Slot> _slots = [];
  bool _slotsLoading = false;
  String? _slotsError;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    if (widget.doctorId != null) {
      try {
        final doctor = await ref.read(doctorDetailProvider(widget.doctorId!).future);
        setState(() {
          _selectedDoctor = doctor;
          _loading = false;
        });
        if (doctor != null) _loadSlots();
      } catch (e) {
        setState(() {
          _loading = false;
          _error = e.toString();
        });
      }
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _loadSlots() async {
    if (_selectedDoctor == null) return;
    setState(() {
      _slotsLoading = true;
      _slotsError = null;
      _selectedTime = null;
    });
    try {
      final repo = ref.read(appointmentRepositoryProvider);
      final slots = await repo.getDoctorSlots(_selectedDoctor!.id, _selectedDate);
      setState(() {
        _slots = slots;
        _slotsLoading = false;
      });
    } catch (e) {
      setState(() {
        _slotsError = e.toString();
        _slotsLoading = false;
      });
    }
  }

  Future<void> _book() async {
    if (_selectedDoctor == null || _selectedTime == null) return;
    setState(() => _submitting = true);
    try {
      await ref.read(appointmentListProvider.notifier).createAppointment({
        'doctor': _selectedDoctor!.id,
        'date': DateFormat('yyyy-MM-dd').format(_selectedDate),
        'time': _selectedTime,
        'notes': _notesController.text.trim(),
      });
      if (mounted) {
        context.showSnackBar('Qabul yaratildi');
        context.go('/appointments');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackBar('Xatolik yuz berdi: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  List<DateTime> _next7Days() {
    return List.generate(7, (i) => DateTime.now().add(Duration(days: i + 1)));
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final doctors = ref.watch(doctorListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Qabulga yozilish')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Color(AppColors.error))),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: const Text('Qayta urinish')),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Shifokor', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      if (_selectedDoctor != null)
                        Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(AppColors.primary).withValues(alpha: 0.1),
                              child: Text(_selectedDoctor!.fullName.isNotEmpty ? _selectedDoctor!.fullName[0].toUpperCase() : '?',
                                  style: const TextStyle(color: Color(AppColors.primary))),
                            ),
                            title: Text(_selectedDoctor!.fullName),
                            subtitle: Text(_selectedDoctor!.specializationLabel),
                            trailing: const Icon(Icons.check_circle, color: Color(AppColors.primary)),
                          ),
                        )
                      else
                        DropdownButtonFormField<int>(
                          decoration: const InputDecoration(labelText: 'Shifokorni tanlang'),
                          items: doctors.doctors.map((d) => DropdownMenuItem(value: d.id, child: Text(d.fullName))).toList(),
                          onChanged: (id) {
                            setState(() {
                              _selectedDoctor = doctors.doctors.firstWhere((d) => d.id == id);
                            });
                            _loadSlots();
                          },
                        ),
                      const SizedBox(height: 24),
                      const Text('Sana', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 72,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _next7Days().length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, i) {
                            final date = _next7Days()[i];
                            final selected = _isSameDay(date, _selectedDate);
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selectedDate = date);
                                _loadSlots();
                              },
                              child: Container(
                                width: 64,
                                decoration: BoxDecoration(
                                  color: selected ? const Color(AppColors.primary) : const Color(AppColors.background),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected ? const Color(AppColors.primary) : const Color(AppColors.border),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('E', 'uz').format(date),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: selected ? Colors.white : const Color(AppColors.textSecondary),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      date.day.toString(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: selected ? Colors.white : const Color(AppColors.textPrimary),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Vaqt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      if (_selectedDoctor == null)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Avval shifokorni tanlang', style: TextStyle(color: Color(AppColors.textSecondary))),
                        )
                      else if (_slotsLoading)
                        const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()))
                      else if (_slotsError != null)
                        Center(
                          child: Column(
                            children: [
                              Text(_slotsError!, style: const TextStyle(color: Color(AppColors.error))),
                              const SizedBox(height: 8),
                              TextButton(onPressed: _loadSlots, child: const Text('Qayta urinish')),
                            ],
                          ),
                        )
                      else if (_slots.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('Bu kun uchun bo\'sh vaqtlar mavjud emas',
                              style: TextStyle(color: Color(AppColors.textSecondary))),
                        )
                      else
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _slots
                              .where((s) => s.isAvailable)
                              .map((slot) {
                                final time = slot.startTime.substring(0, 5);
                                final isSelected = _selectedTime == time;
                                return GestureDetector(
                                  onTap: () => setState(() => _selectedTime = time),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? const Color(AppColors.primary) : const Color(AppColors.background),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? const Color(AppColors.primary) : const Color(AppColors.border),
                                      ),
                                    ),
                                    child: Text(
                                      time,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : const Color(AppColors.textPrimary),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      const SizedBox(height: 24),
                      const Text('Izoh', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: "Qo'shimcha ma'lumot...",
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _selectedDoctor != null && _selectedTime != null && !_submitting ? _book : null,
                          child: _submitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : const Text('Qabulga yozilish'),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
