import 'package:cloud_firestore/cloud_firestore.dart';

enum LikeStatus { pending, accepted, rejected }

class LikeModel {
  final String id;
  final String fromUserId;
  final String toUserId;
  final LikeStatus status;
  final DateTime createdAt;

  LikeModel({
    required this.id,
    required this.fromUserId,
    required this.toUserId,
    required this.status,
    required this.createdAt,
  });

  factory LikeModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LikeModel(
      id: doc.id,
      fromUserId: data['fromUserId'] ?? '',
      toUserId: data['toUserId'] ?? '',
      status: LikeStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => LikeStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'fromUserId': fromUserId,
      'toUserId': toUserId,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  LikeModel copyWith({
    String? id,
    String? fromUserId,
    String? toUserId,
    LikeStatus? status,
    DateTime? createdAt,
  }) {
    return LikeModel(
      id: id ?? this.id,
      fromUserId: fromUserId ?? this.fromUserId,
      toUserId: toUserId ?? this.toUserId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
