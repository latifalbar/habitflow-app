import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'data/models/habit_model.dart';
import 'data/models/habit_log_model.dart';
import 'data/models/user_model.dart';
import 'data/models/achievement_model.dart';
import 'core/constants/storage_keys.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(HabitModelAdapter());
  Hive.registerAdapter(HabitLogModelAdapter());
  Hive.registerAdapter(UserModelAdapter());
  Hive.registerAdapter(AchievementModelAdapter());
  
  // Open Hive boxes
  await Hive.openBox<HabitModel>(StorageKeys.habitsBox);
  await Hive.openBox<HabitLogModel>(StorageKeys.habitLogsBox);
  await Hive.openBox<UserModel>(StorageKeys.userBox);
  await Hive.openBox<AchievementModel>(StorageKeys.achievementsBox);
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