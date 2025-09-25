class DuelPhoto {
  final String photoId;
  final String url;
  final int exposure;
  final int chosen;
  
  const DuelPhoto({
    required this.photoId,
    required this.url,
    required this.exposure,
    required this.chosen,
  });
  
  double get ratio => exposure == 0 ? 0 : chosen / exposure;
  
  DuelPhoto copyWith({
    String? photoId,
    String? url,
    int? exposure,
    int? chosen,
  }) {
    return DuelPhoto(
      photoId: photoId ?? this.photoId,
      url: url ?? this.url,
      exposure: exposure ?? this.exposure,
      chosen: chosen ?? this.chosen,
    );
  }
}

class DuelPair {
  final String targetUserId;
  final String nickname;
  final DuelPhoto a;
  final DuelPhoto b;
  
  const DuelPair({
    required this.targetUserId,
    required this.nickname,
    required this.a,
    required this.b,
  });
  
  DuelPair copyWith({
    String? targetUserId,
    String? nickname,
    DuelPhoto? a,
    DuelPhoto? b,
  }) {
    return DuelPair(
      targetUserId: targetUserId ?? this.targetUserId,
      nickname: nickname ?? this.nickname,
      a: a ?? this.a,
      b: b ?? this.b,
    );
  }
}

enum DuelResult { a, b, c, d }

class DuelChoice {
  final String targetUserId;
  final DuelResult result;
  final DateTime timestamp;
  
  const DuelChoice({
    required this.targetUserId,
    required this.result,
    required this.timestamp,
  });
}
