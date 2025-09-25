import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/selected_photo_model.dart';

class SelectedPhotoNotifier extends StateNotifier<List<SelectedPhoto>> {
  SelectedPhotoNotifier() : super([]);

  void addSelectedPhoto(SelectedPhoto photo) {
    state = [...state, photo];
  }

  void clearSelectedPhotos() {
    state = [];
  }
}

final selectedPhotoProvider = StateNotifierProvider<SelectedPhotoNotifier, List<SelectedPhoto>>((ref) {
  return SelectedPhotoNotifier();
});

