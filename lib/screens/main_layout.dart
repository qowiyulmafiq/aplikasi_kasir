import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/custom_bottom_nav.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    int currentIndex = 0;

    if (location.startsWith('/history')) {
      currentIndex = 1;
    } else if (location.startsWith('/inventory')) {
      currentIndex = 2;
    } else if (location.startsWith('/profile')) {
      currentIndex = 3;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: CustomBottomNav(
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
