import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_model.dart';
import '../services/firebase_photo_service.dart';

// 사용자 사진을 가져오는 FutureProvider
final userPhotosProvider = FutureProvider.family<List<PhotoModel>, String>((ref, userId) async {
  try {
    print('사용자 $userId의 사진을 가져오는 중...');
    final photos = await FirebasePhotoService.getUserPhotos(userId);
    print('사용자 $userId의 사진 ${photos.length}장을 가져왔습니다.');
    return photos;
  } catch (e) {
    print('사용자 사진 가져오기 실패: $e');
    return [];
  }
});

// 모든 사진을 가져오는 FutureProvider
final allPhotosProvider = FutureProvider<List<PhotoModel>>((ref) async {
  try {
    print('모든 사진을 가져오는 중...');
    final photos = await FirebasePhotoService.getAllPhotos();
    print('모든 사진 ${photos.length}장을 가져왔습니다.');
    return photos;
  } catch (e) {
    print('모든 사진 가져오기 실패: $e');
    return [];
  }
});