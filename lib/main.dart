import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'app.dart';
import 'data/models/habit_model.dart';
import 'data/models/habit_log_model.dart';
import 'data/models/user_model.dart';
import 'data/models/achievement_model.dart';
import 'data/models/user_progress_model.dart';
import 'data/models/plant_model.dart';
import 'core/constants/storage_keys.dart';
import 'data/services/crashlytics_service.dart';
import 'data/services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize Crashlytics
  final crashlyticsService = CrashlyticsService();
  await crashlyticsService.initialize();

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(HabitLogModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(AchievementModelAdapter());
  Hive.registerAdapter(UserProgressModelAdapter());
  Hive.registerAdapter(PlantModelAdapter());
  
  // Open Hive boxes
  await Hive.openBox<HabitModel>(StorageKeys.habitsBox);
  await Hive.openBox<HabitLogModel>(StorageKeys.habitLogsBox);
  await Hive.openBox<UserModel>(StorageKeys.userBox);
  await Hive.openBox<AchievementModel>(StorageKeys.achievementsBox);
  await Hive.openBox<UserProgressModel>(StorageKeys.userProgressBox);
  await Hive.openBox<PlantModel>(StorageKeys.plantsBox);
  await Hive.openBox(StorageKeys.settingsBox);

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: HabitFlowApp(),
    ),
  );
}