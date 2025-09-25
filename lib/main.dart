import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/firebase_dummy_data_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Firebase 초기화 (데이터베이스가 없어도 앱은 정상 작동)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase 초기화 성공');
  } catch (e) {
    print('Firebase 초기화 실패: $e');
    // Firebase 실패해도 앱은 계속 실행
  }
  
  // Firebase에 유저 데이터 업로드 시도 (실패해도 계속 진행)
  try {
    final isDataUploaded = await FirebaseDummyDataService.isUserDataUploaded();
    if (!isDataUploaded) {
      await FirebaseDummyDataService.uploadUserData();
      print('유저 데이터 업로드 성공');
    }
  } catch (e) {
    print('유저 데이터 업로드 실패 (오프라인 모드로 계속): $e');
    // 실패해도 앱은 계속 실행
  }
  
  runApp(
    const ProviderScope(
      child: PhotoPickDatingApp(),
    ),
  );
}

class PhotoPickDatingApp extends ConsumerWidget {
  const PhotoPickDatingApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: '사진 선택 소개팅',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
