import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile_setup/presentation/pages/profile_setup_page.dart';
import '../../screens/pick_you/pick_you_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../features/pick_me/presentation/pages/pick_me_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/inbox/presentation/pages/inbox_page.dart';
import '../../features/my_page/presentation/pages/my_page.dart';
import '../../features/splash/presentation/pages/splash_page.dart';
import '../../features/main/presentation/pages/main_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/pick-me',
    redirect: (context, state) {
      // 테스트 모드에서는 리다이렉트 비활성화
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/profile-setup',
        builder: (context, state) => const ProfileSetupPage(),
      ),
        GoRoute(
          path: '/pick-you',
          builder: (context, state) => const MainPage(
            child: PickYouScreen(),
            currentRoute: '/pick-you',
          ),
        ),
      GoRoute(
        path: '/pick-me',
        builder: (context, state) => const MainPage(
          child: PickMePage(),
          currentRoute: '/pick-me',
        ),
      ),
      GoRoute(
        path: '/profile/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return ProfilePage(uid: uid);
        },
      ),
      GoRoute(
        path: '/inbox',
        builder: (context, state) => const InboxPage(),
      ),
      GoRoute(
        path: '/me',
        builder: (context, state) => const MainPage(
          child: MyPage(),
          currentRoute: '/me',
        ),
      ),
    ],
  );
});
