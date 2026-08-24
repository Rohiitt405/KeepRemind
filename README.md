# KeepRemind - Smart Link Bookmark & AI Memory Assistant

**KeepRemind** is a Flutter mobile app that helps you save, organize, and revisit interesting content from Instagram, YouTube, X, Reddit, Facebook and other platforms.

Instead of simply bookmarking links, KeepRemind automatically extracts metadata, generates AI-powered memory notes and tags using Google Gemini, and reminds you to revisit your saved content so you never forget why it mattered.


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
  <img src="assets/screenshots/Add.jpg" width="700" alt="Add content Screen">
</p>

</details>

---

## 📱 Features

### Core Functionality
- **🔗 Save Content** - Quickly save contents links directly from the share sheet
- **🌐 Multi-Platform Support** - Save content from YouTube, Instagram, TikTok, Reddit, Facebook, X (Twitter), LinkedIn, Pinterest, Threads, Snapchat, and websites supporting Open Graph metadata.
- **🤖 AI Memory Generation** - Automatically generate personalized memory notes and tags for each saved savedLink using Google's Gemini AI
- **📝 Smart Organization** - Organize contents into reviewed/unreviewed categories with intuitive tabs
- **🔔 Reminders** - Set flexible reminders (daily or weekly) to review your saved content
- **🎯 Share Intent Support** - Share links directly to KeepRemind from any app
- **📌 Smart Metadata Extraction** - Automatically extracts titles, descriptions, thumbnails, and platform information using Open Graph metadata with graceful fallback support when metadata is unavailable.
- **🧠 Intelligent Platform Detection** - Automatically detects the source platform and adapts metadata extraction and UI presentation accordingly.
- **🗑️ Easy Management** - Swipe to delete savedLinks content with confirmation dialogs
- **🔄 Automatic Update Checker** - Automatically checks GitHub Releases for newer app versions and notifies users with release notes and a direct APK download.
- **⏭️ Skip Update Version** - Users can skip a specific app version and will only be notified again when a newer version is available.
- **✨ Material Design 3** - Modern, intuitive UI with deep purple theme

### AI-Powered Features
- **Memory Notes** - Get concise, under-20-word memory prompts for why you saved each link
- **Smart Tags** - Auto-generate relevant tags for content categorization
- **Intelligent Retries** - Automatic retry logic for AI generation with exponential backoff
- **Background Processing** - AI generation happens in the background without blocking the UI

---

## 🌐 Supported Platforms
| Platform | Metadata | AI Memory | Status |
|----------|----------|-----------|--------|
| YouTube | ✅ | ✅ | Fully Supported |
| Instagram | ✅ | ✅ | Fully Supported |
| Reddit | ✅ | ✅ | Fully Supported |
| LinkedIn | ✅ | ✅ | Fully Supported |
| Pinterest | ✅ | ✅ | Fully Supported |
| Facebook | ⚠ Fallback | ✅ | Supported |
| Threads | ⚠ Fallback | ✅ | Supported |
| Snapchat | ⚠ Fallback | ✅ | Supported |
| X (Twitter) | ✅ | ✅ | Fully Supported |
| Other Websites | Open Graph | ✅ | Supported |

---

## 🔄 Automatic Update System

KeepRemind includes a built-in update checker powered by GitHub Releases.

### How it works

1. The app checks the latest GitHub release.
2. It compares the installed version with the latest available version using semantic version comparison.
3. If a newer version is available, users receive an update dialog.
4. Users can view the release notes and compare the current version with the latest version.
5. Tapping **Update Now** opens the latest APK download.
6. Users can choose **Skip Version** if they don't want to update to the current release.
7. The skipped version is stored locally on the device using SharedPreferences.
8. The skipped version will not be shown again during future update checks.
9. When a newer version is released, the update notification will appear again automatically.

### Skip Version Behavior

The skip feature applies only to the specific version that the user chooses to skip.

For example:

```text
Current Version: 1.0.0
Latest Version:  1.2.0
        ↓
User selects "SKIP VERSION"
        ↓
Skipped Version: 1.2.0

---
## 🏗️ Architecture

```text
lib/
├── main.dart                             # Application entry point
├── app.dart                              # Root widget and app configuration
├── firebase_options.dart                 # Firebase configuration
│
├── constants/
│   ├── app_theme.dart                    # Application theme configuration
│   └── github_constants.dart             # GitHub repository and API constants
│
├── models/
│   ├── ai_memory.dart                    # AI memory response model
│   ├── link_metadata.dart                # Link metadata model
│   ├── saved_link_model.dart             # Saved link model
│   ├── social_platform.dart              # Supported social media platforms
│   └── update_info.dart                  # App update information model
│
├── providers/
│   ├── saved_link_provider.dart          # Saved links state management
│   └── update_provider.dart              # Update checking and skip-version state management
│
├── screens/
│   ├── add_url_screen.dart               # Add URL screen
│   ├── detail_screen.dart                # Saved link details
│   ├── home_screen.dart                  # Main application screen
│   ├── onboarding_screen.dart            # First-time user experience
│   ├── settings_screen.dart              # Application settings
│   ├── share_loading_screen.dart         # Shared URL processing screen
│   └── splash_screen.dart                # Splash screen
│
├── services/
│   ├── metadata/
│   │   ├── fallback_metadata_service.dart    # Fallback metadata extraction
│   │   ├── metadata_fetch_service.dart       # HTTP metadata fetching
│   │   ├── metadata_service.dart             # Metadata service facade
│   │   └── platform_detector_service.dart    # Detect social media platform
│   │
│   ├── ai_service.dart                   # AI memory generation
│   ├── firestore_service.dart            # Firestore database operations
│   ├── notification_service.dart         # Local notification scheduling
│   ├── settings_service.dart             # Local settings and SharedPreferences management
│   └── update_service.dart               # GitHub release update checker
│
├── utils/
│   └── version_helper.dart               # Semantic version comparison helper
│
├── widgets/
│   ├── save_link_card.dart               # Saved link card widget
│   ├── update_dialog.dart                # Update dialog with update and skip-version actions
│   │
│   └── shared/
│       ├── dot_grid_overlay.dart         # Dot grid background overlay
│       └── neo_brutalist_button.dart     # Reusable Neo-Brutalist button
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

