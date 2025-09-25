import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/photo_model.dart';

class PickMeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<PhotoModel>> getUserPhotos(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('photos')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PhotoModel.fromFirestore(doc))
            .toList());
  }
}
