# Flutter

# NoteTask AI - Flutter Mobile Application

A comprehensive AI-powered note-taking and task management mobile application built with Flutter. This app provides intelligent note organization, task management, and AI-powered text processing capabilities.

## 🚀 Features

### Core Functionality
- **Smart Note Taking**: Create, edit, and organize notes with rich text formatting
- **Task Management**: Complete task management with due dates, categories, and completion tracking
- **AI Integration**: Powered by Perplexity AI for text summarization, grammar checking, rewriting, and idea generation
- **Visual Customization**: Customize fonts, colors, and backgrounds for personalized experience
- **Organization**: Folders, tags, pinning, and archiving for efficient organization
- **Search**: Advanced search functionality across all notes and tasks
- **Offline-First**: Works seamlessly offline with automatic sync when online

### Authentication & Security
- **Email/Password Authentication**: Secure user registration and login
- **Google Sign-In**: Quick authentication with Google accounts
- **Biometric Authentication**: Fingerprint and face ID support
- **Data Encryption**: Secure data storage and transmission

### Mobile-Optimized Features
- **Responsive Design**: Optimized for all screen sizes and orientations
- **Native Gestures**: Swipe actions, pull-to-refresh, and intuitive interactions
- **Voice Input**: Speech-to-text functionality for hands-free note creation
- **Push Notifications**: Smart reminders for tasks and important notes
- **Auto-Save**: Automatic saving with visual indicators

### AI-Powered Capabilities
- **Text Summarization**: AI-powered content summarization
- **Grammar Correction**: Intelligent grammar and style checking
- **Content Rewriting**: Improve clarity and readability
- **Idea Generation**: AI-generated suggestions and ideas
- **Smart Suggestions**: Contextual recommendations based on your content

## 📋 Prerequisites

- Flutter SDK (^3.29.2)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android SDK / Xcode (for iOS development)

## 🛠️ Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the application:

To run the app with environment variables defined in an env.json file, follow the steps mentioned below:
1. Through CLI
    ```bash
    flutter run --dart-define-from-file=env.json
    ```
2. For VSCode
    - Open .vscode/launch.json (create it if it doesn't exist).
    - Add or modify your launch configuration to include --dart-define-from-file:
    ```json
    {
        "version": "0.2.0",
        "configurations": [
            {
                "name": "Launch",
                "request": "launch",
                "type": "dart",
                "program": "lib/main.dart",
                "args": [
                    "--dart-define-from-file",
                    "env.json"
                ]
            }
        ]
    }
    ```
3. For IntelliJ / Android Studio
    - Go to Run > Edit Configurations.
    - Select your Flutter configuration or create a new one.
    - Add the following to the "Additional arguments" field:
    ```bash
    --dart-define-from-file=env.json
    ```

## 📁 Project Structure

```
flutter_app/
├── android/            # Android-specific configuration
├── ios/                # iOS-specific configuration
├── lib/
│   ├── core/           # Core utilities and services
│   │   └── utils/      # Utility classes
│   ├── services/       # Business logic and API services
│   │   ├── auth_service.dart
│   │   ├── notes_service.dart
│   │   ├── ai_service.dart
│   │   ├── user_service.dart
│   │   ├── voice_service.dart
│   │   ├── biometric_service.dart
│   │   └── notification_service.dart
│   ├── presentation/   # UI screens and widgets
│   │   ├── splash_screen/
│   │   ├── onboarding_flow/
│   │   ├── login_screen/
│   │   ├── registration_screen/
│   │   ├── overview_screen/
│   │   ├── notes_screen/
│   │   ├── tasks_screen/
│   │   ├── ai_assistant_screen/
│   │   ├── note_editor_screen/
│   │   ├── search_screen/
│   │   ├── settings_screen/
│   │   └── profile_screen/
│   ├── routes/         # Application routing
│   ├── theme/          # Theme configuration
│   ├── widgets/        # Reusable UI components
│   └── main.dart       # Application entry point
├── supabase/           # Database migrations and configuration
│   └── migrations/     # SQL migration files
├── assets/             # Static assets (images, fonts, etc.)
├── pubspec.yaml        # Project dependencies and configuration
└── README.md           # Project documentation
```

## 🔧 Configuration

### Environment Variables
Create an `env.json` file in the root directory with the following structure:

```json
{
  "SUPABASE_URL": "your_supabase_url",
  "SUPABASE_ANON_KEY": "your_supabase_anon_key",
  "PERPLEXITY_API_KEY": "your_perplexity_api_key"
}
```

### Database Setup
1. Create a Supabase project
2. Run the migration files in `supabase/migrations/`
3. Configure Row Level Security (RLS) policies
4. Update environment variables with your Supabase credentials

### AI Integration
1. Sign up for Perplexity AI API
2. Get your API key
3. Add the key to your environment variables

## 🧩 Adding Routes

To add new routes to the application, update the `lib/routes/app_routes.dart` file:

```dart
import 'package:flutter/material.dart';
import 'package:package_name/presentation/home_screen/home_screen.dart';

class AppRoutes {
  static const String initial = '/';
  static const String home = '/home';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    home: (context) => const HomeScreen(),
    // Add more routes as needed
  }
}
```

## 🎨 Theming

This project includes a comprehensive theming system with both light and dark themes:

```dart
// Access the current theme
ThemeData theme = Theme.of(context);

// Use theme colors
Color primaryColor = theme.colorScheme.primary;
```

The theme configuration includes:
- Color schemes for light and dark modes
- Typography styles
- Button themes
- Input decoration themes
- Card and dialog themes

## 📱 Responsive Design

The app is built with responsive design using the Sizer package for consistent scaling across devices:

```dart
// Example of responsive sizing
Container(
  width: 50.w, // 50% of screen width
  height: 20.h, // 20% of screen height
  child: Text('Responsive Container'),
)
```

## 🤖 AI Features

The app integrates with Perplexity AI to provide intelligent text processing:

```dart
// Example AI usage
final aiService = AiService();
final enhancedText = await aiService.enhanceNote(
  title: 'My Note',
  content: 'Original content',
  enhancementType: 'grammar',
);
```

## 🔐 Security Features

- **Row Level Security**: Database-level security with Supabase RLS
- **Biometric Authentication**: Native fingerprint and face ID support
- **Data Encryption**: Secure storage and transmission
- **Offline Security**: Local data protection

## 📊 Performance

- **Offline-First Architecture**: Works without internet connection
- **Optimistic Updates**: Immediate UI updates with background sync
- **Efficient Caching**: Smart caching for improved performance
- **Memory Management**: Optimized for mobile devices

## 📦 Deployment

Build the application for production:

```bash
# For Android
flutter build apk --release

# For iOS
flutter build ios --release
```

### Testing
```bash
# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

## 🛠️ Development

### Code Structure
- **Services**: Business logic and API integrations
- **Presentation**: UI screens and widgets
- **Core**: Utilities and shared functionality
- **Theme**: Consistent design system

### Best Practices
- Clean Architecture principles
- Separation of concerns
- Responsive design patterns
- Error handling and user feedback
- Performance optimization

## 🙏 Acknowledgments
- Built with [Rocket.new](https://rocket.new)
- Powered by [Flutter](https://flutter.dev) & [Dart](https://dart.dev)
- Styled with Material Design 3
- AI powered by [Perplexity AI](https://perplexity.ai)
- Backend by [Supabase](https://supabase.com)

Built with ❤️ on Rocket.new