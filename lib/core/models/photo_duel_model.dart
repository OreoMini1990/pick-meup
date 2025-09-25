import 'user_model.dart';
import 'photo_model.dart';

class PhotoDuel {
  final UserModel targetUser;
  final PhotoModel photoA;
  final PhotoModel photoB;

  PhotoDuel({
    required this.targetUser,
    required this.photoA,
    required this.photoB,
  });
}
