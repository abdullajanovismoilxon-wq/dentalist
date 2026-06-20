import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants.dart';
import '../../models/review.dart';
import '../../models/slot.dart';
import '../../providers/doctor_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../widgets/app_components.dart';
import '../../widgets/star_breakdown.dart';
import '../../widgets/error_view.dart';
import '../../providers/api_service_provider.dart';
import '../../utils/image_utils.dart';

final doctorReviewsProvider = FutureProvider.family<List<Review>, int>((ref, doctorId) async {
  final repo = ref.read(doctorRepositoryProvider);
  return repo.getReviews(doctorId);
});

final doctorServicesProvider = FutureProvider.family<List<dynamic>, int>((ref, doctorId) async {
  final repo = ref.read(doctorRepositoryProvider);
  return repo.getServices();
});

final doctorSlotsProvider = FutureProvider.family<List<Slot>, ({int doctorId, String date})>((ref, params) async {
  final repo = ref.read(appointmentRepositoryProvider);
  return repo.getDoctorSlots(params.doctorId, DateTime.parse(params.date));
});

class DoctorDetailScreen extends ConsumerStatefulWidget {
  final int doctorId;
  const DoctorDetailScreen({super.key, required this.doctorId});

  @override
  ConsumerState<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends ConsumerState<DoctorDetailScreen> {
  final _reviewRatingController = ValueNotifier<double>(5);
  final _reviewCommentController = TextEditingController();
  bool _submittingReview = false;

  // Booking state
  bool _showBooking = false;
  String _selectedDate = '';
  int? _selectedSlotId;

  @override
  void dispose() {
    _reviewRatingController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    final comment = _reviewCommentController.text.trim();
    setState(() => _submittingReview = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.post(ApiConstants.reviews, data: {
        'doctor': widget.doctorId,
        'rating': _reviewRatingController.value.round(),
        if (comment.isNotEmpty) 'comment': comment,
      });
      _reviewCommentController.clear();
      _reviewRatingController.value = 5;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sharhingiz uchun rahmat!"), behavior: SnackBarBehavior.floating),
        );
      }
      ref.invalidate(doctorReviewsProvider(widget.doctorId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: $e"), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _submittingReview = false);
    }
  }

  Future<void> _handleBook() async {
    if (_selectedSlotId == null || _selectedDate.isEmpty) return;
    try {
      final repo = ref.read(appointmentRepositoryProvider);
      await repo.createAppointment({
        'doctor': widget.doctorId,
        'appointment_date': _selectedDate,
        'appointment_time': _getSelectedSlotStartTime(),
      });
      if (mounted) {
        setState(() { _showBooking = false; _selectedDate = ''; _selectedSlotId = null; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Qabul yaratildi!"), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Xatolik: $e"), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  String _getSelectedSlotStartTime() {
    final slots = ref.read(doctorSlotsProvider((doctorId: widget.doctorId, date: _selectedDate))).valueOrNull;
    if (slots == null) return '';
    final slot = slots.where((s) => s.id == _selectedSlotId).firstOrNull;
    return slot?.startTime ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final doctorAsync = ref.watch(doctorDetailProvider(widget.doctorId));
    final reviewsAsync = ref.watch(doctorReviewsProvider(widget.doctorId));
    final favorites = ref.watch(favoriteProvider);
    final isFavorite = favorites.favorites.any((d) => d.id == widget.doctorId);
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Watch slots for selected date
    final slotsAsync = _selectedDate.isNotEmpty
        ? ref.watch(doctorSlotsProvider((doctorId: widget.doctorId, date: _selectedDate)))
        : null;

    return Scaffold(
      body: doctorAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorView(message: err.toString(), onRetry: () => ref.invalidate(doctorDetailProvider(widget.doctorId))),
        data: (doctor) {
          if (doctor == null) return const Center(child: Text('Shifokor topilmadi'));

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(doctorDetailProvider(widget.doctorId));
                  ref.invalidate(doctorReviewsProvider(widget.doctorId));
                  ref.read(favoriteProvider.notifier).loadFavorites();
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──
                      Stack(
                        children: [
                          Container(
                            height: 200,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFE0F7FA), Color(0xFFFCE4EC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12, top: 48,
                            child: GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(Icons.arrow_back, size: 20),
                              ),
                            ),
                          ),
                          Positioned(
                              right: 12, top: 48,
                              child: GestureDetector(
                                onTap: () => ref.read(favoriteProvider.notifier).toggleFavorite(widget.doctorId),
                                child: Container(
                                  width: 36, height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Icon(
                                    isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: isFavorite ? Colors.red : null,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            left: 16, bottom: -40,
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 44,
                                backgroundColor: const Color(AppColors.primaryLight),
                                backgroundImage: doctor.image != null ? CachedNetworkImageProvider(resolveImageUrl(doctor.image)) : null,
                                child: doctor.image == null
                                    ? Text(doctor.fullName.isNotEmpty ? doctor.fullName[0].toUpperCase() : '?',
                                        style: const TextStyle(fontSize: 32, color: Color(AppColors.primary)))
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 52),

                      // ── Doctor Info ──
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(doctor.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            if (doctor.specializations.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(doctor.specializationLabel, style: const TextStyle(fontSize: 14, color: Color(AppColors.textSecondary))),
                            ],
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                AppStarRating(rating: doctor.rating ?? 0, size: StarSize.sm),
                                const SizedBox(width: 6),
                                Text('${doctor.rating?.toStringAsFixed(1) ?? "0.0"} (${doctor.reviewCount ?? 0})',
                                    style: const TextStyle(fontSize: 13, color: Color(AppColors.textSecondary))),
                              ],
                            ),
                            if (doctor.ratingBreakdown != null && doctor.reviewCount! > 0) ...[
                              const SizedBox(height: 12),
                              StarBreakdown(breakdown: doctor.ratingBreakdown!, total: doctor.reviewCount ?? 0),
                            ],
                            const SizedBox(height: 8),
                            if (doctor.clinicName != null || doctor.clinicAddress != null)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.location_on_outlined, size: 18, color: Color(AppColors.primary)),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${doctor.clinicName ?? ""}${doctor.clinicName != null && doctor.clinicAddress != null ? " — " : ""}${doctor.clinicAddress ?? ""}',
                                      style: const TextStyle(fontSize: 13, color: Color(AppColors.textSecondary)),
                                    ),
                                  ),
                                ],
                              ),
                            if (doctor.experience != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.work_outline, size: 18, color: Color(AppColors.primary)),
                                  const SizedBox(width: 4),
                                  Text('${doctor.experience} yillik tajriba', style: const TextStyle(fontSize: 13, color: Color(AppColors.textSecondary))),
                                ],
                              ),
                            ],
                            if (doctor.consultationPrice != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.attach_money_outlined, size: 18, color: Color(AppColors.primary)),
                                  const SizedBox(width: 4),
                                  Text('${doctor.consultationPrice!.toInt()} so\'m', style: const TextStyle(fontSize: 13, color: Color(AppColors.primary), fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ],
                            if (doctor.distanceKm != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.near_me_outlined, size: 18, color: Color(AppColors.primary)),
                                  const SizedBox(width: 4),
                                  Text('Sizdan ${doctor.distanceKm!.toStringAsFixed(1)} km uzoqlikda', style: const TextStyle(fontSize: 13, color: Color(AppColors.textSecondary))),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Bio ──
                      if (doctor.description != null && doctor.description!.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Haqida", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(doctor.description!, style: const TextStyle(fontSize: 14, color: Color(AppColors.textSecondary))),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Reviews Section ──
                      _buildReviewsSection(reviewsAsync),

                      const SizedBox(height: 32),

                      // ── Services ──
                      _buildServicesSection(),

                      const SizedBox(height: 32),

                      // ── Map placeholder ──
                      if (doctor.clinicLatitude != null && doctor.clinicLongitude != null) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text("Manzil", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: GestureDetector(
                            onTap: () {
                              // Open in Google Maps
                            },
                            child: Container(
                              height: 140,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFFE0F7FA), Color(0xFFFCE4EC)]),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.map, size: 32, color: Color(AppColors.primary)),
                                    SizedBox(height: 4),
                                    Text("Xaritada ochish", style: TextStyle(color: Color(AppColors.primary), fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ],
                  ),
                ),
              ),

              // ── Fixed Bottom CTA ──
              Positioned(
                left: 0, right: 0, bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Color(AppColors.border))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: "Chat",
                          icon: Icons.chat_outlined,
                          variant: ButtonVariant.outline,
                          onPressed: () => context.go('/chat'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: "Yozilish",
                          icon: Icons.calendar_today,
                          onPressed: () => setState(() => _showBooking = true),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Booking Modal ──
              if (_showBooking)
                Positioned(
                  left: 0, right: 0, top: 0, bottom: 0,
                  child: GestureDetector(
                    onTap: () => setState(() => _showBooking = false),
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.4),
                      child: GestureDetector(
                        onTap: () {},
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.65,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text("Qabulga yozilish", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                                      GestureDetector(
                                        onTap: () => setState(() => _showBooking = false),
                                        child: const Text("Yopish", style: TextStyle(color: Color(AppColors.textSecondary))),
                                      ),
                                    ],
                                  ),
                                ),
                                const Divider(),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Sanani tanlang", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          height: 48,
                                          child: TextField(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                              suffixIcon: Icon(Icons.calendar_today, size: 20),
                                            ),
                                            readOnly: true,
                                            controller: TextEditingController(text: _selectedDate),
                                            onTap: () async {
                                              final picked = await showDatePicker(
                                                context: context,
                                                initialDate: DateTime.now(),
                                                firstDate: DateTime.now(),
                                                lastDate: DateTime.now().add(const Duration(days: 30)),
                                              );
                                              if (picked != null) {
                                                setState(() {
                                                  _selectedDate = picked.toIso8601String().split('T')[0];
                                                  _selectedSlotId = null;
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        if (_selectedDate.isNotEmpty && slotsAsync != null) ...[
                                          Expanded(
                                            child: slotsAsync.when(
                                              loading: () => const Center(child: CircularProgressIndicator()),
                                              error: (_, __) => const Center(child: Text("Vaqtlarni yuklashda xatolik")),
                                              data: (slots) {
                                                if (slots.isEmpty) {
                                                  return const Center(child: Text("Bu sana uchun vaqtlar mavjud emas"));
                                                }
                                                return GridView.builder(
                                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                    crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.8,
                                                  ),
                                                  itemCount: slots.length,
                                                  itemBuilder: (_, i) {
                                                    final slot = slots[i];
                                                    final isAvail = slot.status == 'available';
                                                    final isSelected = _selectedSlotId == slot.id;
                                                    Color bg, fg, border;
                                                    if (isSelected) {
                                                      bg = const Color(0xFFFCE4EC);
                                                      fg = const Color(0xFFE056C5);
                                                      border = const Color(0xFFE056C5);
                                                    } else if (isAvail) {
                                                      bg = const Color(0xFFE8F5E9);
                                                      fg = const Color(0xFF2E7D32);
                                                      border = const Color(0xFFA5D6A7);
                                                    } else if (slot.status == 'blocked') {
                                                      bg = const Color(0xFFFFF3E0);
                                                      fg = const Color(0xFFE65100);
                                                      border = const Color(0xFFFFCC80);
                                                    } else {
                                                      bg = const Color(0xFFFFEBEE);
                                                      fg = const Color(0xFFC62828);
                                                      border = const Color(0xFFEF9A9A);
                                                    }
                                                    return GestureDetector(
                                                      onTap: isAvail ? () => setState(() => _selectedSlotId = isSelected ? null : slot.id) : null,
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: bg,
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: border),
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Text(slot.startTime.length >= 5 ? slot.startTime.substring(0, 5) : slot.startTime,
                                                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
                                                            Text(
                                                              isAvail ? "Bo'sh" : slot.status == 'blocked' ? "Blok" : "Band",
                                                              style: TextStyle(fontSize: 9, color: fg.withValues(alpha: 0.7)),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                        if (_selectedDate.isEmpty)
                                          const Expanded(child: Center(child: Text("Iltimos, sanani tanlang"))),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: AppButton(
                                      label: _selectedSlotId != null ? "Qabulga yozilish" : (_selectedDate.isNotEmpty ? "Vaqtni tanlang" : "Sanani tanlang"),
                                      onPressed: _selectedSlotId != null ? _handleBook : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewsSection(AsyncValue<List<Review>> reviewsAsync) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Sharhlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              TextButton.icon(
                onPressed: () => ref.invalidate(doctorReviewsProvider(widget.doctorId)),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Yangilash'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          reviewsAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(),
            data: (reviews) => reviews.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(AppColors.background), borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text("Hozircha sharhlar yo'q", style: TextStyle(color: Color(AppColors.textSecondary)))),
                  )
                : Column(
                    children: reviews.map((r) => _reviewTile(r)).toList(),
                  ),
          ),
          const SizedBox(height: 16),

          // ── Add Review Form ──
          const Text("Sharh qoldirish", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text("Baho: ", style: TextStyle(fontSize: 14)),
                    AppStarRating(
                      rating: _reviewRatingController.value, size: StarSize.md,
                      interactive: true,
                      onChanged: (v) => _reviewRatingController.value = v,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _reviewCommentController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: "Fikringizni yozing...",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: "Yuborish", isLoading: _submittingReview, onPressed: _submitReview,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    final servicesAsync = ref.watch(doctorServicesProvider(widget.doctorId));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Xizmatlar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          servicesAsync.when(
            loading: () => const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator())),
            error: (_, __) => const SizedBox(),
            data: (services) => services.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: const Color(AppColors.background), borderRadius: BorderRadius.circular(12)),
                    child: const Center(child: Text("Xizmatlar mavjud emas", style: TextStyle(color: Color(AppColors.textSecondary)))),
                  )
                : SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: services.length,
                      itemBuilder: (_, i) {
                        final s = services[i];
                        final name = s is Map ? (s['title'] ?? s['name'] ?? s['service_name'] ?? '') : s.toString();
                        final price = s is Map ? (s['price'] ?? '') : '';
                        return Container(
                          width: 160,
                          margin: const EdgeInsets.only(right: 12),
                          child: AppCard(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                const Spacer(),
                                if (price.toString().isNotEmpty)
                                  Text('${price.toString()} so\'m',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(AppColors.primary))),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _reviewTile(Review r) {
    return AppCard(
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
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(r.userName ?? 'Foydalanuvchi', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                  AppStarRating(rating: r.rating, size: StarSize.sm),
                ],
              )),
            ],
          ),
          if (r.comment != null && r.comment!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(r.comment!, style: const TextStyle(fontSize: 14, color: Color(AppColors.textSecondary))),
          ],
        ],
      ),
    );
  }
}
