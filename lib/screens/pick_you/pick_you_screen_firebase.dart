import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase 연동 PickYou 화면
/// - 서버 데이터에서 "타깃 유저 1명 + 그 유저 사진 4장"을 불러와 4장 중 1장을 선택하는 UX
/// - 선택 전 비율 숨김, 선택 시 노출/선택 카운트 배치 업데이트 + 로그 + 쿨다운
/// - 선택 순간 AppBar 그라데이션 라이트 + 하트 버스트 애니메이션
/// - 하단 커스텀 네비게이션 바
///
/// 전제:
/// - Firebase.initializeApp()이 이미 main.dart 등에서 수행됨
/// - FirebaseAuth 로그인 완료 상태
/// - 파이어스토어 구조(예시):
///   users/{uid} { profileCompleted: true, nickname, ... }
///   users/{uid}/photos/{photoId} { url, exposureCount, chosenCount, status: 'approved' }
///   feedCooldown/{viewerId_targetId} { viewerId, targetId, nextEligibleAt: Timestamp }
///   photoChoices/{id} { chooserId, targetUserId, chosenPhotoId, shownPhotoIds: [..], createdAt }

class PickYouScreenFirebase extends StatefulWidget {
  const PickYouScreenFirebase({super.key});

  @override
  State<PickYouScreenFirebase> createState() => _PickYouScreenFirebaseState();
}

