import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/constants.dart';
import '../models/clinic.dart';
import '../utils/image_utils.dart';

class ClinicCard extends StatelessWidget {
  final Clinic clinic;

  const ClinicCard({super.key, required this.clinic});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/clinics/${clinic.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: clinic.image != null
                      ? CachedNetworkImage(
                          imageUrl: resolveImageUrl(clinic.image),
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 140,
                      color: const Color(AppColors.primary).withOpacity(0.1),
                      child: const Center(child: Icon(Icons.local_hospital, size: 48, color: Color(AppColors.primary))),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                      if (clinic.rating != null)
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            Text('${clinic.rating!.toStringAsFixed(1)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          ],
                        ),
                    ],
                  ),
                  if (clinic.address != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: Color(AppColors.textSecondary)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            clinic.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Color(AppColors.textSecondary), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
