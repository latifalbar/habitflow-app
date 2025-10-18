# HabitFlow Architecture Documentation

This document describes the technical architecture of HabitFlow, including design patterns, data flow, and system components.

## 🏗️ Architecture Overview

HabitFlow follows **Clean Architecture** principles with a clear separation of concerns across multiple layers.

### Architecture Layers

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation Layer                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │   Screens   │ │   Widgets   │ │  Providers  │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                     Domain Layer                        │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │  Entities   │ │  Use Cases  │ │ Repositories│      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                      Data Layer                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │   Models    │ │Repositories │ │  Services   │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘
┌─────────────────────────────────────────────────────────┐
│                      Core Layer                         │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐      │
│  │  Constants  │ │   Theme     │ │   Utils     │      │
│  └─────────────┘ └─────────────┘ └─────────────┘      │
└─────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point
├── app.dart                     # App configuration
├── core/                        # Core functionality
│   ├── constants/              # App constants
│   │   ├── app_constants.dart  # General constants
│   │   ├── api_constants.dart  # API endpoints
│   │   └── storage_keys.dart   # Storage keys
│   ├── theme/                  # Theme configuration
│   │   ├── app_theme.dart      # Main theme
│   │   ├── app_colors.dart     # Color definitions
│   │   ├── app_text_styles.dart # Typography
│   │   └── app_spacing.dart    # Spacing system
│   ├── utils/                  # Utility functions
│   │   ├── date_utils.dart     # Date utilities
│   │   ├── validation_utils.dart # Input validation
│   │   └── extension_utils.dart # Dart extensions
│   └── router/                 # Navigation
│       ├── app_router.dart     # Main router
│       └── route_names.dart    # Route constants
├── data/                       # Data layer
│   ├── models/                 # Data models
│   │   ├── habit_model.dart    # Habit data model
│   │   ├── habit_log_model.dart # Habit log model
│   │   ├── user_model.dart     # User model
│   │   └── achievement_model.dart # Achievement model
│   ├── repositories/           # Data repositories
│   │   ├── habit_repository.dart # Habit data access
│   │   ├── user_repository.dart # User data access
│   │   └── achievement_repository.dart # Achievement data
│   └── services/               # External services
│       ├── firebase_service.dart # Firebase integration
│       ├── storage_service.dart # Local storage
│       └── analytics_service.dart # Analytics
├── domain/                     # Business logic
│   ├── entities/               # Domain entities
│   │   ├── habit.dart          # Habit entity
│   │   ├── habit_log.dart      # Habit log entity
│   │   ├── user.dart           # User entity
│   │   └── achievement.dart    # Achievement entity
│   └── usecases/               # Use cases
│       ├── create_habit.dart   # Create habit use case
│       ├── track_habit.dart    # Track habit use case
│       ├── calculate_streak.dart # Streak calculation
│       └── unlock_achievement.dart # Achievement logic
└── presentation/               # UI layer
    ├── screens/                # App screens
    │   ├── home/               # Home screen
    │   ├── habit_detail/       # Habit detail screen
    │   ├── add_habit/          # Add habit screen
    │   └── profile/            # Profile screen
    ├── widgets/                # Reusable widgets
    │   ├── common/             # Common widgets
    │   ├── habit/              # Habit-specific widgets
    │   └── charts/             # Chart widgets
    └── providers/              # State management
        ├── habit_provider.dart # Habit state
        ├── user_provider.dart  # User state
        └── theme_provider.dart # Theme state
```

## 🔄 Data Flow

### State Management with Riverpod

```dart
// Provider definition
@riverpod
class HabitNotifier extends _$HabitNotifier {
  @override
  List<Habit> build() => [];

  Future<void> createHabit(CreateHabitParams params) async {
    // 1. Validate input
    // 2. Call use case
    // 3. Update state
    // 4. Handle errors
  }
}

// Widget usage
class HabitList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitNotifierProvider);
    return ListView.builder(
      itemCount: habits.length,
      itemBuilder: (context, index) => HabitTile(habit: habits[index]),
    );
  }
}
```

### Data Flow Pattern

```
User Action → Widget → Provider → Use Case → Repository → Data Source
     ↑                                                           ↓
     └─────────────── State Update ←─────────────────────────────┘
```

## 🗄️ Data Storage

### Local Storage (Hive)

```dart
// Hive model
@HiveType(typeId: 0)
class HabitModel extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String description;
  
  // ... other fields
}

// Repository implementation
class HabitRepositoryImpl implements HabitRepository {
  final Box<HabitModel> _habitBox;
  
