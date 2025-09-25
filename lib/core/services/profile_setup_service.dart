import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/photo_model.dart';

class ProfileSetupService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> completeProfile({
    required List<File> photos,
    required int age,
    required String job,
    required String regionCity,
    required String regionDistrict,
    required String bio,
    required String contactPhone,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    try {
      // Upload photos to storage
      final photoUrls = <String>[];
      final thumbUrls = <String>[];
      
      for (int i = 0; i < photos.length; i++) {
        final photo = photos[i];
        final photoId = '${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}_$i';
        
        // Upload original photo
        final photoRef = _storage
            .ref()
            .child('users')
            .child(currentUser.uid)
            .child('photos')
            .child('${photoId}.jpg');
        
        await photoRef.putFile(photo);
        final photoUrl = await photoRef.getDownloadURL();
        photoUrls.add(photoUrl);
        
        // For now, use the same URL for thumbnail (in production, you'd create actual thumbnails)
        thumbUrls.add(photoUrl);
      }
      
      // Update user document
      await _firestore.collection('users').doc(currentUser.uid).update({
        'profileCompleted': true,
        'age': age,
        'job': job,
        'regionCity': regionCity,
        'regionDistrict': regionDistrict,
        'bio': bio,
        'contactPhone': contactPhone,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      
      // Create photo documents
      final batch = _firestore.batch();
      
      for (int i = 0; i < photos.length; i++) {
        final photoId = '${currentUser.uid}_${DateTime.now().millisecondsSinceEpoch}_$i';
        final photoRef = _firestore
            .collection('users')
            .doc(currentUser.uid)
            .collection('photos')
            .doc(photoId);
        
        final photoModel = PhotoModel(
          photoId: photoId,
          userId: currentUser.uid,
          url: photoUrls[i],
          thumbUrl: thumbUrls[i],
          status: 'approved',
          exposureCount: 0,
          chosenCount: 0,
          createdAt: DateTime.now(),
        );
        
        batch.set(photoRef, photoModel.toFirestore());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to complete profile: $e');
    }
  }
}
