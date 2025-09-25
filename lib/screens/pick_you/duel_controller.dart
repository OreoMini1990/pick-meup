import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/duel_models.dart';
import '../../core/data/dummy_data.dart';

class DuelState {
  final DuelPair? pair;
  final bool loading;
  final bool error;
  final String? errorMessage;
  
  const DuelState({
    this.pair,
    this.loading = false,
    this.error = false,
    this.errorMessage,
  });
  
  DuelState copyWith({
    DuelPair? pair,
    bool? loading,
    bool? error,
    String? errorMessage,
  }) {
    return DuelState(
      pair: pair ?? this.pair,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

final duelControllerProvider = StateNotifierProvider<DuelController, DuelState>((ref) {
  return DuelController(ref);
});

class DuelController extends StateNotifier<DuelState> {
  final Ref ref;
  
  DuelController(this.ref) : super(const DuelState(loading: true)) {
    loadNext();
  }

  Future<void> loadNext() async {
    try {
      state = state.copyWith(loading: true, error: false, errorMessage: null);
      
      // 더미 데이터에서 랜덤하게 선택
      final dummyUsers = DummyData.dummyUsers;
      final dummyPhotos = DummyData.dummyPhotos;
      
      final random = DateTime.now().millisecondsSinceEpoch % dummyUsers.length;
      final targetUser = dummyUsers[random];
      
      // 같은 사람의 서로 다른 사진 2장 선택
      final photoA = dummyPhotos[random % dummyPhotos.length];
      final photoB = dummyPhotos[(random + 2) % dummyPhotos.length];
      
      final pair = DuelPair(
        targetUserId: targetUser.uid,
        nickname: targetUser.nickname,
        a: DuelPhoto(
          photoId: photoA.photoId,
          url: photoA.url,
          exposure: photoA.exposureCount,
          chosen: photoA.chosenCount,
        ),
        b: DuelPhoto(
          photoId: photoB.photoId,
          url: photoB.url,
          exposure: photoB.exposureCount,
          chosen: photoB.chosenCount,
        ),
      );
      
      // 로딩 시뮬레이션
      await Future.delayed(const Duration(milliseconds: 800));
      
      state = state.copyWith(
        pair: pair,
        loading: false,
        error: false,
      );
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: true,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> choose(DuelResult result) async {
    final pair = state.pair;
    if (pair == null) return;
    
    try {
      // TODO: 실제 Firestore 트랜잭션 구현
      // - 두 사진 exposure++
      // - 선택된 사진 chosen++
      // - photoChoices 로그
      // - feedCooldown 갱신
      
      // 낙관적 UI 업데이트
      final updatedPair = pair.copyWith(
        a: pair.a.copyWith(
          exposure: pair.a.exposure + 1,
          chosen: result == DuelResult.a ? pair.a.chosen + 1 : pair.a.chosen,
        ),
        b: pair.b.copyWith(
          exposure: pair.b.exposure + 1,
          chosen: result == DuelResult.b ? pair.b.chosen + 1 : pair.b.chosen,
        ),
      );
      
      state = state.copyWith(pair: updatedPair);
      
      // 성공 로그
      print('Choice made: ${result.name} for user ${pair.targetUserId}');
      
    } catch (e) {
      print('Error making choice: $e');
      // 에러가 발생해도 UI는 업데이트된 상태 유지
    }
  }
}
