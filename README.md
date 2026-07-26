# KeepRemind - Smart Video Bookmark & Memory Assistant

**KeepRemind** is a Flutter mobile app that helps you save, organize, and revisit interesting Instagram and YouTube content with AI-generated memory notes and reminders.

## 📥 Download

Download the latest Android APK from the latest GitHub Release.
[⬇️ Download APK](https://github.com/Rohiitt405/KeepRemind/releases/latest)

---
## 📸 App Screenshots

<details>
<summary><strong>Click to view app screenshots</strong> 📱</summary>

<br>

<p align="center">
  <img src="assets/screenshots/Onboard.jpg" width="700" alt="Onboarding Screen">
</p>

<p align="center">
  <img src="assets/screenshots/Home.jpg" width="700" alt="Home Screen">
</p>

<p align="center">
  <img src="assets/screenshots/Detail.jpg" width="700" alt="Detail Screen">
</p>

<p align="center">
  <img src="assets/screenshots/Reminder.jpg" width="700" alt="Reminder Screen">
</p>

<p align="center">
  <img src="assets/screenshots/Add.jpg" width="700" alt="Add Reel Screen">
</p>

</details>

---

## 📱 Features

### Core Functionality
- **📹 Save Video Reels** - Quickly save Instagram and YouTube video links directly from the share sheet
- **🤖 AI Memory Generation** - Automatically generate personalized memory notes and tags for each saved reel using Google's Gemini AI
- **📝 Smart Organization** - Organize reels into reviewed/unreviewed categories with intuitive tabs
- **🔔 Reminders** - Set flexible reminders (daily or weekly) to review your saved content
- **🎯 Share Intent Support** - Share links directly to KeepRemind from any app
- **📌 Metadata Extraction** - Auto-fetch video title, description, and thumbnail using Open Graph protocol
- **🗑️ Easy Management** - Swipe to delete reels with confirmation dialogs
- **🔄 Automatic Update Checker** - Automatically checks GitHub Releases for newer app versions and notifies users with release notes and a direct APK download.
- **✨ Material Design 3** - Modern, intuitive UI with deep purple theme

### AI-Powered Features
- **Memory Notes** - Get concise, under-20-word memory prompts for why you saved each reel
- **Smart Tags** - Auto-generate relevant tags for content categorization
- **Intelligent Retries** - Automatic retry logic for AI generation with exponential backoff
- **Background Processing** - AI generation happens in the background without blocking the UI

---

## 🔄 Automatic Update System

KeepRemind includes a built-in update checker powered by GitHub Releases.

### How it works

1. The app checks the latest GitHub release.
2. It compares the installed version with the latest available version.
3. If an update is available, users receive an update dialog.
4. Users can view release notes before updating.
5. Tapping **Update** opens the latest APK download.

### Benefits

- Automatic update notifications
- Semantic version comparison
- Release notes support
- Direct APK downloads
- Reduced network requests through cached update checks

---
## 🏗️ Architecture

```text
lib/
├── main.dart                          # Application entry point
├── app.dart                           # Root widget and app configuration
├── firebase_options.dart              # Firebase configuration
│
├── constants/
│   └── github_constants.dart          # GitHub repository and API constants
│
├── models/
│   ├── reel_item.dart                 # Reel data model
│   ├── ai_memory.dart                 # AI memory response model
│   └── update_info.dart               # App update information model
│
├── providers/
│   ├── reel_provider.dart             # Reel state management
│   └── update_provider.dart           # Update checking state management
│
├── services/
│   ├── firestore_service.dart         # Firestore database operations
│   ├── metadata_service.dart          # Video metadata extraction
│   ├── ai_service.dart                # AI memory generation
│   ├── notification_service.dart      # Local notification scheduling
│   ├── settings_service.dart          # SharedPreferences management
│   └── update_service.dart            # GitHub release update checker
│
├── utils/
│   └── version_helper.dart            # Semantic version comparison helper
│
├── screens/
│   ├── home_screen.dart               # Main application screen
│   ├── detail_screen.dart             # Reel details
│   ├── add_url_screen.dart            # Add new reel
│   ├── onboarding_screen.dart         # First-time user experience
│   └── settings_screen.dart           # Application settings
│
└── widgets/
    ├── reel_card.dart                 # Reusable reel card widget
    └── update_dialog.dart             # Update available dialog
```

### Folder Overview

| Folder | Description |
|---------|-------------|
| **constants/** | Stores application-wide constant values such as API endpoints and configuration. |
| **models/** | Contains data models used throughout the application. |
| **providers/** | Manages application state using the Provider package. |
| **services/** | Contains business logic, Firebase operations, AI integration, notifications, and update checking. |
| **utils/** | Utility classes and helper functions shared across the project. |
| **screens/** | UI screens that represent complete pages of the application. |
| **widgets/** | Reusable UI components shared between multiple screens. |

### Technology Stack

| Category | Technology |
|----------|-----------|
| **Frontend** | Flutter 3.9.2+ |
| **State Management** | Provider 6.1.5 |
| **Backend** | Firebase (Auth, Firestore, Storage) |
| **AI** | Google Gemini 3.5 Flash (via Firebase AI) |
| **Notifications** | flutter_local_notifications |
| **Data Persistence** | Cloud Firestore + SharedPreferences |
| **Metadata Extraction** | metadata_fetch |
| **UI Design** | Material Design 3 |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Android Studio or Xcode for platform setup
- Firebase project with enabled services
- Google Cloud project with Gemini API access

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Rohiitt405/KeepRemind.git
    cd KeepRemind
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase**
   ```bash
   flutterfire configure
   ```
   This will generate `firebase_options.dart` with your Firebase configuration.

4. **Run the app**
   ```bash
   flutter run
   ```

### Environment Setup

The app uses anonymous Firebase authentication. Firestore is configured to store user reels under:
```
users/{userId}/reels/
```

Ensure your Firestore security rules allow anonymous users:
```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/reels/{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 📚 Key Components

### ReelItem Model
Represents a saved reel with metadata and AI-generated insights:

```dart
ReelItem(
  id: String,                    // Firestore document ID
  url: String,                   // Video URL
  title: String,                 // Video title
  caption: String,               // Video description
  thumbnailUrl: String,          // Video thumbnail
  platform: String,              // 'instagram' or 'youtube'
  aiMemory: String?,             // AI-generated memory note
  aiTags: List<String>?,         // AI-generated tags
  isGenerating: bool,            // AI generation in progress
  savedAt: DateTime,             // Save timestamp
  isReviewed: bool,              // Review status
)
```

### ReelProvider
Manages the entire reel lifecycle:
- Listen to real-time Firestore updates
- Save reels with URL validation
- Generate AI insights with retry logic
- Schedule reminders on save
- Mark reels as reviewed/deleted

### FirestoreService
Handles database operations:
- Anonymous authentication
- Real-time reel stream
- CRUD operations
- User-scoped data isolation

### AI Service
Generates memory and tags using Gemini:
- Parses AI JSON responses with fallback handling
- Implements exponential retry strategy
- Handles transient API errors gracefully
- Flexible tag extraction (array or string format)

### Notification Service
Manages reminders:
- Weekly reminder on specific weekday
- Daily reminder at set time
- Timezone-aware scheduling
- Singleton pattern for consistency

---

## 🔄 User Flow

### Onboarding
1. First-time users see the onboarding screen
2. Instructions on how to share reels to the app
3. Optional notification permission request
4. Stores onboarding completion in SharedPreferences

### Adding a Reel
1. User shares Instagram/YouTube link or uses in-app URL input
2. App fetches metadata (title, description, thumbnail)
3. Reel is saved immediately to Firestore with `isGenerating: true`
4. AI service generates memory and tags in background
5. Weekly reminder is scheduled automatically
6. UI updates in real-time as AI completes

### Reviewing Reels
1. Home screen displays reels in three tabs: All, Unreviewed, Reviewed
2. Tap a reel to view full details with thumbnail and AI insights
3. Mark as reviewed to track progress
4. Swipe to delete with confirmation

### Settings
- Toggle notification mode (daily/weekly)
- Set reminder day and time
- View app info

---

## 🔐 Security & Privacy

- **Anonymous Authentication**: No user login required; each device gets unique Firebase UID
- **Data Isolation**: Each user's reels are isolated in their own Firestore subcollection
- **No Personal Data**: App doesn't collect emails, names, or identifiable info
- **Local-Only Settings**: Reminder preferences stored locally on device
- **Third-party Links**: Only Instagram and YouTube URLs are supported

---

## 📦 Dependencies

### Production
- `flutter` - UI framework
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Real-time database
- `firebase_auth` - Authentication
- `firebase_storage` - File storage
- `firebase_ai` - Gemini AI integration
- `provider` - State management
- `metadata_fetch` - URL metadata extraction
- `flutter_local_notifications` - Local reminders
- `timezone` / `flutter_timezone` - Timezone handling
- `receive_sharing_intent` - Share sheet integration
- `shared_preferences` - Local storage
- `cached_network_image` - Image caching
- `url_launcher` - Open external links
- `google_fonts` - Custom fonts
- `http` - HTTP networking
- `package_info_plus` - App version information

### Development
- `flutter_lints` - Code quality
- `flutter_launcher_icons` - App icon generation

---

## 🛠️ Development Guide

### Adding a New Feature

1. **Create a Model** (if needed) in `lib/models/`
2. **Create a Service** in `lib/services/` for business logic
3. **Create a Provider** in `lib/providers/` for state management
4. **Create UI Screens** in `lib/screens/`
5. **Create Reusable Widgets** in `lib/widgets/`
6. **Update routing** in `app.dart`
7. Publish APKs through GitHub Releases for automatic update detection.

### Key Patterns Used

- **Provider Pattern**: ChangeNotifier for reactive state updates
- **Service Locator**: Direct service instantiation (consider GetIt for scale)
- **Stream-based Updates**: Firestore snapshots for real-time data
- **Error Handling**: Try-catch with user-friendly messages
- **Async Operations**: Future-based with loading states

---

## 🐛 Debugging

Enable debug logs:
```dart
debugPrint('Your debug message');
debugPrintStack();
```

View Firebase logs:
```bash
flutter logs
```

---

## 📝 License

This repository is publicly available on GitHub for learning, reference, and portfolio purposes.

Unless otherwise stated, all rights to the source code remain with the repository owner.

---

## 👤 Author

**Rohiitt405** - [GitHub Profile](https://github.com/Rohiitt405)

---

## 🤝 Contributing

Contributions are welcome! 🎉

If you'd like to improve KeepRemind, please follow these steps:

### 1. Fork the Repository

Click the **Fork** button at the top-right of this repository to create your own copy.

### 2. Clone Your Fork

```bash
git clone https://github.com/<your-username>/KeepRemind.git
cd KeepRemind
```

### 3. Create a New Branch

```bash
git checkout -b feature/your-feature-name
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Make Your Changes

Implement your feature or fix the issue while following the existing project structure and coding style.

### 6. Test Your Changes

Ensure the application builds and runs successfully.

```bash
flutter test
```

or

```bash
flutter run
```

### 7. Commit Your Changes

```bash
git add .
git commit -m "feat: add your feature description"
```

### 8. Push Your Branch

```bash
git push origin feature/your-feature-name
```

### 9. Open a Pull Request

Create a Pull Request describing:

- What was changed
- Why the change was made
- Screenshots (if the UI was modified)
- Related issues (if applicable)

### Contribution Guidelines

- Follow Flutter and Dart best practices.
- Keep pull requests focused on a single feature or bug fix.
- Write clean, readable, and maintainable code.
- Update the README if your changes introduce new functionality.
- Ensure the application builds successfully before submitting a pull request.

---

## ✨ Roadmap

- [ ] Search and filter functionality
- [ ] Export reels to PDF
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Cloud backup and sync across devices
- [ ] Social sharing features
- [ ] Reel analytics dashboard
- [ ] Custom tags and collections

---

## 📞 Support

For issues or questions:
1. Check existing GitHub issues
2. Review error logs in Flutter DevTools
3. Check Firebase console for backend issues
4. Contact the author via GitHub

---

**Made with ❤️ using Flutter**
