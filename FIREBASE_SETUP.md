# Firebase Setup Documentation

## Project Information
- **Project ID**: habitflow-6a102
- **Project Number**: 95465887677
- **Storage Bucket**: habitflow-6a102.firebasestorage.app

## Android App Configuration
- **Package Name**: com.habitflow.app.habitflow
- **App ID**: 1:95465887677:android:6c9505fefaf3bab7f964d4
- **API Key**: AIzaSyDeC7hE7bK-EgcBFcVI4XPTb5BZKRSGFxQ

## Enabled Services

### 1. Authentication
- ✅ Email/Password authentication
- ✅ Google Sign-In
- Location: https://console.firebase.google.com/project/habitflow-6a102/authentication

### 2. Cloud Firestore
- ✅ Database created
- ✅ Security rules configured (see firestore.rules)
- Location: https://console.firebase.google.com/project/habitflow-6a102/firestore

### 3. Firebase Analytics
- ✅ Enabled automatically
- Location: https://console.firebase.google.com/project/habitflow-6a102/analytics

### 4. Firebase Crashlytics
- ✅ Enabled
- Location: https://console.firebase.google.com/project/habitflow-6a102/crashlytics

## Security Rules

The Firestore security rules are defined in `firestore.rules`. To deploy them:

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. Initialize: `firebase init firestore`
4. Deploy: `firebase deploy --only firestore:rules`

Or manually copy the rules from `firestore.rules` to Firebase Console:
https://console.firebase.google.com/project/habitflow-6a102/firestore/rules

## Data Structure

```
users/{userId}
  ├── profile/{profileId}          # User profile data
  ├── habits/{habitId}              # User's habits
  ├── logs/{logId}                  # Habit completion logs
  ├── achievements/{achievementId}  # Unlocked achievements
  ├── progress/{progressId}         # XP and level data
  └── garden/{gardenId}             # Plants and garden state
```

## Authentication Setup

### Email/Password Sign-In
- Already enabled in Firebase Console
- No additional configuration needed

### Google Sign-In
- Already enabled in Firebase Console
- For production, you need to:
  1. Configure OAuth consent screen
  2. Add SHA-1 certificate fingerprint
  3. Download updated google-services.json

## Cloud Backup Features (Premium)

The app implements optional cloud backup as a premium feature:

- **Free users**: Data stored locally only (Hive)
- **Premium users**: Optional cloud backup & sync
- **Sync Strategy**: Automatic + manual sync (WhatsApp style)
- **Conflict Resolution**: User-prompted with visual comparison

## Testing

### Test Authentication
```dart
// Test email/password sign up
await authService.signUpWithEmail(
  email: 'test@example.com',
  password: 'testpassword123',
  displayName: 'Test User',
);

// Test Google sign in
await authService.signInWithGoogle();
```

### Test Firestore
```dart
// Test creating a habit in Firestore
await firestoreService.createDocument(
  subcollection: 'habits',
  documentId: habitId,
  data: habit.toJson(),
);
```

## Monitoring

### Analytics
View user events and behavior:
https://console.firebase.google.com/project/habitflow-6a102/analytics/events

### Crashlytics
View crash reports:
https://console.firebase.google.com/project/habitflow-6a102/crashlytics

### Performance
Monitor app performance:
https://console.firebase.google.com/project/habitflow-6a102/performance

## Production Checklist

Before launching to production:

- [ ] Update Firestore rules to production mode
- [ ] Add SHA-1 certificate for release builds
- [ ] Configure OAuth consent screen for Google Sign-In
- [ ] Set up Firebase App Distribution for beta testing
- [ ] Enable Firebase Performance Monitoring
- [ ] Configure backup retention policies
- [ ] Set up monitoring alerts

## Support

For Firebase-related issues:
- Firebase Documentation: https://firebase.google.com/docs
- Firebase Console: https://console.firebase.google.com/project/habitflow-6a102
- Support: https://firebase.google.com/support

---

**Last Updated**: October 19, 2025
**Maintained By**: HabitFlow Development Team

