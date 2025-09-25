import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String nickname;
  final String displayName;
  final bool profileCompleted;
  final int? age;
  final String? job;
  final String? regionCity;
  final String? regionDistrict;
  final String? bio;
  final String? contactPhone;
  final String? photoURL;
  final int? height;
  final String? location;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  static const String defaultThumbnailUrl = 'https://via.placeholder.com/150x150/cccccc/666666?text=U';

  UserModel({
    required this.uid,
    required this.email,
    required this.nickname,
    required this.displayName,
    this.profileCompleted = false,
    this.age,
    this.job,
    this.regionCity,
    this.regionDistrict,
    this.bio,
    this.contactPhone,
    this.photoURL,
    this.height,
    this.location,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      displayName: data['displayName'] ?? data['nickname'] ?? '',
      profileCompleted: data['profileCompleted'] ?? false,
      age: data['age'],
      job: data['job'],
      regionCity: data['regionCity'],
      regionDistrict: data['regionDistrict'],
      bio: data['bio'],
      contactPhone: data['contactPhone'],
      photoURL: data['photoURL'],
      height: data['height'],
      location: data['location'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'nickname': nickname,
      'displayName': displayName,
      'profileCompleted': profileCompleted,
      'age': age,
      'job': job,
      'regionCity': regionCity,
      'regionDistrict': regionDistrict,
      'bio': bio,
      'contactPhone': contactPhone,
      'photoURL': photoURL,
      'height': height,
      'location': location,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  UserModel copyWith({
    String? uid,
    String? email,
    String? nickname,
    String? displayName,
    bool? profileCompleted,
    int? age,
    String? job,
    String? regionCity,
    String? regionDistrict,
    String? bio,
    String? contactPhone,
    String? photoURL,
    int? height,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      displayName: displayName ?? this.displayName,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      age: age ?? this.age,
      job: job ?? this.job,
      regionCity: regionCity ?? this.regionCity,
      regionDistrict: regionDistrict ?? this.regionDistrict,
      bio: bio ?? this.bio,
      contactPhone: contactPhone ?? this.contactPhone,
      photoURL: photoURL ?? this.photoURL,
      height: height ?? this.height,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
