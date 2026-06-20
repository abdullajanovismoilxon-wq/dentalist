import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../../models/slot.dart';
import '../../providers/doctor_provider.dart';

class SlotsScreen extends ConsumerStatefulWidget {
  const SlotsScreen({super.key});

  @override
  ConsumerState<SlotsScreen> createState() => _SlotsScreenState();
}

class _SlotsScreenState extends ConsumerState<SlotsScreen> {
  List<Slot> _slots = [];
  bool _loading = true;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    setState(() => _loading = true);
    final repo = ref.read(doctorRepositoryProvider);
    final formatted = DateFormat('yyyy-MM-dd').format(_selectedDate);
    final raw = await repo.getSlots(date: formatted);
    final slots = raw.map((e) => Slot.fromJson(e as Map<String, dynamic>)).toList();
    setState(() {
      _slots = slots;
      _loading = false;
    });
  }

  Future<void> _addSlot() async {
    final dateCtrl = TextEditingController(text: DateFormat('yyyy-MM-dd').format(_selectedDate));
    final startCtrl = TextEditingController(text: '10:00');
    final endCtrl = TextEditingController(text: '11:00');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yangi slot'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateCtrl,
              decoration: const InputDecoration(labelText: 'Sana (YYYY-MM-DD)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startCtrl,
              decoration: const InputDecoration(labelText: 'Boshlanish vaqti (HH:mm)'),
              keyboardType: TextInputType.datetime,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endCtrl,
              decoration: const InputDecoration(labelText: 'Tugash vaqti (HH:mm)'),
              keyboardType: TextInputType.datetime,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Qo\'shish'),
          ),
        ],
      ),
    );

    if (result == true) {
      final repo = ref.read(doctorRepositoryProvider);
      final ok = await repo.createSlot({
        'date': dateCtrl.text,
        'start_time': startCtrl.text,
        'end_time': endCtrl.text,
        'is_available': true,
      });
      if (ok && mounted) {
        context.showSnackBar('Slot qo\'shildi');
        _loadSlots();
      } else if (mounted) {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  Future<void> _deleteSlot(Slot slot) async {
    if (slot.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Slotni o\'chirish'),
        content: Text('${slot.startTime} - ${slot.endTime} slotini o\'chirmoqchimisiz?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('O\'chirish'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final repo = ref.read(doctorRepositoryProvider);
      final ok = await repo.deleteSlot(slot.id!);
      if (ok && mounted) {
        context.showSnackBar('Slot o\'chirildi');
        _loadSlots();
      } else if (mounted) {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Slotlar'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addSlot),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    DateFormat('dd.MM.yyyy').format(_selectedDate),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                      _loadSlots();
                    }
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _slots.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, size: 64, color: Color(AppColors.textHint)),
                            SizedBox(height: 16),
                            Text('Slotlar mavjud emas', style: TextStyle(color: Color(AppColors.textSecondary))),
                            SizedBox(height: 16),
                            Text('Yangi slot qo\'shish uchun + tugmasini bosing', style: TextStyle(color: Color(AppColors.textHint))),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _slots.length,
                        itemBuilder: (_, i) {
                          final slot = _slots[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: slot.isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                child: Icon(
                                  Icons.access_time,
                                  color: slot.isAvailable ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text('${slot.startTime} - ${slot.endTime}'),
                              subtitle: Text(DateFormat('dd.MM.yyyy').format(slot.date)),
                              trailing: slot.isAvailable
                                  ? IconButton(
                                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                                      onPressed: () => _deleteSlot(slot),
                                    )
                                  : const Icon(Icons.block, color: Color(AppColors.textHint)),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
