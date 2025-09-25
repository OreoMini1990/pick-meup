import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photo_model.dart';

class FirebasePhotoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _photosCollection = 'photos';
  static const String _usersCollection = 'users';

  // 모든 사진 가져오기
  static Future<List<PhotoModel>> getAllPhotos() async {
    // 더미 데이터 사용
    print('Using dummy data for all photos');
    return _getAllDummyPhotos();
  }

  // 특정 사용자의 사진 가져오기
  static Future<List<PhotoModel>> getUserPhotos(String userId) async {
    try {
      print('사용자 $userId의 사진을 가져오는 중...');
      
      // 인덱스 없이 쿼리하기 위해 orderBy 제거
      final querySnapshot = await _firestore
          .collection(_photosCollection)
          .where('userId', isEqualTo: userId)
          .get();
      
      final photos = querySnapshot.docs
          .map((doc) => PhotoModel.fromFirestore(doc))
          .toList();
      
      // 클라이언트에서 정렬
      photos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('사용자 $userId의 사진 ${photos.length}장을 가져왔습니다.');
      for (var photo in photos) {
        print('  - 사진 ID: ${photo.photoId}, URL: ${photo.url}');
      }
      return photos;
    } catch (e) {
      print('사용자 사진 가져오기 실패: $e');
      return [];
    }
  }

  // 사진 추가
  static Future<String?> addPhoto(PhotoModel photo) async {
    try {
      final docRef = await _firestore
          .collection(_photosCollection)
          .add(photo.toFirestore());
      
      print('사진이 Firestore에 저장되었습니다: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('사진 저장 실패: $e');
      return null;
    }
  }

  // 사진 업데이트
  static Future<bool> updatePhoto(String photoId, Map<String, dynamic> updates) async {
    try {
      await _firestore
          .collection(_photosCollection)
          .doc(photoId)
          .update(updates);
      return true;
    } catch (e) {
      print('Error updating photo: $e');
      return false;
    }
  }

  // 사진 선택 카운트 증가
  static Future<bool> incrementChosenCount(String photoId) async {
    try {
      await _firestore
          .collection(_photosCollection)
          .doc(photoId)
          .update({
        'chosenCount': FieldValue.increment(1),
        'exposureCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error incrementing chosen count: $e');
      return false;
    }
  }

  // 사진 노출 카운트만 증가
  static Future<bool> incrementExposureCount(String photoId) async {
    try {
      await _firestore
          .collection(_photosCollection)
          .doc(photoId)
          .update({
        'exposureCount': FieldValue.increment(1),
      });
      return true;
    } catch (e) {
      print('Error incrementing exposure count: $e');
      return false;
    }
  }

  // 더미 데이터에서 특정 사용자의 사진 가져오기
  static List<PhotoModel> _getDummyPhotosForUser(String userId) {
    final dummyPhotos = [
      // User 1 - 4장
      PhotoModel(
        photoId: 'user1_1',
        userId: 'user1',
        url: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 120,
        exposureCount: 200,
      ),
      PhotoModel(
        photoId: 'user1_2',
        userId: 'user1',
        url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 100,
        exposureCount: 200,
      ),
      PhotoModel(
        photoId: 'user1_3',
        userId: 'user1',
        url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 140,
        exposureCount: 220,
      ),
      PhotoModel(
        photoId: 'user1_4',
        userId: 'user1',
        url: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 90,
        exposureCount: 180,
      ),
      // User 2 - 4장
      PhotoModel(
        photoId: 'user2_1',
        userId: 'user2',
        url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 150,
        exposureCount: 250,
      ),
      PhotoModel(
        photoId: 'user2_2',
        userId: 'user2',
        url: 'https://images.unsplash.com/photo-1529626465-e491a72cb5f4?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1529626465-e491a72cb5f4?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 130,
        exposureCount: 250,
      ),
      PhotoModel(
        photoId: 'user2_3',
        userId: 'user2',
        url: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 160,
        exposureCount: 280,
      ),
      PhotoModel(
        photoId: 'user2_4',
        userId: 'user2',
        url: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 110,
        exposureCount: 200,
      ),
      // User 3 - 4장
      PhotoModel(
        photoId: 'user3_1',
        userId: 'user3',
        url: 'https://images.unsplash.com/photo-1520813792240-56ff4260afe4?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1520813792240-56ff4260afe4?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 90,
        exposureCount: 180,
      ),
      PhotoModel(
        photoId: 'user3_2',
        userId: 'user3',
        url: 'https://images.unsplash.com/photo-1507003211169-e695c6edd655?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1507003211169-e695c6edd655?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 120,
        exposureCount: 200,
      ),
      PhotoModel(
        photoId: 'user3_3',
        userId: 'user3',
        url: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 80,
        exposureCount: 150,
      ),
      PhotoModel(
        photoId: 'user3_4',
        userId: 'user3',
        url: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 110,
        exposureCount: 190,
      ),
      // User 4 - 4장
      PhotoModel(
        photoId: 'user4_1',
        userId: 'user4',
        url: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1494790108755-2616b612b786?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 140,
        exposureCount: 220,
      ),
      PhotoModel(
        photoId: 'user4_2',
        userId: 'user4',
        url: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 100,
        exposureCount: 180,
      ),
      PhotoModel(
        photoId: 'user4_3',
        userId: 'user4',
        url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 130,
        exposureCount: 210,
      ),
      PhotoModel(
        photoId: 'user4_4',
        userId: 'user4',
        url: 'https://images.unsplash.com/photo-1529626465-e491a72cb5f4?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1529626465-e491a72cb5f4?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 95,
        exposureCount: 170,
      ),
      // User 5 - 4장
      PhotoModel(
        photoId: 'user5_1',
        userId: 'user5',
        url: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 110,
        exposureCount: 190,
      ),
      PhotoModel(
        photoId: 'user5_2',
        userId: 'user5',
        url: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 85,
        exposureCount: 160,
      ),
      PhotoModel(
        photoId: 'user5_3',
        userId: 'user5',
        url: 'https://images.unsplash.com/photo-1520813792240-56ff4260afe4?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1520813792240-56ff4260afe4?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 105,
        exposureCount: 180,
      ),
      PhotoModel(
        photoId: 'user5_4',
        userId: 'user5',
        url: 'https://images.unsplash.com/photo-1507003211169-e695c6edd655?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        thumbUrl: 'https://images.unsplash.com/photo-1507003211169-e695c6edd655?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
        createdAt: DateTime.now(),
        status: 'approved',
        chosenCount: 125,
        exposureCount: 200,
      ),
    ];

    return dummyPhotos.where((photo) => photo.userId == userId).toList();
  }

  // 모든 더미 사진 가져오기
  static List<PhotoModel> _getAllDummyPhotos() {
    return _getDummyPhotosForUser('user1') +
           _getDummyPhotosForUser('user2') +
           _getDummyPhotosForUser('user3') +
           _getDummyPhotosForUser('user4') +
           _getDummyPhotosForUser('user5');
  }

  // 더미 데이터를 Firebase에 업로드
  static Future<void> uploadDummyData() async {
    try {
      // 사용자 데이터 업로드
      final users = [
        {
          'uid': 'user1',
          'email': 'user1@example.com',
          'nickname': '김민수',
          'profileCompleted': true,
          'age': 25,
          'job': '개발자',
          'regionCity': 'Seoul',
          'regionDistrict': 'Gangnam',
          'bio': '안녕하세요! 새로운 사람들과 만나는 것을 좋아합니다.',
          'contactPhone': '010-1234-5678',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'uid': 'user2',
          'email': 'user2@example.com',
          'nickname': '이지은',
          'profileCompleted': true,
          'age': 23,
          'job': '디자이너',
          'regionCity': 'Seoul',
          'regionDistrict': 'Hongdae',
          'bio': '예술과 음악을 사랑하는 사람입니다.',
          'contactPhone': '010-2345-6789',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'uid': 'user3',
          'email': 'user3@example.com',
          'nickname': '박준호',
          'profileCompleted': true,
          'age': 28,
          'job': '마케터',
          'regionCity': 'Busan',
          'regionDistrict': 'Haeundae',
          'bio': '여행과 사진 찍는 것을 즐깁니다.',
          'contactPhone': '010-3456-7890',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'uid': 'user4',
          'email': 'user4@example.com',
          'nickname': '최수진',
          'profileCompleted': true,
          'age': 26,
          'job': '교사',
          'regionCity': 'Seoul',
          'regionDistrict': 'Jongno',
          'bio': '아이들과 함께하는 시간을 좋아합니다.',
          'contactPhone': '010-4567-8901',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
        {
          'uid': 'user5',
          'email': 'user5@example.com',
          'nickname': '정민호',
          'profileCompleted': true,
          'age': 30,
          'job': '엔지니어',
          'regionCity': 'Incheon',
          'regionDistrict': 'Songdo',
          'bio': '기술과 혁신에 관심이 많습니다.',
          'contactPhone': '010-5678-9012',
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        },
      ];

      for (final user in users) {
        await _firestore
            .collection(_usersCollection)
            .doc(user['uid'] as String)
            .set(user);
      }

      // 사진 데이터 업로드
      final photos = [
        // User 1 - 4장
        {
          'userId': 'user1',
          'url': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 120,
          'exposureCount': 200,
        },
        {
          'userId': 'user1',
          'url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 100,
          'exposureCount': 200,
        },
        {
          'userId': 'user1',
          'url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 140,
          'exposureCount': 220,
        },
        {
          'userId': 'user1',
          'url': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 90,
          'exposureCount': 180,
        },
        // User 2 - 4장
        {
          'userId': 'user2',
          'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 150,
          'exposureCount': 250,
        },
        {
          'userId': 'user2',
          'url': 'https://images.unsplash.com/photo-1529626465-e491a72cb5f4?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1529626465-e491a72cb5f4?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 130,
          'exposureCount': 250,
        },
        {
          'userId': 'user2',
          'url': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 160,
          'exposureCount': 280,
        },
        {
          'userId': 'user2',
          'url': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 110,
          'exposureCount': 200,
        },
        // User 3 - 4장
        {
          'userId': 'user3',
          'url': 'https://images.unsplash.com/photo-1520813792240-56ff4260afe4?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1520813792240-56ff4260afe4?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 90,
          'exposureCount': 180,
        },
        {
          'userId': 'user3',
          'url': 'https://images.unsplash.com/photo-1507003211169-e695c6edd655?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1507003211169-e695c6edd655?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 120,
          'exposureCount': 200,
        },
        {
          'userId': 'user3',
          'url': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 80,
          'exposureCount': 150,
        },
        {
          'userId': 'user3',
          'url': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 110,
          'exposureCount': 190,
        },
        // User 4 - 4장
        {
          'userId': 'user4',
          'url': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 140,
          'exposureCount': 220,
        },
        {
          'userId': 'user4',
          'url': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 100,
          'exposureCount': 180,
        },
        {
          'userId': 'user4',
          'url': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 130,
          'exposureCount': 210,
        },
        {
          'userId': 'user4',
          'url': 'https://images.unsplash.com/photo-1529626465-e491a72cb5f4?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1529626465-e491a72cb5f4?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 95,
          'exposureCount': 170,
        },
        // User 5 - 4장
        {
          'userId': 'user5',
          'url': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 110,
          'exposureCount': 190,
        },
        {
          'userId': 'user5',
          'url': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1560250097-0b93528c311a?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 85,
          'exposureCount': 160,
        },
        {
          'userId': 'user5',
          'url': 'https://images.unsplash.com/photo-1520813792240-56ff4260afe4?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1520813792240-56ff4260afe4?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 105,
          'exposureCount': 180,
        },
        {
          'userId': 'user5',
          'url': 'https://images.unsplash.com/photo-1507003211169-e695c6edd655?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'thumbUrl': 'https://images.unsplash.com/photo-1507003211169-e695c6edd655?q=80&w=200&h=300&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
          'createdAt': Timestamp.now(),
          'status': 'approved',
          'chosenCount': 125,
          'exposureCount': 200,
        },
      ];

      for (final photo in photos) {
        await _firestore
            .collection(_photosCollection)
            .add(photo);
      }

      print('Dummy data uploaded successfully to Firebase!');
    } catch (e) {
      print('Error uploading dummy data: $e');
    }
  }
}
