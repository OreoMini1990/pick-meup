# 개발 규칙 및 가이드라인

## 📋 **사진 선택 소개팅 앱 개발 규칙**

### 1. **모델(Model) 규칙**
- 모든 모델은 `lib/core/models/` 디렉토리에 위치
- 모델명은 `Model` 접미사 사용 (예: `UserModel`, `PhotoModel`)
- 필수 메서드: `fromJson()`, `toJson()`, `copyWith()`
- Firestore 사용 시: `fromFirestore()`, `toFirestore()` 메서드 추가
- 모든 속성은 `final`로 선언하고 `required` 키워드 사용

### 2. **Provider 규칙**
- 모든 Provider는 `lib/core/providers/` 디렉토리에 위치
- Provider명은 `Provider` 접미사 사용 (예: `userProvider`, `photoProvider`)
- StateNotifier 사용 시: `Notifier` 접미사 사용 (예: `UserNotifier`)
- Provider 파일명은 `_provider.dart` 접미사 사용

### 3. **서비스(Service) 규칙**
- 모든 서비스는 `lib/core/services/` 디렉토리에 위치
- 서비스명은 `Service` 접미사 사용 (예: `AuthService`, `PhotoService`)
- 정적 메서드 사용 시: `static` 키워드 명시
- 에러 처리: try-catch 블록 필수, 로그 출력

### 4. **위젯(Widget) 규칙**
- ConsumerWidget 사용 시: `mounted` 속성 접근 불가
- `mounted` 속성 필요 시: `ConsumerStatefulWidget` 사용
- 위젯명은 기능을 명확히 표현 (예: `PickYouScreen`, `ProfilePage`)

### 5. **라우팅(Routing) 규칙**
- 모든 라우트는 `lib/core/router/app_router.dart`에 정의
- 라우트 경로는 소문자와 하이픈 사용 (예: `/pick-you`, `/profile-setup`)
- 중복 라우트 경로 금지

### 6. **데이터 일관성 규칙**
- 모델 간 속성명 통일 (예: `url` vs `photoUrl` → `url` 사용)
- Provider와 Service 간 인터페이스 일치
- Firestore 필드명과 모델 속성명 일치

### 7. **에러 처리 규칙**
- 모든 비동기 작업에 try-catch 블록 사용
- 에러 발생 시 사용자에게 적절한 메시지 표시
- 로그 출력으로 디버깅 정보 제공

### 8. **파일 구조 규칙**
```
lib/
├── core/
│   ├── models/          # 데이터 모델
│   ├── providers/       # 상태 관리
│   ├── services/        # 비즈니스 로직
│   ├── router/          # 라우팅
│   └── theme/           # 테마
├── features/            # 기능별 페이지
│   └── [feature_name]/
│       └── presentation/
│           ├── pages/   # 페이지
│           └── widgets/ # 위젯
└── screens/             # 공통 화면
```

### 9. **네이밍 컨벤션**
- 파일명: `snake_case` (예: `user_model.dart`)
- 클래스명: `PascalCase` (예: `UserModel`)
- 변수명: `camelCase` (예: `userName`)
- 상수명: `UPPER_SNAKE_CASE` (예: `MAX_PHOTOS`)

### 10. **코드 품질 규칙**
- 모든 public 메서드에 문서 주석 추가
- 하드코딩된 값은 상수로 분리
- 중복 코드 제거 및 재사용 가능한 컴포넌트 생성
- null safety 준수

## 🚨 **자주 발생하는 문제들**

### 1. **Provider 누락**
- 새로운 Provider 사용 전에 해당 Provider가 존재하는지 확인
- Provider 파일이 `lib/core/providers/`에 위치하는지 확인

### 2. **모델 속성 불일치**
- 모델 간 속성명 통일 (예: `photoUrl` vs `url`)
- Firestore 필드명과 모델 속성명 일치 확인

### 3. **Widget 타입 오류**
- `ConsumerWidget`에서 `mounted` 속성 사용 금지
- `mounted` 필요 시 `ConsumerStatefulWidget` 사용

### 4. **Import 누락 (가장 빈번한 문제)**
- 사용하는 모든 클래스, 함수 import 확인
- 상대 경로 사용 시 정확한 경로 확인
- **새로운 모델 생성 시**: 해당 모델을 사용하는 모든 파일에 import 추가
- **Provider 사용 시**: Provider와 모델 모두 import 확인
- **클래스 사용 전**: 해당 클래스가 import되었는지 확인
- **빌드 에러 시**: "isn't defined" 에러는 대부분 import 누락

### 5. **서비스 메서드 누락**
- Service 클래스에 필요한 메서드가 구현되어 있는지 확인
- 정적 메서드 사용 시 `static` 키워드 확인

### 6. **모델 생성 후 사용처 미반영**
- 새로운 모델 생성 시 기존 코드에서 사용하는 곳에 import 추가
- Provider에서 모델 사용 시 모델 파일 import 확인

### 7. **모델 생성자 매개변수 누락**
- 모델 생성 시 모든 필수 매개변수 제공 확인
- **"Required named parameter must be provided" 에러** → 생성자 매개변수 누락
- 모델 정의와 사용처의 매개변수 일치 확인

## 📝 **체크리스트**

새로운 기능 추가 시 확인사항:
- [ ] 모델이 `lib/core/models/`에 올바르게 정의되었는가?
- [ ] Provider가 `lib/core/providers/`에 올바르게 정의되었는가?
- [ ] Service가 `lib/core/services/`에 올바르게 정의되었는가?
- [ ] **모든 import가 올바르게 되어 있는가? (가장 중요!)**
- [ ] **새로운 모델을 사용하는 모든 파일에 import가 추가되었는가?**
- [ ] **Provider와 모델 모두 import되었는가?**
- [ ] 모델 간 속성명이 일치하는가?
- [ ] 에러 처리가 적절히 되어 있는가?
- [ ] 라우트가 중복되지 않는가?
- [ ] Widget 타입이 올바른가? (ConsumerWidget vs ConsumerStatefulWidget)

**빌드 에러 발생 시 우선 확인사항:**
1. "isn't defined" 에러 → import 누락 확인
2. "Member not found" 에러 → 속성명 불일치 확인
3. "No named parameter" 에러 → 모델 생성자 불일치 확인
4. **"Required named parameter must be provided" 에러** → 생성자 매개변수 누락 확인
5. "The method isn't defined" 에러 → 클래스 import 누락 확인
