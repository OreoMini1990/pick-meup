# Photo Pick Dating - Flutter App

A social app where users pick between two photos of the same person. Dating vibe is minimized. Users can send Likes only after completing their own profile; mutual Likes reveal phone numbers. No chat functionality.

## Features

### Core Functionality
- **Photo Duels**: Users pick between two photos of the same person
- **Profile System**: Complete profile required to send/receive likes
- **Like System**: Send likes, receive likes, mutual likes reveal phone numbers
- **Stats Tracking**: View photo performance statistics
- **Cooldown System**: 30-day cooldown between showing same user

### Authentication
- Google Sign-In integration
- Placeholder stubs for Kakao/Apple (disabled)
- Automatic user document creation

### Profile Management
- Photo upload (2-6 photos required)
- Basic information (age, job, location, bio)
- Optional contact phone number
- Profile completion gating for features

### Navigation
- Bottom navigation with 3 tabs: PickYou, PickMe, MyPage
- App bar with profile avatar and inbox badge
- Profile completion guards throughout the app

## Tech Stack

- **Flutter**: ≥3.19, Dart ≥3.3
- **Android**: compileSdk 34, minSdk 23
- **Firebase**: Auth, Firestore, Storage
- **State Management**: Riverpod
- **Navigation**: go_router
- **Image Handling**: image_picker, cached_network_image

## Project Structure

```
lib/
├── core/
│   ├── models/           # Data models
│   ├── providers/        # Riverpod providers
│   ├── services/         # Business logic services
│   ├── router/           # Navigation configuration
│   └── theme/            # App theming
├── features/
│   ├── onboarding/       # Authentication flow
│   ├── profile_setup/    # Profile completion wizard
│   ├── pick_you/         # Main photo duel functionality
│   ├── pick_me/          # User stats and photo management
│   ├── inbox/            # Likes received management
│   ├── profile/          # Profile viewing
│   ├── my_page/          # User's own profile management
│   └── main/             # Main layout and navigation
└── main.dart
```

## Firebase Collections

### Users
```
users/{uid}
{
  uid: string,
  email: string,
  nickname: string,
  profileCompleted: boolean,
  age?: number,
  job?: string,
  regionCity?: string,
  regionDistrict?: string,
  bio?: string,
  contactPhone?: string,
  createdAt: timestamp,
  updatedAt: timestamp
}
```

### Photos
```
users/{uid}/photos/{photoId}
{
  url: string,
  thumbUrl: string,
  status: 'approved',
  exposureCount: number,
  chosenCount: number,
  createdAt: timestamp
}
```

### Other Collections
- `photoChoices/{id}`: Photo duel choices
- `feedCooldown/{id}`: 30-day cooldown tracking
- `likes/{id}`: Like system
- `matches/{id}`: Mutual likes
- `inboxStates/{uid}`: Inbox badge counts

## Setup Instructions

### 1. Firebase Configuration
1. Create a new Firebase project
2. Enable Authentication (Google Sign-In)
3. Enable Firestore Database
4. Enable Storage
5. Download `google-services.json` and place in `android/app/`
6. Update `lib/firebase_options.dart` with your project configuration

### 2. Android Setup
1. Ensure you have Android SDK 34 installed
2. Update `android/app/build.gradle` with your package name
3. Configure Google Sign-In in Firebase Console

### 3. Dependencies
```bash
flutter pub get
```

### 4. Run the App
```bash
flutter run
```

## Security Rules

### Firestore Rules
- Users can read all user profiles
- Users can only write their own data
- Photos are publicly readable
- All social features require authentication

### Storage Rules
- Users can upload to their own folder
- Photos are publicly readable

## Key Features Implementation

### Photo Duel Algorithm
1. Filter users with `profileCompleted = true` and ≥2 photos
2. Apply 30-day cooldown filter
3. Select photos with lowest exposure count
4. Prefer photos with similar selection ratios
5. Update exposure/chosen counts atomically

### Profile Completion Gating
- Sending likes requires completed profile
- Viewing inbox requires completed profile
- Viewing additional photos requires completed profile
- Modal prompts guide users to complete profile

### Like System
- Send like creates pending like document
- Accept like updates status and checks for mutual like
- Mutual likes create match and reveal phone numbers
- Inbox badge shows pending like count

## Development Notes

### State Management
- Uses Riverpod for state management
- Providers for authentication, likes, photos, etc.
- AsyncValue for loading states

### Navigation
- go_router for navigation
- Route guards for profile completion
- Deep linking support

### Image Handling
- image_picker for photo selection
- cached_network_image for efficient loading
- Firebase Storage for photo uploads

### Error Handling
- Comprehensive error handling throughout
- User-friendly error messages
- Retry mechanisms for failed operations

## Future Enhancements

### Planned Features (Stubs Ready)
- Kakao/Apple Sign-In integration
- Push notifications (FCM)
- Search/Explore functionality
- Report/Block system
- Advanced photo editing
- Video support

### Performance Optimizations
- Photo thumbnail generation
- Pagination for large lists
- Caching strategies
- Background sync

## Testing Checklist

- [ ] Google Sign-In works
- [ ] User document created on first login
- [ ] Profile setup wizard completes successfully
- [ ] Photo uploads work correctly
- [ ] Photo duels display and function properly
- [ ] Like system works end-to-end
- [ ] Inbox shows pending likes
- [ ] Profile completion gating works
- [ ] Stats display correctly
- [ ] Logout returns to onboarding

## Contributing

1. Follow Flutter/Dart style guidelines
2. Use meaningful commit messages
3. Test on both debug and release builds
4. Update documentation for new features

## License

This project is for educational/demonstration purposes.
