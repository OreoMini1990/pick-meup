import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/pick_you_service.dart';
import '../models/photo_duel_model.dart';

final pickYouServiceProvider = Provider<PickYouService>((ref) {
  return PickYouService();
});

final photoDuelProvider = StreamProvider<PhotoDuel?>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value(null);
  
  return ref.watch(pickYouServiceProvider).getNextPhotoDuel(currentUser.uid);
});
