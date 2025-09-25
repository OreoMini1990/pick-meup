import 'package:firebase_core/firebase_core.dart';
import 'firebase_photo_service.dart';

class FirebaseInitService {
  static bool _isInitialized = false;
  
  static Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      // Firebase 초기화
      await Firebase.initializeApp();
      
      // 더미 데이터 업로드 (개발 환경에서만)
      await FirebasePhotoService.uploadDummyData();
      
      _isInitialized = true;
      print('Firebase initialized successfully!');
    } catch (e) {
      print('Error initializing Firebase: $e');
    }
  }
}

