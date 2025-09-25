import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoChoiceModel {
  final String id;
  final String chooserId;
  final String targetUserId;
  final String photoAId;
  final String photoBId;
  final String? chosenPhotoId;
  final DateTime createdAt;

  PhotoChoiceModel({
    required this.id,
    required this.chooserId,
    required this.targetUserId,
    required this.photoAId,
    required this.photoBId,
    this.chosenPhotoId,
    required this.createdAt,
  });

  factory PhotoChoiceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoChoiceModel(
      id: doc.id,
      chooserId: data['chooserId'] ?? '',
      targetUserId: data['targetUserId'] ?? '',
      photoAId: data['photoAId'] ?? '',
      photoBId: data['photoBId'] ?? '',
      chosenPhotoId: data['chosenPhotoId'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chooserId': chooserId,
      'targetUserId': targetUserId,
      'photoAId': photoAId,
      'photoBId': photoBId,
      'chosenPhotoId': chosenPhotoId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
