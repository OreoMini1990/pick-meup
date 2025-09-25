import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pick_me_service.dart';
import '../models/photo_model.dart';

final pickMeServiceProvider = Provider<PickMeService>((ref) {
  return PickMeService();
});

final userPhotosProvider = StreamProvider<List<PhotoModel>>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value([]);
  
  return ref.watch(pickMeServiceProvider).getUserPhotos(currentUser.uid);
});
