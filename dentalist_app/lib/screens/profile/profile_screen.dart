import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../utils/image_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _allergiesController = TextEditingController();
  String _bloodGroup = '';
  String _gender = '';
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authStateProvider.notifier).checkAuth();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _allergiesController.dispose();
    super.dispose();
  }

  void _initForm(User user) {
    if (!_isEditing) {
      _firstNameController.text = user.firstName ?? '';
      _lastNameController.text = user.lastName ?? '';
      _emailController.text = user.email ?? '';
      _allergiesController.text = user.allergies ?? '';
      _bloodGroup = user.bloodGroup ?? '';
      _gender = user.gender ?? '';
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512);
    if (picked == null) return;
    final notifier = ref.read(authStateProvider.notifier);
    await notifier.uploadAvatar(picked.path);
    if (mounted) ref.read(authStateProvider.notifier).checkAuth();
  }

  Future<void> _deleteAvatar() async {
    final notifier = ref.read(authStateProvider.notifier);
    await notifier.deleteAvatar();
    if (mounted) ref.read(authStateProvider.notifier).checkAuth();
  }

  Future<void> _saveProfile() async {
    final notifier = ref.read(authStateProvider.notifier);
    await notifier.updateProfile({
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'email': _emailController.text,
      'allergies': _allergiesController.text,
      'blood_group': _bloodGroup,
      'gender': _gender,
    });
    if (mounted) {
      setState(() => _isEditing = false);
      ref.read(authStateProvider.notifier).checkAuth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    if (authState.isLoading && user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_outline, size: 64, color: Color(AppColors.textHint)),
              const SizedBox(height: 16),
              const Text('Profilni ko\'rish uchun kiring', style: TextStyle(color: Color(AppColors.textSecondary))),
              const SizedBox(height: 16),
              AppButton(label: 'Kirish', onPressed: () => context.go('/auth/login')),
            ],
          ),
        ),
      );
    }

    _initForm(user);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(authStateProvider.notifier).checkAuth(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE0F7FA), Color(0xFFFCE4F8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.white,
                          backgroundImage: user.avatar != null ? NetworkImage(resolveImageUrl(user.avatar)) : null,
                          child: user.avatar == null
                              ? Text(user.initials, style: const TextStyle(fontSize: 24, color: Color(AppColors.primary)))
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: _pickAndUploadAvatar,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: Color(AppColors.primary),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                        if (user.avatar != null)
                          Positioned(
                            bottom: 0,
                            left: 0,
                            child: GestureDetector(
                              onTap: _deleteAvatar,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(AppColors.error),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close, size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(user.phone, style: const TextStyle(fontSize: 14, color: Color(AppColors.textSecondary))),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(AppColors.primary).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              user.isDoctor ? 'Shifokor' : 'Bemor',
                              style: const TextStyle(fontSize: 12, color: Color(AppColors.primary), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Info Cards
              Row(
                children: [
                  Expanded(
                    child: _infoCard(Icons.water_drop, 'Qon guruhi', user.bloodGroup ?? 'Ko\'rsatilmagan'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _infoCard(Icons.warning_amber, 'Allergiyalar', user.allergies ?? 'Yo\'q'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Menu items
              Container(
                decoration: BoxDecoration(
                  color: const Color(AppColors.surface),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(AppColors.border)),
                ),
                child: Column(
                  children: [
                    _menuItem(Icons.calendar_month, 'Qabullar', '/appointments'),
                    const Divider(height: 1, indent: 56),
                    _menuItem(Icons.favorite, 'Sevimlilar', '/favorites'),
                    const Divider(height: 1, indent: 56),
                    _menuItem(Icons.notifications, 'Bildirishnomalar', '/notifications'),
                    if (user.isDoctor) ...[
                      const Divider(height: 1, indent: 56),
                      _menuItem(Icons.dashboard, 'Dashboard', '/dashboard'),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Edit Form
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Shaxsiy ma\'lumotlar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  GestureDetector(
                    onTap: () => setState(() => _isEditing = !_isEditing),
                    child: Text(
                      _isEditing ? 'Bekor qilish' : 'Tahrirlash',
                      style: const TextStyle(fontSize: 13, color: Color(AppColors.primary)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isEditing) ...[
                Row(
                  children: [
                    Expanded(child: _buildField('Ism', _firstNameController)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildField('Familiya', _lastNameController)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildField('Email', _emailController),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildDropdown('Qon guruhi', _bloodGroup, ['', 'I+', 'I-', 'II+', 'II-', 'III+', 'III-', 'IV+', 'IV-'], (v) => setState(() => _bloodGroup = v))),
                    const SizedBox(width: 10),
                    Expanded(child: _buildDropdown('Jins', _gender, ['', 'male', 'female'], (v) => setState(() => _gender = v), labelMap: {'male': 'Erkak', 'female': 'Ayol'})),
                  ],
                ),
                const SizedBox(height: 10),
                _buildField('Allergiyalar', _allergiesController, hint: 'Agar mavjud bo\'lsa'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppColors.primary),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Saqlash', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ] else ...[
                _infoRow('Ism', user.firstName ?? '—'),
                _infoRow('Familiya', user.lastName ?? '—'),
                _infoRow('Telefon', user.phone),
                _infoRow('Jins', user.gender == 'male' ? 'Erkak' : user.gender == 'female' ? 'Ayol' : '—'),
              ],
              const SizedBox(height: 32),

              // Logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authStateProvider.notifier).logout();
                    context.go('/');
                  },
                  icon: const Icon(Icons.logout, color: Color(AppColors.error)),
                  label: const Text('Chiqish', style: TextStyle(color: Color(AppColors.error))),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(AppColors.error)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(AppColors.surface),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: const Color(AppColors.primary)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, color: Color(AppColors.textSecondary))),
            ],
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Color(AppColors.textSecondary))),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, String route) {
    return InkWell(
      onTap: () => context.go(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: const Color(AppColors.primary)),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
            const Icon(Icons.chevron_right, size: 18, color: Color(AppColors.textHint)),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(AppColors.textSecondary))),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(AppColors.background),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(AppColors.border)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(AppColors.border)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String> onChanged, {Map<String, String>? labelMap}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(AppColors.textSecondary))),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(AppColors.background),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(AppColors.border)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: options.map((opt) => DropdownMenuItem(
                value: opt,
                child: Text(opt.isEmpty ? 'Tanlang' : (labelMap?[opt] ?? opt)),
              )).toList(),
              onChanged: (v) { if (v != null) onChanged(v); },
            ),
          ),
        ),
      ],
    );
  }
}

// Placeholder button widget
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const AppButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(AppColors.primary),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
