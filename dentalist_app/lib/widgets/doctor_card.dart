import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../models/doctor.dart';
import '../providers/favorite_provider.dart';
import '../utils/image_utils.dart';

class DoctorCard extends ConsumerWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(favoriteProvider).favorites.any((d) => d.id == doctor.id);

    return GestureDetector(
      onTap: () => context.go('/doctors/${doctor.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(AppColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(AppColors.border)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            SizedBox(
              height: 110,
              width: double.infinity,
              child: Stack(
                children: [
                  doctor.image != null
                      ? CachedNetworkImage(
                          imageUrl: resolveImageUrl(doctor.image),
                          width: double.infinity,
                          height: 110,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                  if (doctor.distanceKm != null)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${doctor.distanceKm!.toStringAsFixed(1)} km',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                      ),
                    ),
                ],
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(doctor.fullName,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                      ),
                      GestureDetector(
                        onTap: () => ref.read(favoriteProvider.notifier).toggleFavorite(doctor.id),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: isFavorite ? Colors.red : const Color(AppColors.textHint),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  if (doctor.specializationLabel.isNotEmpty)
                    Text(doctor.specializationLabel,
                        style: const TextStyle(fontSize: 10, color: Color(AppColors.textSecondary)),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 12, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text('${doctor.rating?.toStringAsFixed(1) ?? "—"}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 2),
                      Text('(${doctor.reviewCount ?? 0})',
                          style: const TextStyle(fontSize: 10, color: Color(AppColors.textSecondary))),
                      const Spacer(),
                      if (doctor.experience != null)
                        Text('${doctor.experience} yil',
                            style: const TextStyle(fontSize: 10, color: Color(AppColors.textSecondary))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (doctor.clinicName != null)
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 11, color: Color(AppColors.textHint)),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(doctor.clinicName!,
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 10, color: Color(AppColors.textSecondary))),
                        ),
                      ],
                    ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (doctor.consultationPrice != null)
                        Text(_formatPrice(doctor.consultationPrice!.toInt()),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(AppColors.primary))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(AppColors.primaryLight),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Yozilish',
                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Color(AppColors.primary))),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 110,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0F7FA), Color(0xFFFCE4F8)],
        ),
      ),
      child: const Center(child: Icon(Icons.medical_services, size: 36, color: Color(AppColors.primaryLight))),
    );
  }

  String _formatPrice(int price) {
    final s = price.toString();
    final b = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
      b.write(s[i]);
    }
    return '${b.toString()} so\'m';
  }
}

class DoctorCardShimmer extends StatelessWidget {
  const DoctorCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(AppColors.surface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(AppColors.border)),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 110, width: double.infinity, child: DecoratedBox(decoration: BoxDecoration(color: Color(AppColors.border)))),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12, width: 100, child: DecoratedBox(decoration: BoxDecoration(color: Color(AppColors.border), borderRadius: BorderRadius.all(Radius.circular(4))))),
                SizedBox(height: 6),
                SizedBox(height: 10, width: 80, child: DecoratedBox(decoration: BoxDecoration(color: Color(AppColors.border), borderRadius: BorderRadius.all(Radius.circular(4))))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
