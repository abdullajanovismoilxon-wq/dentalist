import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../../models/gallery_image.dart';
import '../../providers/clinic_provider.dart';
import '../../providers/doctor_provider.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  List<GalleryImage> _images = [];
  bool _loading = true;
  int? _clinicId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final doctorRepo = ref.read(doctorRepositoryProvider);
    final profile = await doctorRepo.getDoctorProfile();
    final clinicId = profile?['clinic'] as int?;
    if (clinicId != null) {
      _clinicId = clinicId;
      final clinicRepo = ref.read(clinicRepositoryProvider);
      final images = await clinicRepo.getGallery(clinicId);
      setState(() {
        _images = images;
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024);
    if (file != null && _clinicId != null) {
      final clinicRepo = ref.read(clinicRepositoryProvider);
      final ok = await clinicRepo.uploadGalleryImage(_clinicId!, file.path);
      if (ok && mounted) {
        context.showSnackBar('Rasm yuklandi');
        _loadData();
      } else if (mounted) {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  Future<void> _deleteImage(GalleryImage image) async {
    if (image.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rasmni o\'chirish'),
        content: const Text('Ushbu rasmni o\'chirmoqchimisiz?'),
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
      final clinicRepo = ref.read(clinicRepositoryProvider);
      final ok = await clinicRepo.deleteGalleryImage(image.id!);
      if (ok && mounted) {
        context.showSnackBar('Rasm o\'chirildi');
        _loadData();
      } else if (mounted) {
        context.showSnackBar('Xatolik yuz berdi', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galereya'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_photo_alternate_outlined),
            onPressed: _clinicId != null ? _pickImage : null,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _clinicId == null
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Color(AppColors.textHint)),
                      SizedBox(height: 16),
                      Text('Klinika ma\'lumotlari topilmadi', style: TextStyle(color: Color(AppColors.textSecondary))),
                    ],
                  ),
                )
              : _images.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library_outlined, size: 64, color: Color(AppColors.textHint)),
                          SizedBox(height: 16),
                          Text('Rasmlar mavjud emas', style: TextStyle(color: Color(AppColors.textSecondary))),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: _images.length,
                        itemBuilder: (_, i) {
                          return Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  _images[i].image,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.broken_image, color: Color(AppColors.textHint)),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () => _deleteImage(_images[i]),
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 14),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
    );
  }
}
