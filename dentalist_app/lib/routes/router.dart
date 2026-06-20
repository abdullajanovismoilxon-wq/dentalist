import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/register_doctor_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/doctors/doctor_list_screen.dart';
import '../screens/doctors/doctor_detail_screen.dart';
import '../screens/clinics/clinic_list_screen.dart';
import '../screens/clinics/clinic_detail_screen.dart';
import '../screens/clinics/nearby_map_screen.dart';
import '../screens/appointments/appointment_list_screen.dart';
import '../screens/appointments/book_appointment_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/chat/chat_list_screen.dart';
import '../screens/chat/chat_detail_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/dashboard/schedule_screen.dart';
import '../screens/dashboard/slots_screen.dart';
import '../screens/dashboard/services_screen.dart';
import '../screens/dashboard/gallery_screen.dart';
import '../screens/splash_screen.dart';
import '../core/constants.dart';

final _authChangeNotifier = ValueNotifier<int>(0);

final routerProvider = Provider<GoRouter>((ref) {
  ref.listen<AuthState>(authStateProvider, (prev, next) {
    _authChangeNotifier.value++;
  });

  return GoRouter(
    refreshListenable: _authChangeNotifier,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/auth');
      final isSplash = state.matchedLocation == '/splash';

      if (isSplash) return null;
      if (!isAuthenticated && !isAuthRoute) return '/auth/login';
      if (isAuthenticated && isAuthRoute) return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', name: 'splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth/login', name: 'login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/auth/register', name: 'register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/auth/register-doctor', name: 'registerDoctor', builder: (_, __) => const RegisterDoctorScreen()),
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithNavBar(location: state.matchedLocation, child: child),
        routes: [
          GoRoute(path: '/', name: 'home', builder: (_, __) => const HomeScreen()),
          GoRoute(path: '/search', name: 'search', builder: (_, __) => const SearchScreen()),
          GoRoute(path: '/doctors', name: 'doctors', builder: (_, __) => const DoctorListScreen()),
          GoRoute(path: '/doctors/:id', name: 'doctorDetail', builder: (_, state) => DoctorDetailScreen(doctorId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/clinics', name: 'clinics', builder: (_, __) => const ClinicListScreen()),
          GoRoute(path: '/clinics/:id', name: 'clinicDetail', builder: (_, state) => ClinicDetailScreen(clinicId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/nearby', name: 'nearby', builder: (_, __) => const NearbyMapScreen()),
          GoRoute(path: '/appointments', name: 'appointments', builder: (_, __) => const AppointmentListScreen()),
          GoRoute(path: '/appointments/book', name: 'bookAppointment', builder: (_, state) {
            final doctorId = int.tryParse(state.uri.queryParameters['doctor_id'] ?? '');
            return BookAppointmentScreen(doctorId: doctorId);
          }),
          GoRoute(path: '/favorites', name: 'favorites', builder: (_, __) => const FavoritesScreen()),
          GoRoute(path: '/notifications', name: 'notifications', builder: (_, __) => const NotificationsScreen()),
          GoRoute(path: '/profile', name: 'profile', builder: (_, __) => const ProfileScreen()),
          GoRoute(path: '/chat', name: 'chat', builder: (_, __) => const ChatListScreen()),
          GoRoute(path: '/chat/:id', name: 'chatDetail', builder: (_, state) => ChatDetailScreen(conversationId: int.parse(state.pathParameters['id']!))),
          GoRoute(path: '/dashboard', name: 'dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/dashboard/schedule', name: 'dashboardSchedule', builder: (_, __) => const ScheduleScreen()),
          GoRoute(path: '/dashboard/slots', name: 'dashboardSlots', builder: (_, __) => const SlotsScreen()),
          GoRoute(path: '/dashboard/services', name: 'dashboardServices', builder: (_, __) => const ServicesScreen()),
          GoRoute(path: '/dashboard/gallery', name: 'dashboardGallery', builder: (_, __) => const GalleryScreen()),
        ],
      ),
    ],
  );
});

class ScaffoldWithNavBar extends ConsumerStatefulWidget {
  final Widget child;
  final String location;

  const ScaffoldWithNavBar({super.key, required this.child, required this.location});

  @override
  ConsumerState<ScaffoldWithNavBar> createState() => _ScaffoldWithNavBarState();
}

class _ScaffoldWithNavBarState extends ConsumerState<ScaffoldWithNavBar> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(notificationListProvider.notifier).loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isDoctor = authState.user?.isDoctor ?? false;
    final unreadCount = ref.watch(notificationListProvider).unreadCount;

    final patientItems = [
      _NavItem(Icons.home_outlined, Icons.home, 'Uy', '/'),
      _NavItem(Icons.explore_outlined, Icons.explore, 'Yaqin', '/nearby'),
      _NavItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Qabul', '/appointments'),
      _NavItem(Icons.chat_outlined, Icons.chat, 'Chat', '/chat'),
      _NavItem(Icons.person_outlined, Icons.person, 'Profil', '/profile'),
    ];

    final doctorItems = [
      _NavItem(Icons.dashboard_outlined, Icons.dashboard, 'Boshqaruv', '/dashboard'),
      _NavItem(Icons.calendar_month_outlined, Icons.calendar_month, 'Qabullar', '/appointments'),
      _NavItem(Icons.chat_outlined, Icons.chat, 'Chat', '/chat'),
      _NavItem(Icons.notifications_outlined, Icons.notifications, 'Bildirishnomalar', '/notifications'),
      _NavItem(Icons.person_outlined, Icons.person, 'Profil', '/profile'),
    ];

    final items = isDoctor ? doctorItems : patientItems;
    final currentIndex = _calculateIndex(items, widget.location);

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        selectedItemColor: const Color(AppColors.bottomNavActive),
        unselectedItemColor: const Color(AppColors.bottomNavInactive),
        onTap: (index) {
          final path = items[index].path;
          if (widget.location != path) {
            context.go(path);
          }
        },
        items: items.map((item) {
          final isNotif = item.label == 'Bildirishnomalar';
          final showBadge = isNotif && unreadCount > 0;
          return BottomNavigationBarItem(
            icon: showBadge
                ? Badge(label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()), child: Icon(item.icon))
                : Icon(item.icon),
            activeIcon: showBadge
                ? Badge(label: Text(unreadCount > 99 ? '99+' : unreadCount.toString()), child: Icon(item.activeIcon))
                : Icon(item.activeIcon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }

  int _calculateIndex(List<_NavItem> items, String location) {
    for (int i = 0; i < items.length; i++) {
      final path = items[i].path;
      if (location == path || location.startsWith('$path/') || location.startsWith('$path?')) {
        return i;
      }
    }
    return 0;
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  const _NavItem(this.icon, this.activeIcon, this.label, this.path);
}
