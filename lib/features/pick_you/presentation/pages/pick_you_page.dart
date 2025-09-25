import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/models/photo_duel_model.dart';
import '../../../../core/models/photo_model.dart';
import '../../../../core/data/dummy_data.dart';
import '../../../main/presentation/pages/main_page.dart';

class PickYouPage extends ConsumerStatefulWidget {
  const PickYouPage({super.key});

  @override
  ConsumerState<PickYouPage> createState() => _PickYouPageState();
}

class _PickYouPageState extends ConsumerState<PickYouPage> with TickerProviderStateMixin {
  String? selectedPhotoId;
  bool hasSelected = false;
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dummyUsers = DummyData.dummyUsers;
    final dummyPhotos = DummyData.dummyPhotos;

    final random = DateTime.now().millisecondsSinceEpoch % dummyUsers.length;
    final targetUser = dummyUsers[random];

    // 같은 사람의 서로 다른 사진 2장 선택
    final photoA = dummyPhotos[random % dummyPhotos.length];
    final photoB = dummyPhotos[(random + 2) % dummyPhotos.length];

    final duel = PhotoDuel(
      targetUser: targetUser,
      photoA: photoA,
      photoB: photoB,
    );

    return MainPage(
      currentRoute: '/pick-you',
      child: _buildSlideDuelCard(context, ref, duel, true),
    );
  }

  void _onPhotoSelected(String photoId) {
    setState(() {
      selectedPhotoId = photoId;
      hasSelected = true;
    });
    _animationController.forward();
  }

  void _resetSelection() {
    setState(() {
      selectedPhotoId = null;
      hasSelected = false;
    });
    _animationController.reverse();
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  Widget _buildSlideDuelCard(
    BuildContext context,
    WidgetRef ref,
    PhotoDuel duel,
    bool isProfileCompleted,
  ) {
    return Stack(
      children: [
        // PageView로 슬라이드 구현
        PageView(
          controller: _pageController,
          onPageChanged: _onPageChanged,
          children: [
            // Photo A
            _buildFullScreenPhoto(
              context,
              duel.photoA,
              'A',
              () => _onPhotoSelected(duel.photoA.photoId),
              duel.targetUser,
            ),
            // Photo B
            _buildFullScreenPhoto(
              context,
              duel.photoB,
              'B',
              () => _onPhotoSelected(duel.photoB.photoId),
              duel.targetUser,
            ),
          ],
        ),

        // 상단 인디케이터
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPageIndicator(0),
              const SizedBox(width: 8),
              _buildPageIndicator(1),
            ],
          ),
        ),

        // 하단 액션 버튼들
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: _buildBottomActions(context, ref, duel, isProfileCompleted),
        ),

        // 선택 결과 오버레이
        if (hasSelected)
          FadeTransition(
            opacity: _fadeAnimation,
            child: _buildSelectionOverlay(context, duel),
          ),
      ],
    );
  }

  Widget _buildFullScreenPhoto(
    BuildContext context,
    PhotoModel photo,
    String label,
    VoidCallback onTap,
    targetUser,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // 풀스크린 이미지
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: photo.url,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[200],
                child: const Icon(Icons.error),
              ),
            ),
          ),

          // 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.1),
                  Colors.black.withOpacity(0.4),
                ],
              ),
            ),
          ),

          // 상단 정보
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Column(
              children: [
                // 닉네임
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    targetUser.nickname,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // 핵심 메시지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withOpacity(0.9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '더 잘 나온 사진을 선택해주세요',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // 하단 라벨
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: _currentPage == (label == 'A' ? 0 : 1)
                      ? const Color(0xFFE91E63)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Text(
                '사진 $label',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _currentPage == (label == 'A' ? 0 : 1)
                      ? const Color(0xFFE91E63)
                      : Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index
            ? Colors.white
            : Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    PhotoDuel duel,
    bool isProfileCompleted,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // A, B 선택 버튼들 (선택 전에만 표시)
        if (!hasSelected) ...[
          Row(
            children: [
              Expanded(
                child: _buildSelectionButton(
                  context,
                  'A',
                  () => _onPhotoSelected(duel.photoA.photoId),
                  isSelected: selectedPhotoId == duel.photoA.photoId,
                  hasSelected: hasSelected,
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSelectionButton(
                  context,
                  'B',
                  () => _onPhotoSelected(duel.photoB.photoId),
                  isSelected: selectedPhotoId == duel.photoB.photoId,
                  hasSelected: hasSelected,
                  isPrimary: false,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],

        // 하단 액션 버튼들
        Row(
          children: [
            if (hasSelected) ...[
              Expanded(
                child: _buildActionButton(
                  context,
                  '다시 선택',
                  Icons.refresh,
                  () => _resetSelection(),
                  isSecondary: true,
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: _buildActionButton(
                context,
                '다음',
                Icons.skip_next,
                () {
                  _resetSelection();
                  // 다음 사진으로 이동
                },
                isSecondary: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                '좋아요',
                Icons.favorite,
                isProfileCompleted
                    ? () => _sendLike(context, ref, duel.targetUser.uid)
                    : () => _showProfileRequiredDialog(context),
                isSecondary: false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionOverlay(BuildContext context, PhotoDuel duel) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.8),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 선택된 사진 표시
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CachedNetworkImage(
                      imageUrl: selectedPhotoId == duel.photoA.photoId
                          ? duel.photoA.url
                          : duel.photoB.url,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // 선택 결과
                Text(
                  '사진 ${selectedPhotoId == duel.photoA.photoId ? 'A' : 'B'} 선택!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '더 잘 나온 사진을 선택하셨습니다',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 20),

                // 선택률 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${selectedPhotoId == duel.photoA.photoId ? duel.photoA.ratioPercentage.toStringAsFixed(1) : duel.photoB.ratioPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '선택률',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 액션 버튼들
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        context,
                        '다시 선택',
                        Icons.refresh,
                        () => _resetSelection(),
                        isSecondary: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildActionButton(
                        context,
                        '다음 사진',
                        Icons.skip_next,
                        () {
                          _resetSelection();
                          // 다음 사진으로 이동
                        },
                        isSecondary: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionButton(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    required bool isSelected,
    required bool hasSelected,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFE91E63)
              : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFE91E63)
                : Colors.grey.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '사진 $label 선택',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String text,
    IconData icon,
    VoidCallback onTap, {
    required bool isSecondary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: isSecondary
              ? Colors.white.withOpacity(0.9)
              : const Color(0xFFE91E63),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSecondary ? Colors.black87 : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSecondary ? Colors.black87 : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendLike(BuildContext context, WidgetRef ref, String targetUserId) {
    // 테스트 모드에서는 간단한 스낵바만 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('좋아요를 보냈습니다!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showProfileRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('프로필 필요'),
        content: const Text(
          '좋아요를 보내려면 프로필을 완성해주세요.',
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
            child: const Text('프로필 완성'),
          ),
        ],
      ),
    );
  }
}