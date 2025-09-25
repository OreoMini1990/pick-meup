import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../services/firebase_storage_service.dart';
import '../services/firebase_photo_service.dart';
import '../models/photo_model.dart';

// 사진 업로드 상태를 관리하는 모델
class PhotoUploadState {
  final bool isUploading;
  final List<String> uploadedUrls;
  final String? error;
  final int progress;

  const PhotoUploadState({
    this.isUploading = false,
    this.uploadedUrls = const [],
    this.error,
    this.progress = 0,
  });

  PhotoUploadState copyWith({
    bool? isUploading,
    List<String>? uploadedUrls,
    String? error,
    int? progress,
  }) {
    return PhotoUploadState(
      isUploading: isUploading ?? this.isUploading,
      uploadedUrls: uploadedUrls ?? this.uploadedUrls,
      error: error ?? this.error,
      progress: progress ?? this.progress,
    );
  }
}

// 사진 업로드 상태 관리 Notifier
class PhotoUploadNotifier extends StateNotifier<PhotoUploadState> {
  PhotoUploadNotifier() : super(const PhotoUploadState());

  // 사진 업로드
  Future<void> uploadPhotos(List<File> imageFiles, String userId) async {
    if (imageFiles.isEmpty) return;

    state = state.copyWith(
      isUploading: true,
      error: null,
      progress: 0,
    );

    try {
      final List<String> uploadedUrls = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        // 진행률 업데이트
        state = state.copyWith(
          progress: ((i + 1) / imageFiles.length * 100).round(),
        );

        // Firebase Storage에 업로드
        final url = await FirebaseStorageService.uploadImage(
          imageFiles[i], 
          'users/$userId/photos/${DateTime.now().millisecondsSinceEpoch}_$i.jpg'
        );

        if (url != null) {
          uploadedUrls.add(url);
          
          // PhotoModel 생성 및 Firestore에 저장
          final photo = PhotoModel(
            photoId: 'photo_${DateTime.now().millisecondsSinceEpoch}_$i',
            userId: userId,
            url: url,
            thumbUrl: url, // 썸네일은 원본과 동일하게 설정
            createdAt: DateTime.now(),
            status: 'approved',
            chosenCount: 0,
            exposureCount: 0,
          );

          await FirebasePhotoService.addPhoto(photo);
        }
      }

      state = state.copyWith(
        isUploading: false,
        uploadedUrls: uploadedUrls,
        progress: 100,
      );
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        error: e.toString(),
      );
    }
  }

  // 상태 초기화
  void reset() {
    state = const PhotoUploadState();
  }
}

// Provider
final photoUploadProvider = StateNotifierProvider<PhotoUploadNotifier, PhotoUploadState>((ref) {
  return PhotoUploadNotifier();
});
