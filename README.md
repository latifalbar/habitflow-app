# 🌱 HabitFlow - Beautiful Habit Tracker

Modern, gamified habit tracking app built with Flutter. Transform your daily routines into a fun, engaging journey with beautiful UI, smart insights, and powerful analytics.

![HabitFlow Banner](assets/images/banner.png)

## ✨ Features

### 🎯 Core Features
- **Smart Habit Tracking**: Create and track unlimited habits with flexible scheduling
- **Beautiful UI**: Material Design 3 with custom themes and smooth animations
- **Gamification**: XP system, levels, achievements, and virtual garden
- **Streak System**: Visual streak tracking with freeze and recovery options
- **Analytics**: Detailed insights, heatmaps, and pattern recognition
- **Offline-First**: Works seamlessly without internet connection

### 🚀 Premium Features
- **AI Insights**: Smart recommendations based on your patterns
- **Advanced Analytics**: Correlation analysis and custom reports
- **Unlimited Habits**: No restrictions on habit creation
- **Custom Themes**: Create and share your own themes
- **Data Export**: Export your data in CSV/PDF format
- **Priority Sync**: Faster cloud synchronization

### 🎮 Gamification
- **XP & Leveling**: Earn experience points and level up
- **Achievement System**: 30+ achievements to unlock
- **Virtual Garden**: Watch your habits grow into a beautiful garden
- **Coins Economy**: Earn and spend coins on rewards
- **Streak Rewards**: Special bonuses for maintaining streaks

## 🛠 Tech Stack

- **Framework**: Flutter 3.6+
- **Language**: Dart
- **State Management**: Riverpod
- **Local Storage**: Hive
- **Backend**: Firebase (Auth, Firestore, Analytics)
- **Charts**: FL Chart
- **Animations**: Flutter Animate, Lottie
- **IAP**: RevenueCat

## 📱 Screenshots

| Home Screen | Habit Detail | Analytics | Garden |
|-------------|--------------|-----------|---------|
| ![Home](assets/images/screenshots/home.png) | ![Detail](assets/images/screenshots/detail.png) | ![Analytics](assets/images/screenshots/analytics.png) | ![Garden](assets/images/screenshots/garden.png) |

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.6.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Firebase project (for backend features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/habitflow.git
   cd habitflow
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Setup Firebase** (Optional for local development)
   - Create a Firebase project
   - Add `google-services.json` to `android/app/`
   - Add `GoogleService-Info.plist` to `ios/Runner/`
   - Run `flutterfire configure`

4. **Run the app**
   ```bash
   flutter run
   ```

### Development Setup

1. **Install code generation tools**
   ```bash
   flutter packages pub run build_runner build
   ```

2. **Run tests**
   ```bash
   flutter test
   ```

3. **Build for production**
   ```bash
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── app.dart                  # App configuration
├── core/                     # Core functionality
│   ├── constants/           # App constants
│   ├── theme/               # Theme configuration
│   ├── utils/               # Utility functions
│   └── router/              # Navigation setup
├── data/                     # Data layer
│   ├── models/              # Data models
│   ├── repositories/        # Data repositories
│   └── services/            # External services
├── domain/                   # Business logic
│   ├── entities/            # Domain entities
│   └── usecases/            # Use cases
└── presentation/             # UI layer
    ├── screens/             # App screens
    ├── widgets/             # Reusable widgets
    └── providers/           # State providers
```

## 🎨 Design System

### Colors
- **Primary**: Ocean Blue (#2196F3)
- **Secondary**: Forest Green (#4CAF50)
- **Accent**: Sunset Orange (#FF9800)
- **Surface**: Light Gray (#F5F5F5)
- **Error**: Red (#F44336)

### Typography
- **Headings**: Poppins (Medium, SemiBold, Bold)
- **Body**: Inter (Regular, Medium, SemiBold)

### Components
- Material Design 3 components
- Custom animations and transitions
- Responsive design for all screen sizes

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## 📦 Building & Deployment

### Android
```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### iOS
```bash
# Build for iOS
flutter build ios --release

# Archive for App Store
flutter build ipa --release
```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Workflow

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter](https://flutter.dev/) - The amazing UI toolkit
- [Firebase](https://firebase.google.com/) - Backend services
- [Material Design](https://material.io/) - Design system
- [Unsplash](https://unsplash.com/) - Beautiful images

## 📞 Support

- 📧 Email: support@habitflow.app
- 🐛 Issues: [GitHub Issues](https://github.com/yourusername/habitflow/issues)
- 💬 Discord: [Join our community](https://discord.gg/habitflow)

## 🗺 Roadmap

See our [Roadmap](docs/ROADMAP.md) for upcoming features and improvements.

---

Made with ❤️ by the HabitFlow team