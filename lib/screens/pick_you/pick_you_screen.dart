import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import 'duel_controller.dart';
import 'widgets/photo_duel_4grid.dart';

class PickYouScreen extends ConsumerStatefulWidget {
  const PickYouScreen({super.key});

  @override
  ConsumerState<PickYouScreen> createState() => _PickYouScreenState();
}

class _PickYouScreenState extends ConsumerState<PickYouScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(duelControllerProvider);

    return Container(
      color: AppTheme.brandBg,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: () {
          if (state.loading) return const _Skeleton();
          if (state.error) {
            return _Error(
              onRetry: () => ref.read(duelControllerProvider.notifier).loadNext(),
              errorMessage: state.errorMessage,
            );
          }
          if (state.pair == null) {
            return _Empty(
              onRefresh: () => ref.read(duelControllerProvider.notifier).loadNext(),
            );
          }
          return PhotoDuel4Grid(
            key: ValueKey(state.pair!.targetUserId),
            pair: state.pair!,
            onChosen: (result) async {
              if (mounted) {
                await ref.read(duelControllerProvider.notifier).choose(result);
                // 1.2초 후 자동 다음 로드
                await Future.delayed(const Duration(milliseconds: 1200));
                if (mounted) {
                  ref.read(duelControllerProvider.notifier).loadNext();
                }
              }
            },
            onOpenProfile: () {
              context.go('/profile/${state.pair!.targetUserId}');
            },
          );
        }(),
      ),
    );
  }

}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          // 사용자 헤더 스켈레톤
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.brandGray,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 20),
          
          // 4장 사진 그리드 스켈레톤
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.brandGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.brandGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.brandGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.brandGray,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // 버튼 스켈레톤
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.brandGray,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.brandGray,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Error extends StatelessWidget {
  final VoidCallback onRetry;
  final String? errorMessage;
  
  const _Error({
    required this.onRetry,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.brandPink.withOpacity(0.1),
                    AppTheme.brandPink.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: AppTheme.brandPink.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: AppTheme.brandPink.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '데이터를 불러올 수 없어요',
              style: AppTheme.heading3.copyWith(
                color: AppTheme.brandDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (errorMessage != null) ...[
              Text(
                errorMessage!,
                style: AppTheme.body2.copyWith(
                  color: AppTheme.brandDark.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.brandPink, AppTheme.brandPink.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.brandPink.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRetry,
                  borderRadius: BorderRadius.circular(25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.refresh_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '다시 시도',
                        style: AppTheme.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
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

class _Empty extends StatelessWidget {
  final VoidCallback onRefresh;
  
  const _Empty({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.brandPink.withOpacity(0.1),
                    AppTheme.brandPink.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(
                  color: AppTheme.brandPink.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                Icons.photo_library_outlined,
                size: 40,
                color: AppTheme.brandPink.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '지금은 보여줄 사용자가 없어요',
              style: AppTheme.heading3.copyWith(
                color: AppTheme.brandDark,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '잠시 후 다시 확인해보세요',
              style: AppTheme.body2.copyWith(
                color: AppTheme.brandDark.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white,
                    Colors.grey[50]!,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(
                  color: AppTheme.brandPink.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRefresh,
                  borderRadius: BorderRadius.circular(25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh_rounded,
                        color: AppTheme.brandPink,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '새로고침',
                        style: AppTheme.button.copyWith(
                          color: AppTheme.brandPink,
                        ),
                      ),
                    ],
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