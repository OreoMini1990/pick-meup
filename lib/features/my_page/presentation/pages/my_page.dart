import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_theme.dart';

class MyPage extends ConsumerWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Container(
      color: AppTheme.brandBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            
            // 주요 기능 섹션
            _buildMenuItem(
              context: context,
              icon: Icons.favorite,
              iconColor: AppTheme.brandPink,
              title: '스토어',
              onTap: () {
                // 스토어 기능 - 나중에 구현
              },
            ),
            
            _buildMenuItem(
              context: context,
              icon: Icons.group,
              iconColor: AppTheme.brandPink,
              title: '친구 초대하기',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppTheme.brandGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '하트 지급',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.brandWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                // 친구 초대 기능 - 나중에 구현
              },
            ),
            
            _buildMenuItem(
              context: context,
              icon: Icons.card_giftcard,
              iconColor: AppTheme.brandPink,
              title: '친구 초대하기 상품권 리워드 +',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '상품권 + 하트 지급',
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.brandWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                // 상품권 리워드 기능 - 나중에 구현
              },
            ),
            
            const SizedBox(height: 32),
            
            // 서비스 더보기 섹션 헤더
            Text(
              '서비스 더보기',
              style: AppTheme.body2.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 서비스 더보기 메뉴들
            _buildMenuItem(
              context: context,
              icon: Icons.notifications_outlined,
              iconColor: AppTheme.brandDark.withOpacity(0.6),
              title: '공지사항',
              onTap: () {
                // 공지사항 기능 - 나중에 구현
              },
            ),
            
            _buildMenuItem(
              context: context,
              icon: Icons.headset_mic_outlined,
              iconColor: AppTheme.brandDark.withOpacity(0.6),
              title: '고객센터',
              onTap: () {
                // 고객센터 기능 - 나중에 구현
              },
            ),
            
            _buildMenuItem(
              context: context,
              icon: Icons.settings_outlined,
              iconColor: AppTheme.brandDark.withOpacity(0.6),
              title: '설정',
              onTap: () {
                // 설정 기능 - 나중에 구현
              },
            ),
            
            _buildMenuItem(
              context: context,
              icon: Icons.person_off_outlined,
              iconColor: Colors.blue,
              title: '아는 사람 피하기',
              titleColor: Colors.blue,
              onTap: () {
                // 아는 사람 피하기 기능 - 나중에 구현
              },
            ),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    Color titleColor = Colors.black,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.brandWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.brandDark.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.body1.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: trailing ?? Icon(
          Icons.chevron_right,
          color: AppTheme.brandDark.withOpacity(0.3),
          size: 20,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
