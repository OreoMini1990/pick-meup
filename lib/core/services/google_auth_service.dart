import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class GoogleAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 구글 로그인
  static Future<UserCredential?> signInWithGoogle() async {
    try {
      // 구글 로그인 플로우 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // 사용자가 로그인을 취소함
        return null;
      }

      // 인증 세부 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 새 인증 자격 증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      // 사용자 정보를 Firestore에 저장 (처음 로그인인 경우)
      await _saveUserToFirestore(userCredential.user!);
      
      return userCredential;
    } catch (e) {
      print('구글 로그인 에러: $e');
      return null;
    }
  }

  // 사용자 정보를 Firestore에 저장
  static Future<void> _saveUserToFirestore(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        // 새 사용자인 경우 Firestore에 저장
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          nickname: user.displayName ?? '',
          displayName: user.displayName ?? '',
          profileCompleted: false,
          age: null,
          job: null,
          regionCity: null,
          regionDistrict: null,
          bio: null,
          contactPhone: null,
          photoURL: user.photoURL,
          height: null,
          location: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(newUser.toFirestore());
        print('새 사용자 정보가 Firestore에 저장되었습니다.');
      }
    } catch (e) {
      print('사용자 정보 저장 에러: $e');
    }
  }

  // 로그아웃
  static Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('로그아웃 에러: $e');
    }
  }

  // 현재 사용자 가져오기
  static User? getCurrentUser() {
    return _auth.currentUser;
  }

  // 로그인 상태 스트림
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // 사용자 정보 업데이트
  static Future<void> updateUserProfile({
    required String uid,
    required String nickname,
    required int age,
    required String job,
    required String regionCity,
    required String regionDistrict,
    required String bio,
    required String contactPhone,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'nickname': nickname,
        'age': age,
        'job': job,
        'regionCity': regionCity,
        'regionDistrict': regionDistrict,
        'bio': bio,
        'contactPhone': contactPhone,
        'profileCompleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('사용자 프로필 업데이트 에러: $e');
    }
  }

  // 사용자 정보 가져오기
  static Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('사용자 프로필 가져오기 에러: $e');
      return null;
    }
  }
}