class _PickYouScreenFirebaseState extends State<PickYouScreenFirebase>
    with SingleTickerProviderStateMixin {
  late final _vm = _PickViewModel(onChanged: () => setState(() {}));
  late final AnimationController _heartCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _vm.loadNextSet(); // 최초 로드
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final glow = _vm.justPicked;
    return Scaffold(
      appBar: _GradientAppBar(
        title: '사진 선택',
        glow: glow,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.favorite_border)),
          const SizedBox(width: 6),
          const CircleAvatar(radius: 14, backgroundColor: Colors.black12),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                children: [
                  _ProfileHeader(nickname: _vm.nickname, sub: _vm.subInfo),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _FourGrid(
                      items: _vm.photos,
                      selectedIndex: _vm.selectedIndex,
                      showRatio: _vm.showRatio,
                      onTap: (index) async {
                        if (_vm.selectedIndex != null) return;
                        // 하트 애니메이션
                        _heartCtrl.forward(from: 0);
                        await _vm.pick(index); // 서버 반영 + 로컬 반영
                        await Future.delayed(const Duration(milliseconds: 900));
                        if (!mounted) return;
                        _vm.loadNextSet(); // 다음 세트 자동 로드
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '4장의 사진 중 더 잘 나온 사진을 선택해주세요',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 14),
                  _GradButton(
                    label: '프로필 열기',
                    icon: Icons.info_outline,
                    onPressed: () {
                      // 필요 시 상세/바텀시트로 연결
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('프로필 열기 (연결 필요)')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // 하트 버스트(중앙 상단)
          IgnorePointer(
            child: Align(
              alignment: Alignment.topCenter,
              child: _HeartBurst(controller: _heartCtrl),
            ),
          ),
          if (_vm.loading)
            const ColoredBox(
              color: Colors.transparent,
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: _PrettyNavBar(
        index: _tabIndex,
        onChanged: (i) => setState(() => _tabIndex = i),
      ),
    );
  }
}

//
// ----------------------------- ViewModel (Firebase 연동) -----------------------------
//

class _PickViewModel extends ChangeNotifier {
  _PickViewModel({required VoidCallback onChanged}) : _onChanged = onChanged;
  final VoidCallback _onChanged;

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  // 화면상 데이터
  bool loading = false;
  String targetUserId = '';
  String nickname = '';
  String subInfo = ''; // 필요 시 (나이, 지역 등)
  List<_PhotoItem> photos = [];
  int? selectedIndex;
  bool showRatio = false;
  bool justPicked = false;

  void _notify() {
    _onChanged();
    notifyListeners();
  }

  Future<void> loadNextSet() async {
    final me = _auth.currentUser;
    if (me == null) {
      // 비로그인 상태 → 종료
      return;
    }
    loading = true;
    selectedIndex = null;
    showRatio = false;
    justPicked = false;
    photos = [];
    nickname = '';
    targetUserId = '';
    subInfo = '';
    _notify();

    try {
      // 1) 후보 users 가져오기 (profileCompleted == true, uid != me, 쿨다운 제외)
      //    간단히 최근 가입/업데이트 순으로 최대 30명 조회 후 후보 필터링
      final usersSnap = await _db
          .collection('users')
          .where('profileCompleted', isEqualTo: true)
          .orderBy('updatedAt', descending: true)
          .limit(30)
          .get();

      final candidates = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final doc in usersSnap.docs) {
        if (doc.id == me.uid) continue;

        // 쿨다운 체크
        final cooldownId = '${me.uid}_${doc.id}';
        final cd = await _db.collection('feedCooldown').doc(cooldownId).get();
        if (cd.exists) {
          final nextEligibleAt = (cd.data()?['nextEligibleAt'] as Timestamp?)?.toDate();
          if (nextEligibleAt != null && nextEligibleAt.isAfter(DateTime.now())) {
            continue; // 아직 쿨다운
          }
        }

        // 사진 4장 이상(approved) 확인
        final photosSnap = await _db
            .collection('users')
            .doc(doc.id)
            .collection('photos')
            .where('status', isEqualTo: 'approved')
            .limit(6)
            .get();
        if (photosSnap.docs.length >= 4) {
          candidates.add(doc);
        }
      }

      if (candidates.isEmpty) {
        // 보여줄 타깃 없을 때
        loading = false;
        nickname = '지금은 보여줄 사용자가 없어요';
        _notify();
        return;
      }

      // 2) 후보 중 랜덤 1명 선택
      final chosen = candidates[Random().nextInt(candidates.length)];
      targetUserId = chosen.id;
      nickname = (chosen.data()?['nickname'] as String?) ?? '사용자';

      // 필요 시 부가정보(subInfo)
      final age = chosen.data()?['age'];
      final region = chosen.data()?['regionCity'];
      subInfo = [
        if (age != null) '${age}세',
        if (region != null) region,
      ].join(' • ');

      // 3) 그 유저의 approved 사진에서 4장 로드
      final pSnap = await _db
          .collection('users')
          .doc(targetUserId)
          .collection('photos')
          .where('status', isEqualTo: 'approved')
          .orderBy('createdAt', descending: true)
          .limit(8)
          .get();

      final allPhotos = pSnap.docs
          .map((d) => _PhotoItem(
                docId: d.id,
                url: (d.data()['url'] as String?) ?? '',
                exposure: (d.data()['exposureCount'] as int?) ?? 0,
                chosen: (d.data()['chosenCount'] as int?) ?? 0,
              ))
          .where((p) => p.url.isNotEmpty)
          .toList();

      // 랜덤 4장 샘플링
      allPhotos.shuffle();
      photos = allPhotos.take(4).toList();

      loading = false;
      _notify();
    } catch (e) {
      loading = false;
      nickname = '로딩 실패… 다시 시도해주세요';
      _notify();
    }
  }

  Future<void> pick(int index) async {
    if (selectedIndex != null) return;
    if (targetUserId.isEmpty || photos.length < 4) return;

    final me = _auth.currentUser;
    if (me == null) return;

    // 낙관적 UI
    for (final p in photos) p.exposure++;
    photos[index].chosen++;
    selectedIndex = index;
    showRatio = true;
    justPicked = true;
    _notify();
    Future.microtask(() {
      justPicked = false;
      _notify();
    });

    // 서버 반영 (배치/트랜잭션)
    try {
      final batch = _db.batch();

      final targetRef = _db.collection('users').doc(targetUserId);

      // 사진 4장 노출 증가 + 선택 사진 chosen 증가
      for (int i = 0; i < photos.length; i++) {
        final p = photos[i];
        final photoRef = targetRef.collection('photos').doc(p.docId);
        batch.update(photoRef, {
          'exposureCount': FieldValue.increment(1),
          if (i == index) 'chosenCount': FieldValue.increment(1),
        });
      }

      // 선택 로그
      final choiceRef = _db.collection('photoChoices').doc();
      batch.set(choiceRef, {
        'chooserId': me.uid,
        'targetUserId': targetUserId,
        'chosenPhotoId': photos[index].docId,
        'shownPhotoIds': photos.map((e) => e.docId).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 쿨다운(30일)
      final cooldownId = '${me.uid}_$targetUserId';
      final cooldownRef = _db.collection('feedCooldown').doc(cooldownId);
      final next = DateTime.now().add(const Duration(days: 30));
      batch.set(cooldownRef, {
        'viewerId': me.uid,
        'targetId': targetUserId,
        'nextEligibleAt': Timestamp.fromDate(next),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
    } catch (e) {
      // 실패 시: UI는 유지하되, 토스트로만 알림
      // (원하면 롤백 로직 추가 가능)
    }
  }
}

class _PhotoItem {
  _PhotoItem({
    required this.docId,
    required this.url,
    required this.exposure,
    required this.chosen,
  });
  final String docId;
  final String url;
  int exposure;
  int chosen;
  double get ratio => exposure == 0 ? 0 : chosen / exposure;
}

//
// ----------------------------- UI 위젯들 -----------------------------
//

class _GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _GradientAppBar({required this.title, required this.glow, this.actions});

  final String title;
  final bool glow;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppBar(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          actions: actions,
        ),
        if (glow)
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0x33FF2D70),
                      Color(0x22FFC371),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.nickname, required this.sub});
  final String nickname;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          const CircleAvatar(radius: 18, backgroundColor: Colors.black12),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nickname, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              const SizedBox(height: 2),
              Text(sub.isEmpty ? ' ' : sub, style: const TextStyle(color: Colors.black54)),
            ]),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline_rounded)),
        ],
      ),
    );
  }
}

