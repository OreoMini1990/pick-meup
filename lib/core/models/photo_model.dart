import 'package:cloud_firestore/cloud_firestore.dart';

class PhotoModel {
  final String photoId;
  final String userId;
  final String url;
  final String thumbUrl;
  final String status;
  final int exposureCount;
  final int chosenCount;
  final DateTime createdAt;

  PhotoModel({
    required this.photoId,
    required this.userId,
    required this.url,
    required this.thumbUrl,
    this.status = 'approved',
    this.exposureCount = 0,
    this.chosenCount = 0,
    required this.createdAt,
  });

  factory PhotoModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PhotoModel(
      photoId: doc.id,
      userId: data['userId'] ?? '',
      url: data['url'] ?? '',
      thumbUrl: data['thumbUrl'] ?? '',
      status: data['status'] ?? 'approved',
      exposureCount: data['exposureCount'] ?? 0,
      chosenCount: data['chosenCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  factory PhotoModel.fromMap(Map<String, dynamic> data, String id) {
    return PhotoModel(
      photoId: id,
      userId: data['userId'] ?? '',
      url: data['url'] ?? '',
      thumbUrl: data['thumbUrl'] ?? '',
      status: data['status'] ?? 'approved',
      exposureCount: data['exposureCount'] ?? 0,
      chosenCount: data['chosenCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'url': url,
      'thumbUrl': thumbUrl,
      'status': status,
      'exposureCount': exposureCount,
      'chosenCount': chosenCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'url': url,
      'thumbUrl': thumbUrl,
      'status': status,
      'exposureCount': exposureCount,
      'chosenCount': chosenCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  PhotoModel copyWith({
    String? photoId,
    String? userId,
    String? url,
    String? thumbUrl,
    String? status,
    int? exposureCount,
    int? chosenCount,
    DateTime? createdAt,
  }) {
    return PhotoModel(
      photoId: photoId ?? this.photoId,
      userId: userId ?? this.userId,
      url: url ?? this.url,
      thumbUrl: thumbUrl ?? this.thumbUrl,
      status: status ?? this.status,
      exposureCount: exposureCount ?? this.exposureCount,
      chosenCount: chosenCount ?? this.chosenCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  double get ratio {
    if (exposureCount == 0) return 0.0;
    return chosenCount / exposureCount;
  }

  double get ratioPercentage {
    return ratio * 100;
  }
}
