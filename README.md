# KeepRemind - Smart Video Bookmark & Memory Assistant

**KeepRemind** is a Flutter-based mobile application that helps users save, organize, and remember short-form videos (reels) from Instagram and YouTube with AI-powered memory insights and smart reminders.

**Release:** v1.0.0 (Build 1)

[⬇️ Download APK](https://github.com/Rohiitt405/KeepRemind/releases/tag/v1.0.0)

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
- **✨ Material Design 3** - Modern, intuitive UI with deep purple theme

### AI-Powered Features
- **Memory Notes** - Get concise, under-20-word memory prompts for why you saved each reel
- **Smart Tags** - Auto-generate relevant tags for content categorization
- **Intelligent Retries** - Automatic retry logic for AI generation with exponential backoff
- **Background Processing** - AI generation happens in the background without blocking the UI

---

## 🏗️ Architecture

### Project Structure

```
lib/
├── main.dart                          # App entry point with Firebase & notification initialization
├── app.dart                           # Main app widget with routing & share intent handling
├── firebase_options.dart              # Firebase configuration for all platforms
│
├── models/
│   ├── reel_item.dart                # ReelItem data model with serialization
│   └── ai_memory.dart                # AI memory response model
│
├── providers/
│   └── reel_provider.dart            # State management (ChangeNotifier pattern)
│
├── services/
│   ├── firestore_service.dart        # Firestore database operations
│   ├── metadata_service.dart         # URL parsing & metadata extraction
│   ├── ai_service.dart               # AI memory generation using Gemini
│   ├── notification_service.dart     # Local notifications scheduling
│   └── settings_service.dart         # User preferences (SharedPreferences)
│
├── screens/
│   ├── home_screen.dart              # Main dashboard with tabbed views
│   ├── detail_screen.dart            # Detailed reel view with full metadata
│   ├── add_url_screen.dart           # URL input and preview screen
│   ├── onboarding_screen.dart        # First-time user tutorial
│   └── settings_screen.dart          # App settings and notification preferences
│
└── widgets/
    └── reel_card.dart                # Reusable reel card component
```

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
   git clone https://github.com/Rohiitt405/Volt.git
   cd Volt
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

This project is private. For access or collaboration, contact the repository owner.

---

## 👤 Author

**Rohiitt405** - [GitHub Profile](https://github.com/Rohiitt405)

---

## 🤝 Contributing

This is a private project. For feature requests or bug reports, please open an issue on GitHub.

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