## 🔍 Metadata Processing Pipeline

When a link is added, KeepRemind processes it using the following pipeline:

URL
↓
Platform Detection
↓
Metadata Extraction
↓
Fallback Metadata (if needed)
↓
Save to Firestore
↓
AI Memory Generation
↓
Automatic Reminder Scheduling

This modular architecture allows new social platforms to be added with minimal changes.

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

The app uses anonymous Firebase authentication. Firestore is configured to store user savedLink under:
```
users/{userId}/saved_links/
```

Ensure your Firestore security rules allow anonymous users:
```firestore
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write:
          if request.auth != null &&
             request.auth.uid == userId;
        
      match /saved_links/{savedLinkId} {
        allow read, write:
            if request.auth != null &&
               request.auth.uid == userId;
      }
    }
  }
}
```

---

## 📚 Key Components

### SavedLink Model
Represents a saved link with metadata and AI-generated insights:

```dart
SavedLink(
  id: String,                    // Firestore document ID
  url: String,                   // Video URL
  title: String,                 // Video title
  caption: String,               // Video description
  thumbnailUrl: String,          // Video thumbnail
  platform: SocialPlatform,              // 'Major socialMedia Platforms'
  aiMemory: String?,             // AI-generated memory note
  aiTags: List<String>?,         // AI-generated tags
  isGenerating: bool,            // AI generation in progress
  savedAt: DateTime,             // Save timestamp
  isReviewed: bool,              // Review status
)
```

### SavedLinkProvider
Manages the entire savedLink lifecycle:
- Listen to real-time Firestore updates
- Save link with URL validation
- Generate AI insights with retry logic
- Schedule reminders on save
- Mark content as reviewed/deleted

### FirestoreService
Handles database operations:
- Anonymous authentication
- Real-time savedLink stream
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

### Update Service

Handles application version checking through GitHub Releases:

- Fetches the latest GitHub release
- Compares the installed version with the latest release
- Detects available updates using semantic version comparison
- Provides release notes and APK download information
- Checks whether the latest version was previously skipped

### Update Provider

Manages update-checking state and skip-version behavior:

- Tracks update checking state
- Stores available update information
- Handles skip-version actions
- Persists skipped versions through SharedPreferences
- Prevents the same skipped version from being shown again

---

## 🔄 User Flow

### Onboarding
1. First-time users see the onboarding screen
2. Instructions on how to share savedLinks to the app
3. Optional notification permission request
4. Stores onboarding completion in SharedPreferences

### Saving a Link
Paste or share a supported social media link
        ↓
Platform Detection
        ↓
Fetch Metadata (title, description, thumbnail)
        ↓
Save to Firestore (isGenerating: true)
        ↓
Show content in UI Immediately
        ↓
┌─────────────────────────────────────┐
│ Background Processing               │
│ • Generate AI Memory                │
│ • Generate Tags                     │
│ • Schedule Weekly Reminder          │
└─────────────────────────────────────┘
        ↓
Real-time UI Update as AI Completes

### Reviewing savedLinks
1. Home screen displays savedLink in three tabs: All, Unreviewed, Reviewed
2. Tap a savedLink to view full details with thumbnail and AI insights
3. Mark as reviewed to track progress
4. Swipe to delete with confirmation

### Settings
- Toggle notification mode (daily/weekly)
- Set reminder day and time
- View app info

---

## 🌍 Supported Link Types

KeepRemind supports multiple kinds of content, including:

- Short-form videos
- Long-form videos
- Social media posts
- Articles
- Blogs
- GitHub repositories
- Documentation
- News pages
- Educational resources
- Open Graph enabled websites

---

## 🔐 Security & Privacy

- **Anonymous Authentication**: No user login required; each device gets unique Firebase UID
- **Data Isolation**: Each user's savedLinks are isolated in their own Firestore subcollection
- **No Personal Data**: App doesn't collect emails, names, or identifiable info
- **Local-Only Settings**: Reminder preferences and skipped update versions are stored locally on the device
- **Third-party Links**: Supports major social media platforms and websites that expose Open Graph metadata.

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
- `font_awesome_flutter` - Font Awesome social media and UI icons

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
- [ ] Export content to PDF
- [ ] Dark mode support
- [ ] Multi-language support
- [ ] Cloud backup and sync across devices
- [ ] Social sharing features
- [ ] Saved link insights dashboard
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
