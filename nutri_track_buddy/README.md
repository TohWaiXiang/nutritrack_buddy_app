# NutriTrack Buddy

A local Flutter demo app for healthy diet planning.

## Features
- Login / Create Account / Forgot Password
- Persistent local session
- Home calendar + nutrition progress card
- Meal planner with add/edit/delete meal entries by date
- AI nutrition assistant (local rule-based demo)
- Grocery list with progress tracking
- Profile editing with BMI + daily targets
- All data stored locally using SharedPreferences

## Run
1. Create a new Flutter project folder if needed, or open this folder directly.
2. Run:
   ```bash
   flutter pub get
   flutter run
   ```

## Notes
- This version is fully local and does not require Firebase.
- Forgot password uses security question + answer set during registration.
