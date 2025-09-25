import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/google_auth_service.dart';
import '../../../../core/providers/profile_provider.dart';

class NicknameSetupDialog extends ConsumerStatefulWidget {
  final String userEmail;
  final String displayName;
  final String photoURL;

  const NicknameSetupDialog({
    super.key,
    required this.userEmail,
    required this.displayName,
    required this.photoURL,
  });

  @override
  ConsumerState<NicknameSetupDialog> createState() => _NicknameSetupDialogState();
}

class _NicknameSetupDialogState extends ConsumerState<NicknameSetupDialog> {
  final _nicknameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nicknameController.text = widget.displayName;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nicknameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_ageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('나이를 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 18 || age > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 나이를 입력해주세요. (18-100세)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Provider에 프로필 정보 저장
      ref.read(profileProvider.notifier).setProfile(
        uid: GoogleAuthService.getCurrentUser()?.uid ?? '',
        email: widget.userEmail,
        displayName: _nicknameController.text.trim(),
        age: age,
        height: 0, // 기본값
        bio: '',
        location: '',
        photoURL: widget.photoURL,
      );

      // Firebase에 사용자 프로필 업데이트 시도 (실패해도 계속 진행)
      try {
        await GoogleAuthService.updateUserProfile(
          uid: GoogleAuthService.getCurrentUser()?.uid ?? '',
          displayName: _nicknameController.text.trim(),
          age: age,
          height: 0,
          bio: '',
          location: '',
        );
      } catch (e) {
        print('Firebase 프로필 업데이트 실패: $e');
        // Firebase 실패해도 로컬에 저장되었으므로 계속 진행
      }

      if (mounted) {
        Navigator.of(context).pop(true); // 성공적으로 완료됨을 알림
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('프로필이 설정되었습니다!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('프로필 설정 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('프로필 설정 실패: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 헤더
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFE91E63).withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.person_add,
                color: Color(0xFFE91E63),
                size: 30,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Text(
              '프로필 설정',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFFE91E63),
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'PickMe에서 사용할 닉네임과 나이를 설정해주세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // 닉네임 입력
            TextField(
              controller: _nicknameController,
              decoration: InputDecoration(
                labelText: '닉네임',
                hintText: '사용할 닉네임을 입력하세요',
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE91E63)),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 나이 입력
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '나이',
                hintText: '나이를 입력하세요',
                prefixIcon: const Icon(Icons.cake),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE91E63)),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 버튼들
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('나중에'),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E63),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('완료'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
