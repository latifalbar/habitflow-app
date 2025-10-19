import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/analytics_service.dart';
import '../../data/services/crashlytics_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../core/utils/premium_checker.dart';

/// Authentication state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final bool isPremium;
  
  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isPremium = false,
  });
  
  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
    bool? isPremium,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      isPremium: isPremium ?? this.isPremium,
    );
  }
  
  bool get hasError => error != null;
  bool get isSignedIn => isAuthenticated && user != null;
}

/// Authentication notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final AnalyticsService _analyticsService;
  final CrashlyticsService _crashlyticsService;
  final UserRepository _userRepository;
  final PremiumChecker _premiumChecker;
  
  AuthNotifier({
    required AuthService authService,
    required AnalyticsService analyticsService,
    required CrashlyticsService crashlyticsService,
    required UserRepository userRepository,
    required PremiumChecker premiumChecker,
  }) : _authService = authService,
       _analyticsService = analyticsService,
       _crashlyticsService = crashlyticsService,
       _userRepository = userRepository,
       _premiumChecker = premiumChecker,
       super(const AuthState()) {
    _initialize();
  }
  
  /// Initialize auth state
  void _initialize() {
    _authService.authStateChanges.listen((user) async {
      final isAuthenticated = user != null;
      final isPremium = await PremiumChecker.isPremium();
      
      state = state.copyWith(
        isAuthenticated: isAuthenticated,
        user: user,
        isPremium: isPremium,
        error: null,
      );
      
      if (isAuthenticated) {
        await _updateUserContext();
      }
    });
  }
  
  /// Update user context for analytics and crashlytics
  Future<void> _updateUserContext() async {
    if (state.user != null) {
      final userStats = _userRepository.getUserStats();
      
      await _analyticsService.setUserProperties(
        userId: state.user!.uid,
        isPremium: state.isPremium,
        level: userStats['level'] as int?,
        totalHabits: 0, // TODO: Get from habit repository
        totalStreak: 0, // TODO: Get from habit log repository
      );
      
      await _crashlyticsService.setUserContext(
        userId: state.user!.uid,
        isPremium: state.isPremium,
        level: userStats['level'] as int?,
        totalHabits: 0, // TODO: Get from habit repository
      );
    }
  }
  
  /// Sign up with email and password
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final credential = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: name,
      );
      
      // Create user in local database
      await _userRepository.createUser(
        name: name,
        email: email,
        isPremium: false, // Will be updated when premium is purchased
      );
      
      // Track analytics
      await _analyticsService.trackAuthEvent(
        eventName: 'sign_up',
        method: 'email',
        success: true,
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: credential.user,
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackAuthEvent(
        eventName: 'sign_up',
        method: 'email',
        success: false,
        errorMessage: e.toString(),
      );
      
      await _crashlyticsService.trackAuthError(
        errorType: 'sign_up_failed',
        method: 'email',
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Sign in with email and password
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final credential = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      
      // Update last active time
      await _userRepository.updateLastActiveTime();
      
      // Track analytics
      await _analyticsService.trackAuthEvent(
        eventName: 'sign_in',
        method: 'email',
        success: true,
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: credential.user,
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackAuthEvent(
        eventName: 'sign_in',
        method: 'email',
        success: false,
        errorMessage: e.toString(),
      );
      
      await _crashlyticsService.trackAuthError(
        errorType: 'sign_in_failed',
        method: 'email',
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final credential = await _authService.signInWithGoogle();
      
      // Create or update user in local database
      final user = credential.user;
      if (user != null) {
        final existingUser = _userRepository.getCurrentUser();
        if (existingUser == null) {
          await _userRepository.createUser(
            name: user.displayName ?? 'User',
            email: user.email ?? '',
            profileImageUrl: user.photoURL,
            isPremium: false,
          );
        } else {
          await _userRepository.updateLastActiveTime();
        }
      }
      
      // Track analytics
      await _analyticsService.trackAuthEvent(
        eventName: 'sign_in',
        method: 'google',
        success: true,
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackAuthEvent(
        eventName: 'sign_in',
        method: 'google',
        success: false,
        errorMessage: e.toString(),
      );
      
      await _crashlyticsService.trackAuthError(
        errorType: 'sign_in_failed',
        method: 'google',
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Sign out
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _authService.signOut();
      
      // Track analytics
      await _analyticsService.trackAuthEvent(
        eventName: 'sign_out',
        method: 'manual',
        success: true,
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackAuthEvent(
        eventName: 'sign_out',
        method: 'manual',
        success: false,
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      await _authService.sendPasswordResetEmail(email);
      
      // Track analytics
      await _analyticsService.trackAuthEvent(
        eventName: 'password_reset_requested',
        method: 'email',
        success: true,
      );
      
      state = state.copyWith(
        isLoading: false,
        error: null,
      );
    } catch (e) {
      await _analyticsService.trackAuthEvent(
        eventName: 'password_reset_requested',
        method: 'email',
        success: false,
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  
  /// Update premium status
  Future<void> updatePremiumStatus(bool isPremium) async {
    await _userRepository.updatePremiumStatus(isPremium);
    
    state = state.copyWith(isPremium: isPremium);
    
    // Update user context
    await _updateUserContext();
  }
  
  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
  
  /// Check if user can access premium features
  bool canAccessPremiumFeature() {
    return state.isPremium;
  }
  
  /// Get user display name
  String? get userDisplayName => state.user?.displayName;
  
  /// Get user email
  String? get userEmail => state.user?.email;
  
  /// Get user ID
  String? get userId => state.user?.uid;
}

/// Riverpod provider for AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider);
  final analyticsService = ref.watch(analyticsServiceProvider);
  final crashlyticsService = ref.watch(crashlyticsServiceProvider);
  final userRepository = ref.watch(userRepositoryProvider);
  
  return AuthNotifier(
    authService: authService,
    analyticsService: analyticsService,
    crashlyticsService: crashlyticsService,
    userRepository: userRepository,
    premiumChecker: PremiumChecker(),
  );
});

/// Riverpod provider for authentication state
final authStateProvider = StateProvider<AuthState>((ref) {
  return ref.watch(authNotifierProvider);
});

/// Riverpod provider for current user
final currentAuthUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.user;
});

/// Riverpod provider for premium status
final isPremiumProvider = Provider<bool>((ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.isPremium;
});
