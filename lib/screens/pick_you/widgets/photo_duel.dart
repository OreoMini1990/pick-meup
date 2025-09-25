import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/duel_models.dart';
import '../../../theme/app_theme.dart';

typedef OnChosen = Future<void> Function(DuelResult result);

class PhotoDuel extends StatefulWidget {
  final DuelPair pair;
  final OnChosen onChosen;
  final VoidCallback onOpenProfile;
  
  const PhotoDuel({
    super.key,
    required this.pair,
    required this.onChosen,
    required this.onOpenProfile,
  });

  @override
  State<PhotoDuel> createState() => _PhotoDuelState();
}

class _PhotoDuelState extends State<PhotoDuel> with TickerProviderStateMixin {
  DuelResult? _selected;
  bool _showRatio = false;
  late final AnimationController _burstController;
  late final AnimationController _scaleController;
  
  // 스와이프 제스처 관련
  double _dragOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _burstController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  Future<void> _pick(DuelResult result) async {
    if (_selected != null) return;
    
    // 햅틱 피드백
    HapticFeedback.lightImpact();
    
    setState(() {
      _selected = result;
      _isDragging = false;
      _dragOffset = 0.0;
    });
    
    // 애니메이션 시작
    _burstController.forward(from: 0);
    _scaleController.forward();
    
    // 선택률 표시 지연
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) {
      setState(() => _showRatio = true);
    }
    
    // 선택 로직 실행
    await widget.onChosen(result);
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_selected != null) return;
    
    setState(() {
      _dragOffset += details.delta.dx;
      _isDragging = true;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_selected != null) return;
    
    const double threshold = 50.0;
    
    if (_dragOffset > threshold) {
      _pick(DuelResult.a);
    } else if (_dragOffset < -threshold) {
      _pick(DuelResult.b);
    } else {
      setState(() {
        _dragOffset = 0.0;
        _isDragging = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pair = widget.pair;
    final a = pair.a;
    final b = pair.b;

    // 선택률 계산 (낙관적 UI)
    final totalA = a.exposure + (_selected != null ? 1 : 0);
    final totalB = b.exposure + (_selected != null ? 1 : 0);
    final chosenA = a.chosen + (_selected == DuelResult.a ? 1 : 0);
    final chosenB = b.chosen + (_selected == DuelResult.b ? 1 : 0);
    final ratioA = totalA == 0 ? 0.0 : chosenA / totalA;
    final ratioB = totalB == 0 ? 0.0 : chosenB / totalB;

    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        final safeH = max(420.0, h - 120);

        return Column(
          children: [
            const SizedBox(height: 8),
            _NamePill(name: pair.nickname),
            const SizedBox(height: 16),

            // 두 장을 한 화면에 크게 배치
            SizedBox(
              height: safeH,
              child: GestureDetector(
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: Row(
                  children: [
                    Expanded(
                      child: _PhotoCard(
                        url: a.url,
                        photoId: a.photoId,
                        highlight: _selected == DuelResult.a,
                        dim: _selected != null && _selected != DuelResult.a,
                        showRatio: _showRatio,
                        ratioText: '${(ratioA * 100).round()}%',
                        onTap: () => _pick(DuelResult.a),
                        dragOffset: _dragOffset,
                        isDragging: _isDragging,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PhotoCard(
                        url: b.url,
                        photoId: b.photoId,
                        highlight: _selected == DuelResult.b,
                        dim: _selected != null && _selected != DuelResult.b,
                        showRatio: _showRatio,
                        ratioText: '${(ratioB * 100).round()}%',
                        onTap: () => _pick(DuelResult.b),
                        dragOffset: -_dragOffset,
                        isDragging: _isDragging,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 액션 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onOpenProfile,
                    icon: const Icon(Icons.info_outline, size: 20),
                    label: const Text('프로필 열기'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _selected != null ? null : () {
                      HapticFeedback.selectionClick();
                      // TODO: 좋아요 기능 구현
                    },
                    icon: const Icon(Icons.favorite_border, size: 20),
                    label: const Text('좋아요'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),

            // 하트 버스트 애니메이션
            if (_selected != null)
              SizedBox(
                height: 0,
                child: _HeartBurst(controller: _burstController),
              ),
          ],
        );
      },
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String url;
  final String photoId;
  final bool highlight;
  final bool dim;
  final bool showRatio;
  final String ratioText;
  final VoidCallback onTap;
  final double dragOffset;
  final bool isDragging;

  const _PhotoCard({
    required this.url,
    required this.photoId,
    required this.highlight,
    required this.dim,
    required this.showRatio,
    required this.ratioText,
    required this.onTap,
    this.dragOffset = 0.0,
    this.isDragging = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                  imageUrl: url,
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
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translate(dragOffset * 0.1)
          ..scale(isDragging ? 0.98 : 1.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (highlight)
              BoxShadow(
                color: AppTheme.brandPink.withOpacity(0.3),
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
                aspectRatio: 10 / 16,
                child: CachedNetworkImage(
                  imageUrl: url,
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
                      size: 48,
                    ),
                  ),
                )
                    .animate(target: highlight ? 1 : 0)
                    .scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.02, 1.02),
                      duration: 200.ms,
                    ),
              ),
            ),

            // 선택 전 힌트 그라디언트
            if (!showRatio)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: dim ? 0.2 : 0.3,
                    duration: const Duration(milliseconds: 200),
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

            // 선택률 표시
            if (showRatio)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: AnimatedOpacity(
                  opacity: showRatio ? 1 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: highlight ? AppTheme.brandPink : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        ratioText,
                        style: AppTheme.button.copyWith(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // 선택 시 상대 카드 dim 처리
            if (dim)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),

            // 선택 표시 오버레이
            if (highlight)
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
          ],
        ),
      ),
    );
  }
}

class _NamePill extends StatelessWidget {
  final String name;
  
  const _NamePill({required this.name});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.brandWhite,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        name,
        style: AppTheme.heading3.copyWith(
          color: AppTheme.brandDark,
        ),
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
              scale: 1 + t * 0.5,
              child: Icon(
                Icons.favorite,
                color: AppTheme.brandPink.withOpacity(1.0 - t),
                size: 80,
              ),
            ),
          );
        },
      ),
    );
  }
}
