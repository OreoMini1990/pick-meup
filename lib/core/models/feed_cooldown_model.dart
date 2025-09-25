import 'package:cloud_firestore/cloud_firestore.dart';

class FeedCooldownModel {
  final String id;
  final String viewerId;
  final String targetId;
  final DateTime nextEligibleAt;

  FeedCooldownModel({
    required this.id,
    required this.viewerId,
    required this.targetId,
    required this.nextEligibleAt,
  });

  factory FeedCooldownModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FeedCooldownModel(
      id: doc.id,
      viewerId: data['viewerId'] ?? '',
      targetId: data['targetId'] ?? '',
      nextEligibleAt: (data['nextEligibleAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'viewerId': viewerId,
      'targetId': targetId,
      'nextEligibleAt': Timestamp.fromDate(nextEligibleAt),
    };
  }

  static String generateId(String viewerId, String targetId) {
    return '${viewerId}_$targetId';
  }
}
