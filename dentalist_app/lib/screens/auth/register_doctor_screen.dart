import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/doctor_provider.dart';

class RegisterDoctorScreen extends ConsumerStatefulWidget {
  const RegisterDoctorScreen({super.key});

  @override
  ConsumerState<RegisterDoctorScreen> createState() => _RegisterDoctorScreenState();
}

class _RegisterDoctorScreenState extends ConsumerState<RegisterDoctorScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _password2Controller = TextEditingController();
  final _clinicNameController = TextEditingController();
  final _clinicAddressController = TextEditingController();
  String _selectedGender = 'male';
  final _experienceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final Set<String> _selectedPatientTypes = {};
  final Set<int> _selectedSpecializationIds = {};

  static const _patientTypeOptions = [
    ('children', 'Bolalar'),
    ('adults', 'Kattalar'),
    ('elderly', 'Qariyalar'),
  ];

  String _getPatientTypeValue() {
    if (_selectedPatientTypes.length == 1) {
      if (_selectedPatientTypes.contains('children')) return 'children';
      if (_selectedPatientTypes.contains('adults')) return 'adults';
    }
    return 'both';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _password2Controller.dispose();
    _clinicNameController.dispose();
    _clinicAddressController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final clinicName = _clinicNameController.text.trim();
    final clinicAddress = _clinicAddressController.text.trim();
    final experienceYears = int.tryParse(_experienceController.text.trim()) ?? 0;
    final patientType = _getPatientTypeValue();

    final specializationsAsync = ref.read(specializationsProvider);
    final allSpecs = specializationsAsync.valueOrNull ?? [];
    final specNames = allSpecs
        .where((s) => _selectedSpecializationIds.contains(s.id))
        .map((s) => s.name)
        .toList();

    debugPrint('[RegisterDoctorScreen] body: {phone: $phone, first_name: $firstName, last_name: $lastName, gender: $_selectedGender, experience_years: $experienceYears, clinic_name: $clinicName, patient_type: $patientType, specializations: $specNames, clinic_address: $clinicAddress}');
    final success = await ref.read(authStateProvider.notifier).registerDoctor(
      phone: phone,
      password: password,
      firstName: firstName,
      lastName: lastName,
      gender: _selectedGender,
      experienceYears: experienceYears,
      clinicName: clinicName,
      patientType: patientType,
      specializations: specNames,
      clinicAddress: clinicAddress,
    );

    debugPrint('[RegisterDoctorScreen] register result: $success');
    if (success && mounted) {
      final authState = ref.read(authStateProvider);
      if (authState.isAuthenticated) {
        context.go('/profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/auth/login'),
                ),
                const SizedBox(height: 16),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(AppColors.primary).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.medical_services, size: 32, color: Color(AppColors.primary)),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Shifokor sifatida',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(AppColors.textPrimary)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Klinikangizni boshqaring',
                  style: TextStyle(fontSize: 16, color: Color(AppColors.textSecondary)),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(labelText: 'Ism', prefixIcon: Icon(Icons.person_outlined)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(labelText: 'Familiya', prefixIcon: Icon(Icons.person_outlined)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Telefon',
                    hintText: '+998 90 123 45 67',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Telefon kiritilmadi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Parol', prefixIcon: Icon(Icons.lock_outlined)),
                  validator: (v) {
                    if (v == null || v.length < 8) return 'Kamida 8 belgi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _password2Controller,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Parolni takrorlang', prefixIcon: Icon(Icons.lock_outlined)),
                  validator: (v) {
                    if (v != _passwordController.text) return 'Parollar mos kelmadi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clinicNameController,
                  decoration: const InputDecoration(labelText: 'Klinika nomi', prefixIcon: Icon(Icons.local_hospital_outlined)),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Klinika nomi kiritilmadi';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                const Text('Bemorlar toifasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(AppColors.textPrimary))),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: _patientTypeOptions.map((option) {
                    final value = option.$1;
                    final label = option.$2;
                    final selected = _selectedPatientTypes.contains(value);
                    return FilterChip(
                      label: Text(label),
                      selected: selected,
                      selectedColor: const Color(AppColors.primary).withOpacity(0.15),
                      checkmarkColor: const Color(AppColors.primary),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            _selectedPatientTypes.add(value);
                          } else {
                            _selectedPatientTypes.remove(value);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clinicAddressController,
                  decoration: const InputDecoration(labelText: 'Klinika manzili', prefixIcon: Icon(Icons.location_on_outlined)),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text('Mutaxassislik', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(AppColors.textPrimary))),
                const SizedBox(height: 8),
                ref.watch(specializationsProvider).when(
                  loading: () => const SizedBox(height: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  error: (_, __) => const SizedBox(height: 40, child: Center(child: Text('Yuklanmadi'))),
                  data: (specs) => Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: specs.map((spec) {
                      final selected = _selectedSpecializationIds.contains(spec.id);
                      return FilterChip(
                        label: Text(spec.name),
                        selected: selected,
                        selectedColor: const Color(AppColors.primary).withOpacity(0.15),
                        checkmarkColor: const Color(AppColors.primary),
                        onSelected: (isSelected) {
                          setState(() {
                            if (isSelected) {
                              _selectedSpecializationIds.add(spec.id);
                            } else {
                              _selectedSpecializationIds.remove(spec.id);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedGender,
                  decoration: const InputDecoration(labelText: 'Jins', prefixIcon: Icon(Icons.wc_outlined)),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Erkak')),
                    DropdownMenuItem(value: 'female', child: Text('Ayol')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _selectedGender = v);
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _experienceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Tajriba (yil)',
                    prefixIcon: Icon(Icons.timeline_outlined),
                  ),
                ),
                if (authState.error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Text(authState.error!, style: const TextStyle(color: Colors.red)),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _register,
                    child: authState.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Ro\'yxatdan o\'tish'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
