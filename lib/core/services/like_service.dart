import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/like_model.dart';
import '../models/match_model.dart';

class LikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendLike(String fromUserId, String toUserId) async {
    try {
      final likeId = '${fromUserId}_${toUserId}_${DateTime.now().millisecondsSinceEpoch}';
      
      await _firestore.collection('likes').doc(likeId).set({
        'fromUserId': fromUserId,
        'toUserId': toUserId,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to send like: $e');
    }
  }

  Future<void> acceptLike(String likeId) async {
    try {
      final batch = _firestore.batch();
      
      // Get the like document
      final likeDoc = await _firestore.collection('likes').doc(likeId).get();
      if (!likeDoc.exists) throw Exception('Like not found');
      
      final likeData = likeDoc.data()!;
      final fromUserId = likeData['fromUserId'] as String;
      final toUserId = likeData['toUserId'] as String;
      
      // Update like status
      batch.update(_firestore.collection('likes').doc(likeId), {
        'status': 'accepted',
      });
      
      // Check if there's a mutual like
      final mutualLikeQuery = await _firestore
          .collection('likes')
          .where('fromUserId', isEqualTo: toUserId)
          .where('toUserId', isEqualTo: fromUserId)
          .where('status', isEqualTo: 'accepted')
          .limit(1)
          .get();
      
      if (mutualLikeQuery.docs.isNotEmpty) {
        // Create match
        final matchId = MatchModel.generateMatchId(fromUserId, toUserId);
        batch.set(_firestore.collection('matches').doc(matchId), {
          'userAId': fromUserId,
          'userBId': toUserId,
          'createdAt': Timestamp.fromDate(DateTime.now()),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to accept like: $e');
    }
  }

  Future<void> rejectLike(String likeId) async {
    try {
      await _firestore.collection('likes').doc(likeId).update({
        'status': 'rejected',
      });
    } catch (e) {
      throw Exception('Failed to reject like: $e');
    }
  }

  Stream<List<LikeModel>> getPendingLikes(String userId) {
    return _firestore
        .collection('likes')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LikeModel.fromFirestore(doc))
            .toList());
  }

  Stream<List<LikeModel>> getSentLikes(String userId) {
    return _firestore
        .collection('likes')
        .where('fromUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LikeModel.fromFirestore(doc))
            .toList());
  }

  Stream<int> getPendingLikesCount(String userId) {
    return _firestore
        .collection('likes')
        .where('toUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<bool> hasLiked(String fromUserId, String toUserId) async {
    try {
      final query = await _firestore
          .collection('likes')
          .where('fromUserId', isEqualTo: fromUserId)
          .where('toUserId', isEqualTo: toUserId)
          .limit(1)
          .get();
      
      return query.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}
