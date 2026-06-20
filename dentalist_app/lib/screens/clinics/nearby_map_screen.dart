import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants.dart';
import '../../providers/clinic_provider.dart';
import '../../widgets/app_components.dart';

class NearbyMapScreen extends ConsumerStatefulWidget {
  const NearbyMapScreen({super.key});

  @override
  ConsumerState<NearbyMapScreen> createState() => _NearbyMapScreenState();
}

class _NearbyMapScreenState extends ConsumerState<NearbyMapScreen> {
  bool _loading = true;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      _currentPosition = LatLng(position.latitude, position.longitude);
      ref.read(clinicListProvider.notifier).setLocation(position.latitude, position.longitude);
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(clinicListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Yaqin klinikalar')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (state.isLoading) const LinearProgressIndicator(),
                // Map
                Expanded(
                  flex: 3,
                  child: _currentPosition != null
                      ? FlutterMap(
                          options: MapOptions(
                            center: _currentPosition,
                            zoom: 13.0,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                              userAgentPackageName: 'com.dentalist.app',
                            ),
                            MarkerLayer(
                              markers: [
                                if (_currentPosition != null)
                                  Marker(
                                    point: _currentPosition!,
                                    width: 40,
                                    height: 40,
                                    child: const Icon(Icons.my_location, color: Color(AppColors.primary), size: 32),
                                  ),
                                ...state.clinics.where((c) => c.latitude != null && c.longitude != null).map((c) => Marker(
                                      point: LatLng(c.latitude!, c.longitude!),
                                      width: 40,
                                      height: 40,
                                      child: GestureDetector(
                                        onTap: () => context.go('/clinics/${c.id}'),
                                        child: const Icon(Icons.local_hospital, color: Colors.red, size: 32),
                                      ),
                                    )),
                              ],
                            ),
                          ],
                        )
                      : const Center(child: Text('Joylashuv aniqlanmadi')),
                ),
                // Clinic list
                Expanded(
                  flex: 2,
                  child: state.clinics.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.map_outlined, size: 48, color: Color(AppColors.textHint)),
                              SizedBox(height: 12),
                              Text('Yaqin klinikalar topilmadi', style: TextStyle(color: Color(AppColors.textSecondary))),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: state.clinics.length,
                          itemBuilder: (_, i) {
                            final clinic = state.clinics[i];
                            return AppCard(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () => context.go('/clinics/${clinic.id}'),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: const Color(AppColors.primaryLight),
                                      child: const Icon(Icons.local_hospital, color: Color(AppColors.primary)),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(clinic.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                          if (clinic.address != null)
                                            Text(clinic.address!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontSize: 13, color: Color(AppColors.textSecondary))),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.chevron_right, color: Color(AppColors.textHint)),
                                  ],
                                ),
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
