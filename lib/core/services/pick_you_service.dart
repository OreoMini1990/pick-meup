import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/photo_duel_model.dart';
import '../models/user_model.dart';
import '../models/photo_model.dart';
import '../models/feed_cooldown_model.dart';

class PickYouService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<PhotoDuel?> getNextPhotoDuel(String viewerId) {
    return _firestore
        .collection('users')
        .where('profileCompleted', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final candidates = <UserModel>[];
      
      for (final doc in snapshot.docs) {
        final user = UserModel.fromFirestore(doc);
        if (user.uid == viewerId) continue;
        
        // Check cooldown
        final cooldownId = FeedCooldownModel.generateId(viewerId, user.uid);
        final cooldownDoc = await _firestore
            .collection('feedCooldown')
            .doc(cooldownId)
            .get();
        
        if (cooldownDoc.exists) {
          final cooldown = FeedCooldownModel.fromFirestore(cooldownDoc);
          if (cooldown.nextEligibleAt.isAfter(DateTime.now())) {
            continue; // Skip if still in cooldown
          }
        }
        
        // Check if user has at least 2 photos
        final photosSnapshot = await _firestore
            .collection('users')
            .doc(user.uid)
            .collection('photos')
            .where('status', isEqualTo: 'approved')
            .get();
        
        if (photosSnapshot.docs.length >= 2) {
          candidates.add(user);
        }
      }
      
      if (candidates.isEmpty) return null;
      
      // Pick random candidate
      final random = DateTime.now().millisecondsSinceEpoch % candidates.length;
      final targetUser = candidates[random];
      
      // Get photos for duel
      final photos = await _getPhotosForDuel(targetUser.uid);
      if (photos.length < 2) return null;
      
      return PhotoDuel(
        targetUser: targetUser,
        photoA: photos[0],
        photoB: photos[1],
      );
    });
  }

  Future<List<PhotoModel>> _getPhotosForDuel(String userId) async {
    final photosSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('photos')
        .where('status', isEqualTo: 'approved')
        .orderBy('exposureCount')
        .limit(3)
        .get();
    
    final photos = photosSnapshot.docs
        .map((doc) => PhotoModel.fromFirestore(doc))
        .toList();
    
    if (photos.length < 2) return photos;
    
    // Try to find two photos with similar ratios
    final sortedPhotos = List<PhotoModel>.from(photos);
    sortedPhotos.sort((a, b) => a.exposureCount.compareTo(b.exposureCount));
    
    // Take first two photos (lowest exposure)
    return sortedPhotos.take(2).toList();
  }

  Future<void> pickPhoto(PhotoDuel duel, String chosenPhotoId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    
    try {
      final batch = _firestore.batch();
      
      // Increment exposure count for both photos
      final photoARef = _firestore
          .collection('users')
          .doc(duel.targetUser.uid)
          .collection('photos')
          .doc(duel.photoA.photoId);
      
      final photoBRef = _firestore
          .collection('users')
          .doc(duel.targetUser.uid)
          .collection('photos')
          .doc(duel.photoB.photoId);
      
      batch.update(photoARef, {
        'exposureCount': FieldValue.increment(1),
      });
      
      batch.update(photoBRef, {
        'exposureCount': FieldValue.increment(1),
      });
      
      // Increment chosen count for selected photo
      final chosenPhotoRef = chosenPhotoId == duel.photoA.photoId ? photoARef : photoBRef;
      batch.update(chosenPhotoRef, {
        'chosenCount': FieldValue.increment(1),
      });
      
      // Create photo choice log
      final choiceId = '${currentUser.uid}_${duel.targetUser.uid}_${DateTime.now().millisecondsSinceEpoch}';
      final choiceRef = _firestore.collection('photoChoices').doc(choiceId);
      
      batch.set(choiceRef, {
        'chooserId': currentUser.uid,
        'targetUserId': duel.targetUser.uid,
        'photoAId': duel.photoA.photoId,
        'photoBId': duel.photoB.photoId,
        'chosenPhotoId': chosenPhotoId,
        'createdAt': Timestamp.fromDate(DateTime.now()),
      });
      
      // Set cooldown
      final cooldownId = FeedCooldownModel.generateId(currentUser.uid, duel.targetUser.uid);
      final cooldownRef = _firestore.collection('feedCooldown').doc(cooldownId);
      
      batch.set(cooldownRef, {
        'viewerId': currentUser.uid,
        'targetId': duel.targetUser.uid,
        'nextEligibleAt': Timestamp.fromDate(
          DateTime.now().add(const Duration(days: 30)),
        ),
      });
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to record photo pick: $e');
    }
  }
}
