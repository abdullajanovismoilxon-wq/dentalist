import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../../models/clinic_service.dart';
import '../../providers/doctor_provider.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  List<ClinicService> _services = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    setState(() => _loading = true);
    final repo = ref.read(doctorRepositoryProvider);
    final raw = await repo.getServices();
    final services = raw.map((e) => ClinicService.fromJson(e as Map<String, dynamic>)).toList();
    setState(() {
      _services = services;
      _loading = false;
    });
  }

  Future<void> _addService() async {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final durationCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yangi xizmat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Xizmat nomi')),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Narxi'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Daqiqa'), keyboardType: TextInputType.number),
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
      final ok = await repo.createService({
        'name': nameCtrl.text,
        'price': double.tryParse(priceCtrl.text) ?? 0,
        'duration': int.tryParse(durationCtrl.text),
      });
      if (ok && mounted) {
        context.showSnackBar('Xizmat qo\'shildi');
        _loadServices();
      } else if (mounted) {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  Future<void> _editService(ClinicService service) async {
    final nameCtrl = TextEditingController(text: service.name);
    final priceCtrl = TextEditingController(text: service.price.toStringAsFixed(0));
    final durationCtrl = TextEditingController(text: service.duration?.toString() ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xizmatni tahrirlash'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Xizmat nomi')),
            const SizedBox(height: 12),
            TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Narxi'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextField(controller: durationCtrl, decoration: const InputDecoration(labelText: 'Daqiqa'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Bekor qilish')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );

    if (result == true) {
      final repo = ref.read(doctorRepositoryProvider);
      final ok = await repo.updateService(service.id, {
        'name': nameCtrl.text,
        'price': double.tryParse(priceCtrl.text) ?? 0,
        'duration': int.tryParse(durationCtrl.text),
      });
      if (ok && mounted) {
        context.showSnackBar('Xizmat yangilandi');
        _loadServices();
      } else if (mounted) {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  Future<void> _deleteService(ClinicService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xizmatni o\'chirish'),
        content: Text('"${service.name}" xizmatini o\'chirmoqchimisiz?'),
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
      final ok = await repo.deleteService(service.id);
      if (ok && mounted) {
        context.showSnackBar('Xizmat o\'chirildi');
        _loadServices();
      } else if (mounted) {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xizmatlar'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: _addService),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _services.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services_outlined, size: 64, color: Color(AppColors.textHint)),
                      SizedBox(height: 16),
                      Text('Xizmatlar mavjud emas', style: TextStyle(color: Color(AppColors.textSecondary))),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _services.length,
                  itemBuilder: (_, i) {
                    final s = _services[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: s.duration != null ? Text('${s.duration} daqiqa') : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('${s.price.toStringAsFixed(0)} so\'m',
                                style: const TextStyle(color: Color(AppColors.primary), fontWeight: FontWeight.w600)),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => _deleteService(s),
                            ),
                          ],
                        ),
                        onTap: () => _editService(s),
                      ),
                    );
                  },
                ),
    );
  }
}
