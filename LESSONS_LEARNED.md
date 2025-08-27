# Lessons Learned - Flutter Mealie App Development

## JSON Serialization with Mealie API

### Issue: User Data Not Displaying
**Problem**: Profile page showed "Unknown User" and "No email available" despite API returning correct data.

**Root Cause**: 
- Mealie API returns **camelCase** field names (`fullName`, `groupId`, `canManage`)
- Generated JSON serialization code expected **snake_case** (`full_name`, `group_id`, `can_manage`)
- Model annotations had `@JsonKey(name: 'full_name')` but API actually returns `fullName`

**API Response Format**:
```json
{
  "id": "0fae345b-9b72-44c3-b1e8-a42a5921e0c8",
  "username": "Til",
  "fullName": "Tilman Kieselbach",
  "email": "tilman.kieselbach@icloud.com",
  "admin": true,
  "group": "home",
  "household": "Lucy&Til",
  "groupId": "04fb018a-30f1-410b-9c39-af17917ffff8",
  "householdId": "d5bdde1a-c1c8-4130-91a6-32f7b718b873",
  "canInvite": true,
  "canManage": true,
  "canOrganize": true
}
```

**Wrong Approach** (Outdated generated code):
```dart
// user_models.g.dart
User _$UserFromJson(Map<String, dynamic> json) => User(
  fullName: json['full_name'] as String,  // ❌ API uses 'fullName'
  groupId: json['group_id'] as String?,   // ❌ API uses 'groupId'
);
```

**Correct Approach** (Updated generated code):
```dart
// user_models.g.dart  
User _$UserFromJson(Map<String, dynamic> json) => User(
  fullName: json['fullName'] as String,  // ✅ Matches API
  groupId: json['groupId'] as String?,   // ✅ Matches API
);
```

### Solutions Considered

#### 1. Manual JSON Parsing (Not Recommended)
```dart
// Works but not maintainable
factory User.fromJson(Map<String, dynamic> json) {
  return User(
    fullName: json['fullName'] as String,
    email: json['email'] as String,
    // ... manual parsing for all fields
  );
}
```
**Problems**: More code, error-prone, no tooling support

#### 2. Fix Generated Code (Recommended ✅)
```dart
// Update user_models.g.dart to match API format
User _$UserFromJson(Map<String, dynamic> json) => User(
  fullName: json['fullName'] as String,  // Match API response
  groupId: json['groupId'] as String?,   // Match API response
);
```
**Benefits**: Standard approach, maintainable, type-safe

### Debugging Technique
Added debug statements at multiple points to trace data flow:

```dart
// 1. API Response Logging (Dio interceptor already logs)
// 2. JSON Parsing Debug
factory User.fromJson(Map<String, dynamic> json) {
  print('DEBUG: User.fromJson called with: $json');
  // ...
}

// 3. Provider Debug  
Future<void> loadCurrentUser() async {
  print('DEBUG: Starting user data fetch...');
  final user = await _mealieClient.users.getCurrentUser();
  print('DEBUG: User fullName: ${user.fullName}');
  // ...
}

// 4. UI Debug
Widget _buildUserCard(BuildContext context, AuthProvider authProvider) {
  final user = authProvider.currentUser;
  print('DEBUG: user is null: ${user == null}');
  // ...
}
```

## Authentication Flow Implementation

### Key Lessons

#### 1. Mealie API Uses Multipart/Form-Data for Login
**Wrong**: JSON request body
```dart
await _dio.post('/api/auth/token', data: request.toJson());
```

**Correct**: FormData request
```dart
final formData = FormData.fromMap({
  'username': request.username,
  'password': request.password,
  'remember_me': request.rememberMe?.toString() ?? 'false',
});
await _dio.post('/api/auth/token', data: formData);
```

#### 2. Authentication State Management
Issue: User could authenticate but `isLoggedIn` remained false.

**Problem**: Required both storage state AND user object:
```dart
bool get isLoggedIn => _authStorage.isLoggedIn() && _currentUser != null;
```

**Solution**: Make user object optional when use case unavailable:
```dart
bool get isLoggedIn => _authStorage.isLoggedIn() && 
  (_getCurrentUserUseCase == null || _currentUser != null);
```

#### 3. Router Navigation Guards
Proper authentication flow routing:
```dart
static String? _redirect(BuildContext context, GoRouterState state) {
  final authProvider = context.read<AuthProvider>();
  
  // 1. Always allow splash screen
  if (state.matchedLocation == splash) return null;
  
  // 2. Check server URL configuration
  if (!authProvider.hasServerUrl && !isOnOnboardingPage) {
    return onboarding;
  }
  
  // 3. Check authentication
  if (!authProvider.isLoggedIn && !isOnAuthPage) {
    return login;
  }
  
  return null; // Allow access
}
```

## Flutter UI/UX Best Practices

### Material Design 3 Implementation
- Use `Theme.of(context).colorScheme` for consistent colors
- Implement proper loading states with `CircularProgressIndicator`
- Use cards with appropriate elevation and rounded corners
- Follow Material Design spacing guidelines (8dp grid)

### Profile Page Design Principles
```dart
// Good: Modern card-based layout
Card(
  elevation: 4,
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  child: Container(padding: const EdgeInsets.all(24), ...),
)

// Good: Gradient avatars
Container(
  decoration: BoxDecoration(
    shape: BoxShape.circle,
    gradient: LinearGradient(colors: [primary, secondary]),
  ),
)

// Good: Role badges with semantic colors
Container(
  decoration: BoxDecoration(
    color: user.admin 
      ? Theme.of(context).colorScheme.errorContainer
      : Theme.of(context).colorScheme.primaryContainer,
  ),
)
```

### StatefulWidget vs StatelessWidget
Use StatefulWidget when:
- Need to load data on page initialization
- Managing local component state
- Implementing lifecycle methods

```dart
class ProfilePage extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadCurrentUser();
    });
  }
}
```

## Development Workflow

### Debug-First Approach
1. **Add logging** at multiple points in data flow
2. **Check API responses** with Dio logging interceptor  
3. **Trace data transformation** through providers and models
4. **Verify UI state** in build methods
5. **Test on device** (Android APK) rather than web for full functionality

### Code Generation Best Practices
- **Understand the API format** before writing models
- **Match field naming conventions** (camelCase vs snake_case)
- **Keep generated files in sync** with model changes
- **Prefer generated code** over manual parsing for maintainability

### Architecture Decisions
- **Clean Architecture**: Domain/Data/Presentation separation
- **Provider Pattern**: State management with ChangeNotifier
- **Repository Pattern**: Abstract data sources
- **Use Cases**: Business logic encapsulation (can be optional for simple apps)

## Key Takeaways

1. **API Contract Understanding**: Always verify actual API response format vs documentation
2. **Debug Systematically**: Add logging at each layer to isolate issues
3. **Generated Code Maintenance**: Keep generated files in sync with API changes
4. **Authentication Complexity**: Handle edge cases in state management
5. **Material Design**: Follow design system for professional UI
6. **Platform Testing**: Test on actual devices, not just web/emulator

---

*Last Updated: August 27, 2025*