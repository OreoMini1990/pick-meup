import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:badges/badges.dart' as badges;
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/like_provider.dart';
import '../../../../core/providers/profile_provider.dart';
import '../../../../core/providers/user_photos_provider.dart';
import '../../../../core/models/user_model.dart';
import '../widgets/custom_bottom_nav.dart';

class MainPage extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const MainPage({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final profile = ref.watch(profileProvider);
    final pendingLikesCount = ref.watch(pendingLikesCountProvider);
    
    // 현재 사용자 ID 가져오기
    final userId = currentUser.when(
      data: (user) => user?.uid ?? 'current_user',
      loading: () => 'current_user',
      error: (_, __) => 'current_user',
    );
    
    // 사용자 사진 가져오기
    final userPhotos = ref.watch(userPhotosProvider(userId));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: currentRoute == '/me' 
          ? const Text(
              '더보기',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E63), Color(0xFF9C27B0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'PickMe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
        actions: [
          // 쪽지함 (인스타그램 스타일)
          pendingLikesCount.when(
            data: (count) => GestureDetector(
              onTap: () => _handleInboxTap(context, ref),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: badges.Badge(
                  badgeContent: count > 0 ? Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ) : null,
                  showBadge: count > 0,
                  child: const Icon(
                    Icons.favorite_outline,
                    color: Colors.black,
                    size: 24,
                  ),
                ),
              ),
            ),
            loading: () => const Icon(Icons.favorite_outline, color: Colors.black),
            error: (_, __) => const Icon(Icons.favorite_outline, color: Colors.black),
          ),
          
          const SizedBox(width: 8),
          
          // 마이프로필 (인스타그램 스타일)
          GestureDetector(
            onTap: () => context.go('/me'),
            child: Container(
              padding: const EdgeInsets.all(8),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: ClipOval(
                  child: userPhotos.when(
                    data: (photos) {
                      // 사용자가 업로드한 사진이 있으면 첫 번째 사진 사용
                      if (photos.isNotEmpty) {
                        return CachedNetworkImage(
                          imageUrl: photos.first.url,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Text(
                            (profile?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          errorWidget: (context, url, error) => Text(
                            (profile?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                      // 업로드한 사진이 없으면 기본 이미지 사용
                      return CachedNetworkImage(
                        imageUrl: UserModel.defaultThumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Text(
                          (profile?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        errorWidget: (context, url, error) => Text(
                          (profile?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(strokeWidth: 2),
                    error: (_, __) => Text(
                      (profile?.displayName ?? 'U').substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
        ],
      ),
      body: child,
      bottomNavigationBar: CustomBottomNav(currentRoute: currentRoute),
    );
  }


  void _handleInboxTap(BuildContext context, WidgetRef ref) {
    final isProfileCompleted = ref.read(isProfileCompletedProvider);
    
    if (!isProfileCompleted) {
      _showProfileRequiredDialog(context);
    } else {
      context.go('/inbox');
    }
  }

  void _showProfileRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 필요'),
        content: const Text(
          '좋아요를 보려면 먼저 프로필을 완성해주세요.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/profile-setup');
            },
            child: const Text('지금 완성하기'),
          ),
        ],
      ),
    );
  }
}
