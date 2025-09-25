import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/like_service.dart';
import '../models/like_model.dart';

final likeServiceProvider = Provider<LikeService>((ref) {
  return LikeService();
});

final pendingLikesCountProvider = StreamProvider<int>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value(0);
  
  return ref.watch(likeServiceProvider).getPendingLikesCount(currentUser.uid);
});

final pendingLikesProvider = StreamProvider<List<LikeModel>>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value([]);
  
  return ref.watch(likeServiceProvider).getPendingLikes(currentUser.uid);
});

final sentLikesProvider = StreamProvider<List<LikeModel>>((ref) {
  final currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser == null) return Stream.value([]);
  
  return ref.watch(likeServiceProvider).getSentLikes(currentUser.uid);
});
