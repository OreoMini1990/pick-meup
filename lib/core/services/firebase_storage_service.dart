import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _photosFolder = 'user_photos';

  // 사진 업로드 (uploadImage 별칭)
  static Future<String?> uploadImage(File imageFile, String filePath) async {
    try {
      final ref = _storage.ref().child(filePath);
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      print('사진 업로드 성공: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('사진 업로드 실패: $e');
      return null;
    }
  }

  // 사진 업로드
  static Future<String?> uploadPhoto(File imageFile, String userId) async {
    try {
      // 고유한 파일명 생성
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(imageFile.path)}';
      final ref = _storage.ref().child('$_photosFolder/$userId/$fileName');
      
      // 사진 업로드
      final uploadTask = await ref.putFile(imageFile);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      print('사진 업로드 성공: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('사진 업로드 실패: $e');
      return null;
    }
  }

  // 여러 사진 업로드
  static Future<List<String>> uploadMultiplePhotos(List<File> imageFiles, String userId) async {
    List<String> uploadedUrls = [];
    
    for (File imageFile in imageFiles) {
      final url = await uploadPhoto(imageFile, userId);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    
    return uploadedUrls;
  }

  // 사진 삭제
  static Future<bool> deletePhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
      print('사진 삭제 성공: $photoUrl');
      return true;
    } catch (e) {
      print('사진 삭제 실패: $e');
      return false;
    }
  }
}




