import 'package:cloud_firestore/cloud_firestore.dart';

class MatchModel {
  final String matchId;
  final String userAId;
  final String userBId;
  final DateTime createdAt;

  MatchModel({
    required this.matchId,
    required this.userAId,
    required this.userBId,
    required this.createdAt,
  });

  factory MatchModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MatchModel(
      matchId: doc.id,
      userAId: data['userAId'] ?? '',
      userBId: data['userBId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userAId': userAId,
      'userBId': userBId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  static String generateMatchId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
