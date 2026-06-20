import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../../models/doctor_schedule.dart';
import '../../providers/doctor_provider.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  bool _loading = true;
  bool _saving = false;
  final Map<int, TextEditingController> _startControllers = {};
  final Map<int, TextEditingController> _endControllers = {};
  final Map<int, bool> _workingStatus = {};
  final Map<int, int> _existingIds = {};

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  @override
  void dispose() {
    for (final c in _startControllers.values) c.dispose();
    for (final c in _endControllers.values) c.dispose();
    super.dispose();
  }

  Future<void> _loadSchedule() async {
    setState(() => _loading = true);
    final repo = ref.read(doctorRepositoryProvider);
    final schedule = await repo.getSchedule();
    for (final s in schedule) {
      _startControllers[s.dayOfWeek] = TextEditingController(text: s.startTime ?? '09:00');
      _endControllers[s.dayOfWeek] = TextEditingController(text: s.endTime ?? '18:00');
      _workingStatus[s.dayOfWeek] = s.isWorking;
      if (s.id > 0) _existingIds[s.dayOfWeek] = s.id;
    }
    for (int d = 1; d <= 7; d++) {
      _startControllers.putIfAbsent(d, () => TextEditingController(text: '09:00'));
      _endControllers.putIfAbsent(d, () => TextEditingController(text: '18:00'));
      _workingStatus.putIfAbsent(d, () => true);
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final repo = ref.read(doctorRepositoryProvider);
    int successCount = 0;
    for (int d = 1; d <= 7; d++) {
      final isWorking = _workingStatus[d] ?? true;
      final startTime = _startControllers[d]?.text ?? '09:00';
      final endTime = _endControllers[d]?.text ?? '18:00';
      final data = <String, dynamic>{
        'day_of_week': d,
        'start_time': startTime,
        'end_time': endTime,
        'is_working': isWorking,
      };
      if (_existingIds.containsKey(d)) {
        final ok = await repo.updateSchedule(_existingIds[d]!, data);
        if (ok) successCount++;
      } else {
        final ok = await repo.createSchedule(data);
        if (ok) successCount++;
      }
    }
    setState(() => _saving = false);
    if (mounted) {
      if (successCount == 7) {
        context.showSnackBar('Ish vaqti saqlandi');
      } else {
        context.showSnackBar('Ba\'zi kunlarda xatolik yuz berdi', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ish vaqti')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...List.generate(7, (i) => _dayCard(i + 1)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Saqlash'),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _dayCard(int dayOfWeek) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DoctorSchedule.dayNamesUz[dayOfWeek - 1],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                Switch(
                  value: _workingStatus[dayOfWeek] ?? true,
                  onChanged: (v) => setState(() => _workingStatus[dayOfWeek] = v),
                  activeColor: const Color(AppColors.primary),
                ),
              ],
            ),
            if (_workingStatus[dayOfWeek] == true) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startControllers[dayOfWeek],
                      decoration: const InputDecoration(labelText: 'Boshlanish', prefixText: ' '),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('-', style: TextStyle(fontSize: 18)),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _endControllers[dayOfWeek],
                      decoration: const InputDecoration(labelText: 'Tugash', prefixText: ' '),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
