import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../services/profile_setup_service.dart';

final profileSetupServiceProvider = Provider<ProfileSetupService>((ref) {
  return ProfileSetupService();
});

final profileSetupProvider = StateNotifierProvider<ProfileSetupNotifier, AsyncValue<void>>((ref) {
  return ProfileSetupNotifier(ref.read(profileSetupServiceProvider));
});

class ProfileSetupNotifier extends StateNotifier<AsyncValue<void>> {
  final ProfileSetupService _service;

  ProfileSetupNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> completeProfile({
    required List<File> photos,
    required int age,
    required String job,
    required String regionCity,
    required String regionDistrict,
    required String bio,
    required String contactPhone,
  }) async {
    state = const AsyncValue.loading();
    
    try {
      await _service.completeProfile(
        photos: photos,
        age: age,
        job: job,
        regionCity: regionCity,
        regionDistrict: regionDistrict,
        bio: bio,
        contactPhone: contactPhone,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
