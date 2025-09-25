import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../../core/models/photo_model.dart';
import '../../../../core/providers/selected_photo_provider.dart';
import '../../../../core/providers/user_photos_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../core/providers/photo_upload_provider.dart';
import '../../../../core/models/selected_photo_model.dart';

class PickMePage extends ConsumerWidget {
  const PickMePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPhotos = ref.watch(selectedPhotoProvider);
    final currentUser = ref.watch(currentUserProvider);
    final photoUploadState = ref.watch(photoUploadProvider);
    
    // 현재 사용자 ID 가져오기
    final userId = currentUser.when(
      data: (user) => user?.uid ?? 'current_user',
      loading: () => 'current_user',
      error: (_, __) => 'current_user',
    );
    
    // 사용자 사진 가져오기
    final userPhotos = ref.watch(userPhotosProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pick Me'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: userPhotos.when(
        data: (photos) {
          // 사진을 업로드 날짜 순으로 정렬하고 최대 4장만 표시
          final sortedPhotos = List<PhotoModel>.from(photos)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final limitedPhotos = sortedPhotos.take(4).toList(); // 최대 4장만 표시
          
          // 선택률이 가장 높은 사진 찾기
          PhotoModel? highestRatedPhoto;
          if (limitedPhotos.isNotEmpty) {
            highestRatedPhoto = limitedPhotos.reduce((a, b) {
              final aPercentage = _calculatePercentageValue(a);
              final bPercentage = _calculatePercentageValue(b);
              return aPercentage > bPercentage ? a : b;
            });
          }
          
          return SingleChildScrollView(
            child: Column(
              children: [
                // 내가 고른 사진 섹션
                if (selectedPhotos.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '내가 고른 사진',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: selectedPhotos.length,
                            itemBuilder: (context, index) {
                              final photo = selectedPhotos[index];
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                child: GestureDetector(
                                  onTap: () => _showLikeConfirmationDialog(context, photo),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: CachedNetworkImage(
                                      imageUrl: photo.photoUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: CircularProgressIndicator(),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) => Container(
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                
                // 내 사진 반응 섹션
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 섹션 헤더 (제목 + 수정 버튼)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            '내 사진 반응',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // 수정 버튼
                          if (limitedPhotos.isNotEmpty)
                            TextButton.icon(
                              onPressed: () => _showPhotoUploadDialog(context, ref),
                              icon: const Icon(
                                Icons.edit,
                                size: 16,
                              ),
                              label: const Text(
                                '수정',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFFE91E63),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (photoUploadState.isUploading)
                        const Center(
                          child: Column(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('사진을 업로드하고 있습니다...'),
                            ],
                          ),
                        )
                      else if (limitedPhotos.isEmpty)
                        _buildNoPhotosState(context, ref)
                      else
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: limitedPhotos.length,
                          itemBuilder: (context, index) {
                            final photo = limitedPhotos[index];
                            final isHighestRated = photo.photoId == highestRatedPhoto?.photoId;
                            return _buildPhotoCard(context, photo, isHighestRated);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, error.toString()),
      ),
    );
  }

  Widget _buildNoPhotosState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 큰 + 버튼
          GestureDetector(
            onTap: () => _showPhotoUploadDialog(context, ref),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(60),
                border: Border.all(
                  color: const Color(0xFFE91E63),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.add,
                size: 48,
                color: Color(0xFFE91E63),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '아직 업로드된 사진이 없습니다',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            '4장의 사진을 업로드하여\n프로필을 완성해보세요',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => _showPhotoUploadDialog(context, ref),
            icon: const Icon(Icons.add_photo_alternate),
            label: const Text('사진 업로드'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E63),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoCard(BuildContext context, PhotoModel photo, bool isHighestRated) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: photo.url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.error),
              ),
            ),
            
            // 트로피 표시 (선택률이 가장 높은 사진에만)
            if (isHighestRated)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            
            // 통계 정보 오버레이
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(Icons.visibility, photo.exposureCount, '노출'),
                    _buildStatItem(Icons.favorite, photo.chosenCount, '선택'),
                    _buildStatItem(Icons.percent, _calculatePercentage(photo), '%'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, dynamic value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 16,
        ),
        const SizedBox(height: 2),
        Text(
          value.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  String _calculatePercentage(PhotoModel photo) {
    if (photo.exposureCount == 0) return '0';
    final percentage = (photo.chosenCount / photo.exposureCount * 100).round();
    return percentage.toString();
  }

  // 선택률 값을 숫자로 계산하는 헬퍼 메서드 추가
  double _calculatePercentageValue(PhotoModel photo) {
    if (photo.exposureCount == 0) return 0.0;
    return (photo.chosenCount / photo.exposureCount * 100);
  }

  void _showPhotoUploadDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('사진 업로드'),
        content: const Text('갤러리에서 4장의 사진을 선택해주세요.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _uploadPhotos(context, ref);
            },
            child: const Text('선택'),
          ),
        ],
      ),
    );
  }

  void _uploadPhotos(BuildContext context, WidgetRef ref) async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    if (images.length < 4) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('최소 4장의 사진을 선택해주세요.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    // 현재 사용자 ID 가져오기
    final currentUser = ref.read(currentUserProvider);
    final userId = currentUser.when(
      data: (user) => user?.uid ?? 'current_user',
      loading: () => 'current_user',
      error: (_, __) => 'current_user',
    );

    print('사진 업로드 시작 - 사용자 ID: $userId');

    // File 객체로 변환
    final List<File> imageFiles = images.map((xFile) => File(xFile.path)).toList();

    // 사진 업로드
    await ref.read(photoUploadProvider.notifier).uploadPhotos(imageFiles, userId);

    // 업로드 완료 후 상태 확인
    final uploadState = ref.read(photoUploadProvider);
    if (context.mounted) {
      if (uploadState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('업로드 실패: ${uploadState.error}'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (uploadState.uploadedUrls.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${uploadState.uploadedUrls.length}장의 사진이 업로드되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // 사진 목록 새로고침
        print('사진 목록 새로고침 - 사용자 ID: $userId');
        ref.invalidate(userPhotosProvider(userId));
        
        // 추가로 refresh도 호출
        ref.refresh(userPhotosProvider(userId));
      }
    }
  }

  void _showLikeConfirmationDialog(BuildContext context, SelectedPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('좋아요 보내기'),
        content: Text('${photo.nickname}님의 사진에 좋아요를 보내시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // 좋아요 보내기 로직 구현
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('좋아요를 보냈습니다!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('보내기'),
          ),
        ],
      ),
    );
  }
}