import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/photo_model.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return UserModel.fromFirestore(doc);
          }
          return null;
        });
  }

  Stream<List<PhotoModel>> getUserPhotos(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('photos')
        .where('status', isEqualTo: 'approved')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PhotoModel.fromFirestore(doc))
            .toList());
  }
}