  @override
  Future<List<Habit>> getHabits() async {
    return _habitBox.values
        .map((model) => model.toEntity())
        .toList();
  }
  
  @override
  Future<void> saveHabit(Habit habit) async {
    final model = HabitModel.fromEntity(habit);
    await _habitBox.put(habit.id, model);
  }
}
```

### Cloud Storage (Firebase)

```dart
// Firebase service
class FirebaseService {
  final FirebaseFirestore _firestore;
  
  Future<void> syncHabits(String userId, List<Habit> habits) async {
    final batch = _firestore.batch();
    
    for (final habit in habits) {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habit.id);
      
      batch.set(docRef, habit.toJson());
    }
    
    await batch.commit();
  }
}
```

## 🎨 UI Architecture

### Theme System

```dart
// App theme configuration
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
    ),
    textTheme: AppTextStyles.lightTextTheme,
    // ... other theme properties
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
    ),
    textTheme: AppTextStyles.darkTextTheme,
    // ... other theme properties
  );
}
```

### Component Architecture

```dart
// Base widget class
abstract class BaseWidget extends StatelessWidget {
  const BaseWidget({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        return buildWidget(context, ref);
      },
    );
  }
  
  Widget buildWidget(BuildContext context, WidgetRef ref);
}

// Specific widget implementation
class HabitCard extends BaseWidget {
  final Habit habit;
  
  const HabitCard({Key? key, required this.habit}) : super(key: key);
  
  @override
  Widget buildWidget(BuildContext context, WidgetRef ref) {
    return Card(
      child: ListTile(
        title: Text(habit.name),
        subtitle: Text('Streak: ${habit.currentStreak}'),
        trailing: IconButton(
          icon: Icon(Icons.check),
          onPressed: () => _completeHabit(ref),
        ),
      ),
    );
  }
}
```

## 🔐 Security Architecture

### Data Encryption

```dart
// Encryption service
class EncryptionService {
  static const String _key = 'your-encryption-key';
  
  static String encrypt(String plainText) {
    final key = Key.fromBase64(_key);
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(plainText, iv: IV.fromLength(16));
    return encrypted.base64;
  }
  
  static String decrypt(String encryptedText) {
    final key = Key.fromBase64(_key);
    final encrypter = Encrypter(AES(key));
    final encrypted = Encrypted.fromBase64(encryptedText);
    return encrypter.decrypt(encrypted, iv: IV.fromLength(16));
  }
}
```

### Authentication Flow

```dart
// Authentication service
class AuthService {
  final FirebaseAuth _auth;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  Future<UserCredential> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } catch (e) {
      throw AuthException('Sign in failed: $e');
    }
  }
}
```

## 📊 Analytics Architecture

### Event Tracking

```dart
// Analytics service
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  
  Future<void> trackEvent(String eventName, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(
      name: eventName,
      parameters: parameters,
    );
  }
  
  Future<void> trackHabitCompleted(String habitId, int streak) async {
    await trackEvent('habit_completed', {
      'habit_id': habitId,
      'streak': streak,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
```

### Performance Monitoring

```dart
// Performance monitoring
class PerformanceService {
  final FirebasePerformance _performance;
  
  Future<T> measureOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    final trace = _performance.newTrace(operationName);
    await trace.start();
    
    try {
      final result = await operation();
      trace.putMetric('success', 1);
      return result;
    } catch (e) {
      trace.putMetric('error', 1);
      rethrow;
    } finally {
      await trace.stop();
    }
  }
}
```

## 🧪 Testing Architecture

### Unit Testing

```dart
// Use case testing
class CreateHabitTest {
  late CreateHabit useCase;
  late MockHabitRepository mockRepository;
  
  setUp(() {
    mockRepository = MockHabitRepository();
    useCase = CreateHabit(mockRepository);
  });
  
  test('should create habit successfully', () async {
    // Arrange
    final params = CreateHabitParams(name: 'Test Habit');
    when(mockRepository.saveHabit(any)).thenAnswer((_) async {});
    
    // Act
    await useCase(params);
    
    // Assert
    verify(mockRepository.saveHabit(any)).called(1);
  });
}
```

### Widget Testing

```dart
// Widget testing
class HabitCardTest {
  testWidgets('should display habit information', (tester) async {
    // Arrange
    final habit = Habit(
      id: '1',
      name: 'Test Habit',
      currentStreak: 5,
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: HabitCard(habit: habit),
      ),
    );
    
    // Assert
    expect(find.text('Test Habit'), findsOneWidget);
    expect(find.text('Streak: 5'), findsOneWidget);
  });
}
```

### Integration Testing

```dart
// Integration testing
class HabitFlowTest {
  testWidgets('complete habit flow', (tester) async {
    // Arrange
    await tester.pumpWidget(MyApp());
    
    // Act
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    
    await tester.enterText(find.byType(TextField), 'New Habit');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    
    // Assert
    expect(find.text('New Habit'), findsOneWidget);
  });
}
```

## 🚀 Performance Architecture

### Lazy Loading

```dart
// Lazy loading implementation
class LazyHabitList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final habitsAsync = ref.watch(habitsProvider);
        
        return habitsAsync.when(
          data: (habits) => ListView.builder(
            itemCount: habits.length,
            itemBuilder: (context, index) {
              if (index >= habits.length - 5) {
                // Load more when near end
                ref.read(loadMoreHabitsProvider.notifier).loadMore();
              }
              return HabitTile(habit: habits[index]);
            },
          ),
          loading: () => CircularProgressIndicator(),
          error: (error, stack) => Text('Error: $error'),
        );
      },
    );
  }
}
```

### Caching Strategy

```dart
// Cache implementation
class CacheService {
  final Map<String, dynamic> _cache = {};
  final Duration _defaultTtl = Duration(minutes: 5);
  
