import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../../screens/main_layout.dart';
import '../../screens/inventory/inventory_screen.dart';
import '../../screens/inventory/inventory_form_screen.dart';
import '../../data/database/app_database.dart';
import '../../screens/pos/pos_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/profile/store_settings_screen.dart';
import '../../screens/profile/system_settings_screen.dart';
import '../../screens/profile/operational_settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/pos',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) {
        return MainLayout(child: child);
      },
      routes: [
        GoRoute(
          path: '/pos',
          builder: (context, state) => const PosScreen(),
        ),
        GoRoute(
          path: '/history',
          builder: (context, state) => const HistoryScreen(),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/inventory/add',
      // _rootNavigatorKey memastikan halaman ini menutupi seluruh layar (termasuk Bottom Nav)
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const InventoryFormScreen(),
    ),
    GoRoute(
      path: '/inventory/edit',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        // Menerima objek BarangData yang dilempar dari layar sebelumnya
        final barang = state.extra as BarangData;
        return InventoryFormScreen(barangToEdit: barang);
      },
    ),
    GoRoute(
      path: '/profile/store-settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const StoreSettingsScreen(),
    ),
    GoRoute(
      path: '/profile/system-settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const SystemSettingsScreen(),
    ),
    GoRoute(
      path: '/profile/operational-settings',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const OperationalSettingsScreen(),
    ),
  ],
);
