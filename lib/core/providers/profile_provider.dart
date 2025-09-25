import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';

class ProfileNotifier extends StateNotifier<UserModel?> {
  ProfileNotifier() : super(null);

  // 프로필 설정
  void setProfile({
    required String uid,
    required String email,
    required String displayName,
    required int age,
    int height = 0,
    String bio = '',
    String location = '',
    String photoURL = '',
  }) {
    state = UserModel(
      uid: uid,
      email: email,
      nickname: displayName,
      displayName: displayName,
      photoURL: photoURL,
      profileCompleted: true,
      age: age,
      height: height,
      bio: bio,
      location: location,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // 프로필 업데이트
  void updateProfile({
    String? displayName,
    int? age,
    int? height,
    String? bio,
    String? location,
    String? photoURL,
  }) {
    if (state != null) {
      state = state!.copyWith(
        displayName: displayName ?? state!.displayName,
        age: age ?? state!.age,
        height: height ?? state!.height,
        bio: bio ?? state!.bio,
        location: location ?? state!.location,
        photoURL: photoURL ?? state!.photoURL,
        updatedAt: DateTime.now(),
      );
    }
  }

  // 프로필 초기화
  void clearProfile() {
    state = null;
  }

  // 프로필 완료 여부 확인
  bool get isProfileCompleted => state?.profileCompleted ?? false;
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserModel?>((ref) {
  return ProfileNotifier();
});