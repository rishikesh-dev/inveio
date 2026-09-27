# Fix Firebase Log Exposure Issues

## Problem
Firebase-related error information is being exposed to users inappropriately:
1. Raw Firebase error codes shown to users when not in known error map
2. DebugPrint statements potentially leaking internal information in debug builds

## Locations to Fix

### 1. AuthFailureHelper Fallback Exposure
**File**: `lib/auth/data/datasources/remote/auth_failure_helper.dart`
**Line**: 32
**Issue**: Unknown Firebase error codes expose raw codes to users
```dart
final msg = _firebaseErrors[e.code] ?? 'Auth failed: ${e.code}';
```

### 2. SignInScreen DebugPrint
**File**: `lib/auth/presentation/screens/sign_in_screen.dart`
**Line**: 60
**Issue**: DebugPrint shows full state details
```dart
debugPrint('${state.message} ${state.toString()}');
```

### 3. HomeScreen DebugPrint
**File**: `lib/home/presentation/screens/home_screen.dart`
**Line**: 151
**Issue**: DebugPrint logs transaction errors
```dart
debugPrint(state.latest.latestError);
```

## Solution Approach

### 1. Fix AuthFailureHelper Fallback
Replace raw Firebase error code exposure with generic user-friendly message:
- Change fallback from `'Auth failed: ${e.code}'` to generic message like `'Authentication failed. Please try again.'`
- Log the actual error code internally for debugging (but don't expose to UI)

### 2. Remove/Replace DebugPrint Statements
Replace debugPrint with proper logging that doesn't expose sensitive information:
- Remove debugPrint or replace with generic messages
- Use appropriate logging levels (debug/info/warn/error)
- Ensure no sensitive data is logged

## Implementation Plan

### Task 1: Fix AuthFailureHelper
- Replace the fallback message with a generic user-friendly message
- Add internal logging of the actual error code for debugging purposes
- Ensure all Firebase errors map to appropriate user messages

### Task 2: Fix SignInScreen DebugPrint
- Remove the debugPrint statement or replace with minimal non-sensitive logging
- Ensure error messaging to user remains intact via SnackBar

### Task 3: Fix HomeScreen DebugPrint
- Remove or replace the debugPrint with appropriate logging level
- Keep UI error display but don't log raw error details

## Files to Modify
1. `lib/auth/data/datasources/remote/auth_failure_helper.dart`
2. `lib/auth/presentation/screens/sign_in_screen.dart`
3. `lib/home/presentation/screens/home_screen.dart`

## Validation
After changes:
- All Firebase auth errors should show user-friendly messages
- No raw Firebase error codes should be visible to users
- Debug builds should not leak sensitive information via console
- Error reporting to users should remain functional