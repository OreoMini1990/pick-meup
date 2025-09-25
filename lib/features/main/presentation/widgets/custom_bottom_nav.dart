import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../theme/app_theme.dart';

class CustomBottomNav extends StatelessWidget {
  final String currentRoute;

  const CustomBottomNav({
    super.key,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.brandWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 50,
            maxHeight: 60,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.photo_camera,
                activeIcon: Icons.photo_camera,
                label: '픽유',
                route: '/pick-you',
                isActive: currentRoute == '/pick-you',
              ),
              _buildNavItem(
                context,
                icon: Icons.favorite_border,
                activeIcon: Icons.favorite,
                label: '픽미',
                route: '/pick-me',
                isActive: currentRoute == '/pick-me',
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '프로필',
                route: '/me',
                isActive: currentRoute == '/me',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return Flexible(
      child: GestureDetector(
        onTap: () => context.go(route),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    colors: [
                      AppTheme.brandPink.withOpacity(0.1),
                      AppTheme.brandPink.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(16),
            border: isActive
                ? Border.all(
                    color: AppTheme.brandPink.withOpacity(0.3),
                    width: 1,
                  )
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? AppTheme.brandPink : AppTheme.brandDark.withOpacity(0.6),
                size: 18,
              ),
              const SizedBox(height: 2),
              Flexible(
                child: Text(
                  label,
                  style: AppTheme.caption.copyWith(
                    color: isActive ? AppTheme.brandPink : AppTheme.brandDark.withOpacity(0.6),
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 9,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
