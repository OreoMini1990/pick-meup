class SelectedPhoto {
  final String photoId;
  final String userId;
  final String photoUrl;
  final String nickname;
  final DateTime selectedAt;

  const SelectedPhoto({
    required this.photoId,
    required this.userId,
    required this.photoUrl,
    required this.nickname,
    required this.selectedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'photoId': photoId,
      'userId': userId,
      'photoUrl': photoUrl,
      'nickname': nickname,
      'selectedAt': selectedAt.toIso8601String(),
    };
  }

  factory SelectedPhoto.fromJson(Map<String, dynamic> json) {
    return SelectedPhoto(
      photoId: json['photoId'] as String,
      userId: json['userId'] as String,
      photoUrl: json['photoUrl'] as String,
      nickname: json['nickname'] as String,
      selectedAt: DateTime.parse(json['selectedAt'] as String),
    );
  }

  SelectedPhoto copyWith({
    String? photoId,
    String? userId,
    String? photoUrl,
    String? nickname,
    DateTime? selectedAt,
  }) {
    return SelectedPhoto(
      photoId: photoId ?? this.photoId,
      userId: userId ?? this.userId,
      photoUrl: photoUrl ?? this.photoUrl,
      nickname: nickname ?? this.nickname,
      selectedAt: selectedAt ?? this.selectedAt,
    );
  }
}
