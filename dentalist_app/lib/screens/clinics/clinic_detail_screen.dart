import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants.dart';
import '../../models/review.dart';
import '../../models/doctor.dart';
import '../../providers/clinic_provider.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_components.dart';
import '../../utils/image_utils.dart';

final clinicDoctorsProvider = FutureProvider.family<List<Doctor>, int>((ref, clinicId) async {
  final repo = ref.read(doctorRepositoryProvider);
  return repo.getDoctors(extraParams: {'clinic_id': '$clinicId'});
});

final clinicReviewsProvider = FutureProvider.family<List<Review>, int>((ref, clinicId) async {
  final repo = ref.read(clinicRepositoryProvider);
  return repo.getReviews(clinicId);
});

class ClinicDetailScreen extends ConsumerStatefulWidget {
  final int clinicId;
  const ClinicDetailScreen({super.key, required this.clinicId});

  @override
  ConsumerState<ClinicDetailScreen> createState() => _ClinicDetailScreenState();
}

class _ClinicDetailScreenState extends ConsumerState<ClinicDetailScreen> {
  final _reviewRatingNotifier = ValueNotifier<double>(5);
  final _reviewCommentController = TextEditingController();
  bool _submittingReview = false;

  @override
  void dispose() {
    _reviewRatingNotifier.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview(int clinicId) async {
    final comment = _reviewCommentController.text.trim();
    setState(() => _submittingReview = true);
    try {
      final repo = ref.read(clinicRepositoryProvider);
      await repo.createReview(clinicId, {
        'rating': _reviewRatingNotifier.value.round(),
        if (comment.isNotEmpty) 'comment': comment,
      });
      _reviewCommentController.clear();
      _reviewRatingNotifier.value = 5;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sharhingiz qabul qilindi')));
      }
      ref.invalidate(clinicReviewsProvider(clinicId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
      }
    }
    if (mounted) setState(() => _submittingReview = false);
  }

  @override
  Widget build(BuildContext context) {
    final clinicId = widget.clinicId;
    final clinicAsync = ref.watch(clinicDetailProvider(clinicId));
    final servicesAsync = ref.watch(clinicServicesProvider(clinicId));
    final galleryAsync = ref.watch(clinicGalleryProvider(clinicId));
    final hoursAsync = ref.watch(clinicWorkingHoursProvider(clinicId));
    final reviewsAsync = ref.watch(clinicReviewsProvider(clinicId));
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Klinika haqida')),
      body: clinicAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Xatolik yuz berdi')),
        data: (clinic) {
          if (clinic == null) return const Center(child: Text('Klinika topilmadi'));
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Image ──
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: clinic.image != null
                      ? CachedNetworkImage(imageUrl: resolveImageUrl(clinic.image), height: 200, width: double.infinity, fit: BoxFit.cover)
                      : Container(
                          height: 200,
                          color: const Color(AppColors.primaryLight),
                          child: const Center(child: Icon(Icons.local_hospital, size: 64, color: Color(AppColors.primary))),
                        ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(clinic.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    ),
                    if (clinic.is247 == true)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.success).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('24/7', style: TextStyle(color: Color(AppColors.success), fontSize: 12, fontWeight: FontWeight.w600)),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (clinic.rating != null) ...[
                  Row(
                    children: [
                      AppStarRating(rating: clinic.rating!, size: StarSize.sm),
                      const SizedBox(width: 6),
                      Text('${clinic.rating!.toStringAsFixed(1)} (${clinic.reviewCount ?? 0})',
                          style: const TextStyle(color: Color(AppColors.textSecondary))),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                if (clinic.address != null) _infoTile(Icons.location_on_outlined, clinic.address!),
                if (clinic.phone != null) _infoTile(Icons.phone_outlined, clinic.phone!),
                if (clinic.workStart != null && clinic.workEnd != null)
                  _infoTile(Icons.access_time, '${clinic.workStart} - ${clinic.workEnd}'),
                const SizedBox(height: 24),

                // ── Doctors ──
                const Text('Shifokorlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                _buildDoctorsSection(clinicId),
                const SizedBox(height: 24),

                // ── Description ──
                if (clinic.description != null && clinic.description!.isNotEmpty) ...[
                  const Text('Tavsif', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(clinic.description!, style: const TextStyle(fontSize: 15, color: Color(AppColors.textSecondary), height: 1.5)),
                  const SizedBox(height: 24),
                ],

                // ── Working Hours ──
                const Text('Ish vaqti', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                hoursAsync.when(
                  data: (hours) => Column(
                    children: hours.map((h) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(h.dayLabel, style: const TextStyle(fontSize: 14)),
                          Text(
                            h.isWorking ? '${h.startTime ?? '09:00'} - ${h.endTime ?? '18:00'}' : 'Dam olish',
                            style: TextStyle(
                              color: h.isWorking ? const Color(AppColors.textPrimary) : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                  ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),

                // ── Services ──
                const Text('Xizmatlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                servicesAsync.when(
                  data: (services) => services.isEmpty
                      ? const Text('Xizmatlar mavjud emas', style: TextStyle(color: Color(AppColors.textSecondary)))
                      : Column(
                          children: services.map((s) => AppCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w500))),
                                Text('${s.price.toStringAsFixed(0)} so\'m',
                                    style: const TextStyle(color: Color(AppColors.primary), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          )).toList(),
                        ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),

                // ── Gallery ──
                const Text('Galereya', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                galleryAsync.when(
                  data: (images) => images.isEmpty
                      ? const Text('Rasmlar mavjud emas', style: TextStyle(color: Color(AppColors.textSecondary)))
                      : SizedBox(
                          height: 140,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (_, i) => Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: resolveImageUrl(images[i].image),
                                  width: 140,
                                  height: 140,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
                const SizedBox(height: 24),

                // ── Add Review ──
                if (authState.isAuthenticated && authState.user?.role == 'patient') ...[
                  const Text('Baholash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  AppCard(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Baho: ', style: TextStyle(fontSize: 14)),
                            ValueListenableBuilder<double>(
                              valueListenable: _reviewRatingNotifier,
                              builder: (_, v, __) => AppStarRating(
                                rating: v,
                                size: StarSize.md,
                                interactive: true,
                                onChanged: (val) => _reviewRatingNotifier.value = val,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _reviewCommentController,
                          decoration: const InputDecoration(
                            hintText: 'Sharhingiz (ixtiyoriy)',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: AppButton(
                            label: 'Yuborish',
                            isLoading: _submittingReview,
                            onPressed: () => _submitReview(clinicId),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // ── Reviews ──
                const Text('Sharhlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                reviewsAsync.when(
                  data: (reviews) => reviews.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(AppColors.background),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text('Hozircha sharhlar yo\'q', style: TextStyle(color: Color(AppColors.textSecondary))),
                          ),
                        )
                      : Column(
                          children: reviews.map((r) => AppCard(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: const Color(AppColors.primaryLight),
                                      child: Text(r.userName?.isNotEmpty == true ? r.userName![0].toUpperCase() : '?',
                                          style: const TextStyle(fontSize: 14, color: Color(AppColors.primary))),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(r.userName ?? 'Foydalanuvchi', style: const TextStyle(fontWeight: FontWeight.w500))),
                                    AppStarRating(rating: r.rating, size: StarSize.sm),
                                  ],
                                ),
                                if (r.comment != null && r.comment!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(r.comment!, style: const TextStyle(fontSize: 14, color: Color(AppColors.textSecondary))),
                                ],
                              ],
                            ),
                          )).toList(),
                        ),
                  loading: () => const SizedBox(),
                  error: (_, __) => const SizedBox(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDoctorsSection(int clinicId) {
    final doctorsAsync = ref.watch(clinicDoctorsProvider(clinicId));
    return doctorsAsync.when(
      loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
      error: (_, __) => const SizedBox(),
      data: (doctors) => doctors.isEmpty
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: const Color(AppColors.background), borderRadius: BorderRadius.circular(12)),
              child: const Center(child: Text('Shifokorlar mavjud emas', style: TextStyle(color: Color(AppColors.textSecondary)))),
            )
          : Column(
              children: doctors.map((d) => AppCard(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => context.push('/doctors/${d.id}'),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: d.image != null
                            ? CachedNetworkImage(imageUrl: resolveImageUrl(d.image), width: 56, height: 56, fit: BoxFit.cover)
                            : Container(width: 56, height: 56, color: const Color(AppColors.primaryLight), child: const Icon(Icons.person, color: Color(AppColors.primary))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(d.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                            if (d.specializationLabel.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(d.specializationLabel, style: const TextStyle(fontSize: 13, color: Color(AppColors.textSecondary))),
                            ],
                            if (d.rating != null) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  AppStarRating(rating: d.rating!, size: StarSize.sm),
                                  const SizedBox(width: 4),
                                  Text('${d.rating!.toStringAsFixed(1)}', style: const TextStyle(fontSize: 12, color: Color(AppColors.textSecondary))),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Color(AppColors.textHint)),
                    ],
                  ),
                ),
              )).toList(),
            ),
    );
  }

  Widget _infoTile(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(AppColors.primary), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 15))),
        ],
      ),
    );
  }
}
