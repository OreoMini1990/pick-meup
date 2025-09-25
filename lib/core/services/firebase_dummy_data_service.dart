import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDummyDataService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// 유저 데이터가 이미 업로드되었는지 확인
  static Future<bool> isUserDataUploaded() async {
    try {
      final snapshot = await _firestore.collection('users').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('데이터 확인 중 오류: $e');
      return false;
    }
  }
  
  /// 더미 유저 데이터 업로드
  static Future<void> uploadUserData() async {
    try {
      // 더미 유저 데이터
      final dummyUsers = [
        {
          'id': 'user1',
          'name': '김민수',
          'age': 25,
          'bio': '안녕하세요! 새로운 사람들과 만나는 것을 좋아해요.',
          'photos': [
            'https://picsum.photos/400/600?random=1',
            'https://picsum.photos/400/600?random=2',
          ],
          'interests': ['영화', '음악', '여행'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'user2',
          'name': '이지은',
          'age': 23,
          'bio': '카페에서 책 읽는 것을 좋아해요. 함께 이야기 나눠요!',
          'photos': [
            'https://picsum.photos/400/600?random=3',
            'https://picsum.photos/400/600?random=4',
          ],
          'interests': ['독서', '카페', '산책'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'user3',
          'name': '박준호',
          'age': 28,
          'bio': '운동을 좋아하고 새로운 도전을 즐겨요.',
          'photos': [
            'https://picsum.photos/400/600?random=5',
            'https://picsum.photos/400/600?random=6',
          ],
          'interests': ['운동', '요리', '게임'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'user4',
          'name': '최유진',
          'age': 26,
          'bio': '예술과 문화에 관심이 많아요. 전시회 같이 가요!',
          'photos': [
            'https://picsum.photos/400/600?random=7',
            'https://picsum.photos/400/600?random=8',
          ],
          'interests': ['예술', '전시회', '음악'],
          'createdAt': FieldValue.serverTimestamp(),
        },
        {
          'id': 'user5',
          'name': '정태현',
          'age': 24,
          'bio': '개발자입니다. 기술 이야기 나눠요!',
          'photos': [
            'https://picsum.photos/400/600?random=9',
            'https://picsum.photos/400/600?random=10',
          ],
          'interests': ['프로그래밍', '기술', '스타트업'],
          'createdAt': FieldValue.serverTimestamp(),
        },
      ];
      
      // 배치로 데이터 업로드
      final batch = _firestore.batch();
      
      for (final user in dummyUsers) {
        final docRef = _firestore.collection('users').doc(user['id'] as String);
        batch.set(docRef, user);
      }
      
      await batch.commit();
      print('더미 데이터 업로드 완료');
    } catch (e) {
      print('더미 데이터 업로드 실패: $e');
      rethrow;
    }
  }
}