  T? get<T>(String key) {
    final item = _cache[key];
    if (item == null) return null;
    
    final cacheItem = item as CacheItem<T>;
    if (cacheItem.isExpired) {
      _cache.remove(key);
      return null;
    }
    
    return cacheItem.data;
  }
  
  void set<T>(String key, T data, {Duration? ttl}) {
    _cache[key] = CacheItem(
      data: data,
      expiresAt: DateTime.now().add(ttl ?? _defaultTtl),
    );
  }
}
```

## 🔄 Offline-First Architecture

### Sync Strategy

```dart
// Sync service
class SyncService {
  final LocalRepository _localRepo;
  final RemoteRepository _remoteRepo;
  final Queue<SyncOperation> _syncQueue = Queue();
  
  Future<void> syncData() async {
    if (!await _isOnline()) return;
    
    // Process sync queue
    while (_syncQueue.isNotEmpty) {
      final operation = _syncQueue.removeFirst();
      await _processSyncOperation(operation);
    }
    
    // Pull remote changes
    await _pullRemoteChanges();
  }
  
  Future<void> _processSyncOperation(SyncOperation operation) async {
    try {
      switch (operation.type) {
        case SyncType.create:
          await _remoteRepo.create(operation.data);
          break;
        case SyncType.update:
          await _remoteRepo.update(operation.data);
          break;
        case SyncType.delete:
          await _remoteRepo.delete(operation.id);
          break;
      }
    } catch (e) {
      // Re-queue failed operations
      _syncQueue.add(operation);
    }
  }
}
```

## 📱 Platform-Specific Architecture

### Android Configuration

```dart
// Android-specific setup
class AndroidConfig {
  static void configure() {
    // Set up Android-specific configurations
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }
}
```

### iOS Configuration

```dart
// iOS-specific setup
class IOSConfig {
  static void configure() {
    // Set up iOS-specific configurations
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
      ),
    );
  }
}
```

## 🔧 Development Tools

### Code Generation

```dart
// Build runner configuration
// build.yaml
targets:
  $default:
    builders:
      riverpod_generator:
        options:
          # Riverpod generator options
      hive_generator:
        options:
          # Hive generator options
```

### Linting Configuration

```yaml
# analysis_options.yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    # Custom linting rules
    prefer_const_constructors: true
    prefer_const_literals_to_create_immutables: true
    avoid_print: true
```

## 📈 Monitoring & Observability

### Error Tracking

```dart
// Error tracking service
class ErrorTrackingService {
  final FirebaseCrashlytics _crashlytics;
  
  Future<void> recordError(dynamic error, StackTrace stackTrace) async {
    await _crashlytics.recordError(error, stackTrace);
  }
  
  Future<void> setUserIdentifier(String userId) async {
    await _crashlytics.setUserIdentifier(userId);
  }
}
```

### Health Checks

```dart
// Health check service
class HealthCheckService {
  Future<HealthStatus> checkHealth() async {
    final checks = await Future.wait([
      _checkDatabase(),
      _checkNetwork(),
      _checkStorage(),
    ]);
    
    return HealthStatus(
      isHealthy: checks.every((check) => check.isHealthy),
      checks: checks,
    );
  }
}
```

---

This architecture provides a solid foundation for building a scalable, maintainable, and performant habit tracking application. The clean architecture principles ensure separation of concerns, testability, and flexibility for future enhancements.