class _FourGrid extends StatelessWidget {
  const _FourGrid({
    required this.items,
    required this.selectedIndex,
    required this.showRatio,
    required this.onTap,
  });

  final List<_PhotoItem> items;
  final int? selectedIndex;
  final bool showRatio;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('로딩 중...', style: TextStyle(color: Colors.black54)));
    }
    return LayoutBuilder(builder: (context, c) {
      const gap = 10.0;
      return Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(child: _PhotoCard(index: 0, item: items[0], selectedIndex: selectedIndex, showRatio: showRatio, onTap: onTap)),
                const SizedBox(width: gap),
                Expanded(child: _PhotoCard(index: 1, item: items[1], selectedIndex: selectedIndex, showRatio: showRatio, onTap: onTap)),
              ],
            ),
          ),
          const SizedBox(height: gap),
          Expanded(
            child: Row(
              children: [
                Expanded(child: _PhotoCard(index: 2, item: items[2], selectedIndex: selectedIndex, showRatio: showRatio, onTap: onTap)),
                const SizedBox(width: gap),
                Expanded(child: _PhotoCard(index: 3, item: items[3], selectedIndex: selectedIndex, showRatio: showRatio, onTap: onTap)),
              ],
            ),
          ),
        ],
      );
    });
  }
}

class _PhotoCard extends StatefulWidget {
  const _PhotoCard({
    required this.index,
    required this.item,
    required this.selectedIndex,
    required this.showRatio,
    required this.onTap,
  });

  final int index;
  final _PhotoItem item;
  final int? selectedIndex;
  final bool showRatio;
  final ValueChanged<int> onTap;

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedIndex == widget.index;
    final dimOthers = widget.selectedIndex != null && !selected;

    return Semantics(
      button: true,
      label: '사진 ${['A','B','C','D'][widget.index]} 선택',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () => widget.onTap(widget.index),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 130),
          scale: selected ? 1.04 : (_pressed ? 0.98 : 1.0),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(selected ? 0.25 : 0.10),
                      blurRadius: selected ? 22 : 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: widget.item.url,
                        fit: BoxFit.cover,
                        memCacheWidth: 1200,
                        placeholder: (_, __) => Container(color: const Color(0xFFEDEDEF)),
                        errorWidget: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFEDEDEF),
                          child: Icon(Icons.broken_image, size: 42, color: Colors.black38),
                        ),
                      ),
                      if (widget.selectedIndex == null)
                        Positioned(
                          left: 10, top: 10,
                          child: _Chip(text: '사진 ${['A','B','C','D'][widget.index]}'),
                        ),
                      if (widget.showRatio)
                        Positioned(
                          left: 10, right: 10, bottom: 12,
                          child: Center(
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 220),
                              opacity: 1,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.55),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${(widget.item.ratio * 100).round()}%',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (dimOthers)
                        Container(color: Colors.black.withOpacity(0.25)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

class _GradButton extends StatelessWidget {
  const _GradButton({required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          padding: EdgeInsets.zero,
        ).merge(ButtonStyle(
          overlayColor: const MaterialStatePropertyAll(Colors.white24),
          backgroundColor: const MaterialStatePropertyAll(Colors.transparent),
        )),
      ),
    )._withGradient();
  }
}

extension on Widget {
  Widget _withGradient() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFFFF2D70), Color(0xFFFFC371)]),
        borderRadius: BorderRadius.all(Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(28)),
          ),
          child: this,
        ),
      ),
    );
  }
}

class _HeartBurst extends StatelessWidget {
  const _HeartBurst({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = controller.value;
        final scale = 0.8 + t * 0.5;
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF2D70).withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite, color: Colors.white, size: 26),
            ),
          ),
        );
      },
    );
  }
}

class _PrettyNavBar extends StatelessWidget {
  const _PrettyNavBar({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final items = const [
      _NavItem(icon: Icons.camera_alt_rounded, label: '픽유'),
      _NavItem(icon: Icons.favorite, label: '픽미'),
      _NavItem(icon: Icons.person, label: '프로필'),
    ];
    return SafeArea(
      child: Container(
        height: 68,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          children: List.generate(items.length, (i) {
            final selected = i == index;
            return Expanded(
              child: InkWell(
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: selected
                            ? const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFFFF2D70), Color(0xFFFFC371)],
                                ),
                                shape: BoxShape.circle,
                              )
                            : null,
                        child: Icon(
                          items[i].icon,
                          color: selected ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        items[i].label,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: selected ? const Color(0xFFFF2D70) : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}




