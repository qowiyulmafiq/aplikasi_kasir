import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/system_settings_provider.dart';
import '../widgets/custom_bottom_nav.dart';

class MainLayout extends ConsumerWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final cashierMode = ref.watch(systemSettingsNotifierProvider).cashierMode;
    int currentIndex = 0;

    if (location.startsWith('/history')) {
      currentIndex = 1;
    } else if (location.startsWith('/inventory')) {
      currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      currentIndex = 3;
    }

    // Cashier Mode hides the nav only on /pos; management tabs keep it so
    // there is always a visible way back.
    final hideNav = cashierMode && location.startsWith('/pos');

    return Scaffold(
      body: child,
      bottomNavigationBar: hideNav
          ? null
          : CustomBottomNav(
              currentIndex: currentIndex,
              onTap: (index) {
                if (index == 0) {
                  context.go('/pos');
                } else if (index == 1) {
                  context.go('/history');
                } else if (index == 2) {
                  context.go('/inventory');
                } else if (index == 3) {
                  context.go('/profile');
                }
              },
            ),
    );
  }
}
