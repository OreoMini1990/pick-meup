import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../core/data/dummy_data.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;
  
  const ProfileScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    // 더미 데이터에서 사용자 찾기
    final user = DummyData.dummyUsers.firstWhere(
      (u) => u.uid == userId,
      orElse: () => DummyData.dummyUsers.first,
    );
    
    final photos = DummyData.myDummyPhotos;

    return Scaffold(
      backgroundColor: AppTheme.brandBg,
      appBar: AppBar(
        title: Text(
          user.nickname,
          style: AppTheme.heading3.copyWith(
            color: AppTheme.brandDark,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppTheme.brandWhite,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/pick-me');
            }
          },
          icon: const Icon(
            Icons.arrow_back_ios_rounded,
            color: AppTheme.brandDark,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: 좋아요 기능
            },
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: AppTheme.brandPink,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // 프로필 헤더
            _ProfileHeader(user: user),
            
            const SizedBox(height: 24),
            
            // 사진 그리드
            _PhotoGrid(photos: photos),
            
            const SizedBox(height: 24),
            
            // 액션 버튼들
            _ActionButtons(userId: userId),
            
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final user;
  
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.brandWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 프로필 이미지
          CircleAvatar(
            radius: 50,
            backgroundColor: AppTheme.brandPink.withOpacity(0.1),
            child: Text(
              user.nickname.substring(0, 1).toUpperCase(),
              style: AppTheme.heading1.copyWith(
                color: AppTheme.brandPink,
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 이름
          Text(
            user.nickname,
            style: AppTheme.heading2.copyWith(
              color: AppTheme.brandDark,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 나이
          if (user.age != null)
            Text(
              '${user.age}세',
              style: AppTheme.body1.copyWith(
                color: AppTheme.brandDark.withOpacity(0.7),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // 직업과 지역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (user.job != null) ...[
                _InfoChip(icon: Icons.work_outline, text: user.job!),
                const SizedBox(width: 12),
              ],
              if (user.regionCity != null) ...[
                _InfoChip(
                  icon: Icons.location_on_outlined,
                  text: '${user.regionCity}${user.regionDistrict != null ? ', ${user.regionDistrict}' : ''}',
                ),
              ],
            ],
          ),
          
          if (user.bio != null) ...[
            const SizedBox(height: 16),
            Text(
              user.bio!,
              style: AppTheme.body2,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  
  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.brandPink.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.brandPink,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: AppTheme.caption.copyWith(
              color: AppTheme.brandPink,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoGrid extends StatelessWidget {
  final List photos;
  
  const _PhotoGrid({required this.photos});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사진',
            style: AppTheme.heading3.copyWith(
              color: AppTheme.brandDark,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.8,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final photo = photos[index];
              return _PhotoCard(
                photoId: photo.photoId,
                url: photo.url,
                ratio: photo.ratioPercentage,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String photoId;
  final String url;
  final double ratio;
  
  const _PhotoCard({
    required this.photoId,
    required this.url,
    required this.ratio,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // 이미지 확대 보기
        showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: Colors.black,
            child: InteractiveViewer(
              child: Hero(
                tag: photoId,
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        );
      },
      child: Hero(
        tag: photoId,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  placeholder: (context, url) => Container(
                    color: AppTheme.brandGray,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.brandPink,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: AppTheme.brandGray,
                    child: const Icon(
                      Icons.error_outline,
                      color: Colors.grey,
                      size: 32,
                    ),
                  ),
                ),
                
                // 선택률 오버레이
                Positioned(
                  bottom: 8,
                  left: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${ratio.toStringAsFixed(1)}%',
                      style: AppTheme.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final String userId;
  
  const _ActionButtons({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: 메시지 기능
              },
              icon: const Icon(Icons.message_outlined),
              label: const Text('메시지'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: FilledButton.icon(
              onPressed: () {
                // TODO: 좋아요 기능
              },
              icon: const Icon(Icons.favorite_border),
              label: const Text('좋아요'),
            ),
          ),
        ],
      ),
    );
  }
}
