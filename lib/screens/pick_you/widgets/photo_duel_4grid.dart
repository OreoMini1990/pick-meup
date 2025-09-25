import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/duel_models.dart';
import '../../../theme/app_theme.dart';
import '../../../core/data/dummy_data.dart';
import '../../../core/providers/selected_photo_provider.dart';
import '../../../core/models/photo_model.dart';
import '../../../core/models/selected_photo_model.dart';
import '../../../core/services/firebase_photo_service.dart';

typedef OnChosen = Future<void> Function(DuelResult result);

class PhotoDuel4Grid extends ConsumerStatefulWidget {
  final DuelPair pair;
  final OnChosen onChosen;
  final VoidCallback onOpenProfile;
  
  const PhotoDuel4Grid({
    super.key,
    required this.pair,
    required this.onChosen,
    required this.onOpenProfile,
  });

  @override
  ConsumerState<PhotoDuel4Grid> createState() => _PhotoDuel4GridState();
}

class _PhotoDuel4GridState extends ConsumerState<PhotoDuel4Grid> with TickerProviderStateMixin {
  DuelResult? _selected;
  bool _showRatio = false;
  late final AnimationController _burstController;
  late final AnimationController _scaleController;
  late final AnimationController _pulseController;
  

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    
    // 펄스 애니메이션 시작
    _pulseController.repeat(reverse: true);
  }


  @override
  void dispose() {
    _burstController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pick(DuelResult result) async {
    if (_selected != null) return;
    
    // 햅틱 피드백
    HapticFeedback.lightImpact();
    
    setState(() {
      _selected = result;
    });
    
    // 애니메이션 시작
    _burstController.forward(from: 0);
    _scaleController.forward();
    
    // 선택한 사진을 selectedPhotoProvider에 추가
    if (mounted) {
      final photoUrl = await _getSelectedPhotoUrl(result);
      ref.read(selectedPhotoProvider.notifier).addSelectedPhoto(
        SelectedPhoto(
          photoId: 'photo_${DateTime.now().millisecondsSinceEpoch}',
          photoUrl: photoUrl,
          userId: widget.pair.targetUserId,
          nickname: widget.pair.nickname,
          selectedAt: DateTime.now(),
        ),
      );
    }
    
    // 선택률 표시 지연
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _showRatio = true);
    }
    
    // 바로 다음 프로필로 넘어가기
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      await widget.onChosen(result);
    }
  }


  Future<String> _getSelectedPhotoUrl(DuelResult result) async {
    // Firebase에서 해당 사용자의 4장 사진 가져오기
    final userPhotos = await FirebasePhotoService.getUserPhotos(widget.pair.targetUserId);
    
    // 4장이 부족한 경우 기본 사진으로 채움
    List<PhotoModel> photos = List.from(userPhotos);
    while (photos.length < 4) {
      photos.add(PhotoModel(
        photoId: 'default_${photos.length}',
        userId: widget.pair.targetUserId,
        url: widget.pair.a.url,
        thumbUrl: widget.pair.a.url,
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: widget.pair.a.chosen,
        exposureCount: widget.pair.a.exposure,
      ));
    }
    
    switch (result) {
      case DuelResult.a:
        return photos[0].url;
      case DuelResult.b:
        return photos[1].url;
      case DuelResult.c:
        return photos[2].url;
      case DuelResult.d:
        return photos[3].url;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 
                         MediaQuery.of(context).padding.top - 
                         MediaQuery.of(context).padding.bottom - 
                         100, // 네비게이션바 공간 확보
            ),
            child: Column(
              children: [
                const SizedBox(height: 12),
                
                // 상단 사용자 정보
                _buildUserHeader(),
                
                const SizedBox(height: 8),
                
                // 4장 사진 그리드
                Container(
                  height: 400, // 고정 높이로 설정
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: _buildPhotoGrid(),
                ),
                
                const SizedBox(height: 8),
                
                // 하단 액션 버튼들
                _buildActionButtons(),
                
                const SizedBox(height: 20), // 네비게이션바를 위한 여백
              ],
            ),
          ),
        ),
        
        // 하트 버스트 애니메이션 (화면 중앙)
        if (_selected != null)
          Positioned.fill(
            child: _HeartBurst(controller: _burstController),
          ),
      ],
    );
  }

  Widget _buildUserHeader() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 프로필 썸네일 (인스타그램 스타일)
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.brandPink,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: 'https://picsum.photos/100/100?random=${widget.pair.targetUserId}',
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppTheme.brandGray,
                  child: Center(
                    child: Text(
                      widget.pair.nickname.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppTheme.brandGray,
                  child: Center(
                    child: Text(
                      widget.pair.nickname.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 사용자 정보 (인스타그램 스타일)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.pair.nickname,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '25세 • 180cm',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // 신고하기 버튼 (사이렌 모양)
          GestureDetector(
            onTap: () => _showReportDialog(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.report,
                color: Colors.red,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    return FutureBuilder<List<PhotoModel>>(
      future: FirebasePhotoService.getUserPhotos(widget.pair.targetUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        
        List<PhotoModel> userPhotos = snapshot.data ?? [];
        
        // 4장이 부족한 경우 기본 사진으로 채움
        while (userPhotos.length < 4) {
          userPhotos.add(PhotoModel(
            photoId: 'default_${userPhotos.length}',
            userId: widget.pair.targetUserId,
            url: widget.pair.a.url,
            thumbUrl: widget.pair.a.url,
            createdAt: DateTime.now(),
            status: 'approved',
            chosenCount: widget.pair.a.chosen,
            exposureCount: widget.pair.a.exposure,
          ));
        }
        
        return Column(
      children: [
        // 상단 2장
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildPhotoCard(
                  DuelPhoto(
                    photoId: userPhotos[0].photoId,
                    url: userPhotos[0].url,
                    exposure: userPhotos[0].exposureCount,
                    chosen: userPhotos[0].chosenCount,
                  ),
                  'A',
                  DuelResult.a,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildPhotoCard(
                  DuelPhoto(
                    photoId: userPhotos[1].photoId,
                    url: userPhotos[1].url,
                    exposure: userPhotos[1].exposureCount,
                    chosen: userPhotos[1].chosenCount,
                  ),
                  'B',
                  DuelResult.b,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 4),
        
        // 하단 2장
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: _buildPhotoCard(
                  DuelPhoto(
                    photoId: userPhotos[2].photoId,
                    url: userPhotos[2].url,
                    exposure: userPhotos[2].exposureCount,
                    chosen: userPhotos[2].chosenCount,
                  ),
                  'C',
                  DuelResult.c,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: _buildPhotoCard(
                  DuelPhoto(
                    photoId: userPhotos[3].photoId,
                    url: userPhotos[3].url,
                    exposure: userPhotos[3].exposureCount,
                    chosen: userPhotos[3].chosenCount,
                  ),
                  'D',
                  DuelResult.d,
                ),
              ),
            ],
          ),
        ),
      ],
    );
      },
    );
  }

  Widget _buildPhotoCard(DuelPhoto photo, String label, DuelResult result) {
    final isSelected = _selected == result;
    final isDimmed = _selected != null && _selected != result;
    
    return GestureDetector(
      onTap: () => _pick(result),
      onLongPress: () {
        // 이미지 확대 보기
        showDialog(
          context: context,
          builder: (_) => Dialog(
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: Colors.black,
            child: InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: photo.url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => Container(
                    color: AppTheme.brandGray,
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.brandPink,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: AppTheme.brandPink.withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 사진
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: CachedNetworkImage(
                  imageUrl: photo.url,
                  fit: BoxFit.cover,
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
                )
                    .animate(target: isSelected ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 300.ms,
                    ),
              ),
            ),

            // 선택 전 힌트 그라디언트
            if (!_showRatio)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: isDimmed ? 0.3 : 0.2,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.1),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 라벨 오버레이
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected 
                      ? AppTheme.brandPink 
                      : Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '사진 $label',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // 선택률 표시
            if (_showRatio && isSelected)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: AnimatedOpacity(
                  opacity: _showRatio ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppTheme.brandPink,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      '${(photo.ratio * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            // 선택 시 상대 카드 dim 처리
            if (isDimmed)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

            // 선택 표시 오버레이
            if (isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.brandPink,
                      width: 3,
                    ),
                  ),
                ),
              ),

            // 펄스 애니메이션 (선택 전에만)
            if (_selected == null)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.brandPink.withOpacity(0.3 * (1 - _pulseController.value)),
                            width: 2,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 안내 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '4장의 사진 중 더 잘 나온 사진을 선택해주세요',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 액션 버튼들 (선택 전에만 표시)
          if (_selected == null) ...[
            Row(
              children: [
                
                Expanded(
                  child: _buildActionButton(
                    '프로필 열기',
                    Icons.info_outline,
                    widget.onOpenProfile,
                    isSecondary: false,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    IconData icon,
    VoidCallback onTap, {
    required bool isSecondary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          gradient: isSecondary
              ? LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [
                    AppTheme.brandPink,
                    AppTheme.brandPink.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isSecondary 
                  ? Colors.black.withOpacity(0.1)
                  : AppTheme.brandPink.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSecondary ? AppTheme.brandDark : Colors.white,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSecondary ? AppTheme.brandDark : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          '신고하기',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.pair.nickname}님을 신고하시겠습니까?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            const Text(
              '신고 사유를 선택해주세요:',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            _buildReportOption('부적절한 사진', 'inappropriate_photo'),
            _buildReportOption('스팸 또는 광고', 'spam'),
            _buildReportOption('사기 또는 허위 정보', 'fraud'),
            _buildReportOption('괴롭힘 또는 위협', 'harassment'),
            _buildReportOption('기타', 'other'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              '취소',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${widget.pair.nickname}님을 신고했습니다. 검토 후 조치하겠습니다.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '신고하기',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportOption(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Radio<String>(
            value: value,
            groupValue: null, // 실제로는 상태 관리 필요
            onChanged: (value) {
              // 신고 사유 선택 로직
            },
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _HeartBurst extends StatelessWidget {
  final AnimationController controller;
  
  const _HeartBurst({required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          final t = controller.value;
          return Opacity(
            opacity: (1.0 - t).clamp(0, 1),
            child: Transform.scale(
              scale: 1 + t * 0.8,
              child: Icon(
                Icons.favorite,
                color: AppTheme.brandPink.withOpacity(1.0 - t),
                size: 100,
              ),
            ),
          );
        },
      ),
    );
  }

}
