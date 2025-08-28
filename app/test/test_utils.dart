import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mealie_api/mealie_api.dart';
import 'package:provider/provider.dart';

import 'package:cookbook_app/presentation/providers/auth_provider.dart';
import 'package:cookbook_app/presentation/themes/app_theme.dart';
import 'package:cookbook_app/domain/usecases/auth/login_usecase.dart';
import 'package:cookbook_app/domain/usecases/auth/logout_usecase.dart';
import 'package:cookbook_app/core/storage/auth_storage.dart';
import 'fakes.dart';

/// Provides a minimal app shell with MaterialApp and theme for widget tests.
Widget wrapWithApp(Widget child, {ThemeMode mode = ThemeMode.dark}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: mode,
      home: child,
    );

/// Builds a MealieClient with request interceptors to stub API responses.
MealieClient buildStubbedMealieClient({
  required String baseUrl,
  Map<String, dynamic>? stubs,
}) {
  final client = MealieClient(baseUrl: baseUrl);
  if (stubs != null && stubs.isNotEmpty) {
    client.dio.interceptors.add(
      InterceptorsWrapper(onRequest: (options, handler) {
        final path = options.path;
        if (options.method.toUpperCase() == 'GET' &&
            path.startsWith('/api/recipes/')) {
          final slug = path.split('/').last;
          if (stubs.containsKey(slug)) {
            return handler.resolve(Response(
              requestOptions: options,
              statusCode: 200,
              data: stubs[slug],
            ));
          }
        }
        return handler.next(options);
      }),
    );
  }
  return client;
}

/// Creates a testing Service Locator scope with fakes.
class TestDiScope extends StatelessWidget {
  final Widget child;
  final MealieClient mealieClient;

  const TestDiScope(
      {super.key, required this.child, required this.mealieClient});

  @override
  Widget build(BuildContext context) {
    final sl = GetIt.instance;
    if (sl.isRegistered<MealieClient>()) sl.unregister<MealieClient>();
    sl.registerSingleton<MealieClient>(mealieClient);

    // Minimal AuthProvider to satisfy AuthenticatedImage
    final authRepo = FakeAuthRepository();
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(
        loginUseCase: LoginUseCase(authRepo),
        logoutUseCase: LogoutUseCase(authRepo),
        getCurrentUserUseCase: null,
        authStorage: _MemoryAuthStorage(),
        mealieClient: mealieClient,
      ),
      child: child,
    );
  }
}

class _MemoryAuthStorage implements AuthStorage {
  String? _baseUrl;
  bool _loggedIn = false;
  String? _token;
  bool _remember = false;
  String? _refresh;
  String? _userId;

  @override
  Future<void> clearAll() async {
    _loggedIn = false;
    _token = null;
    _refresh = null;
    _userId = null;
  }

  @override
  Future<void> clearAccessToken() async => _token = null;

  @override
  Future<void> clearRefreshToken() async => _refresh = null;

  @override
  String? getAccessToken() => _token;

  @override
  String? getRefreshToken() => _refresh;

  @override
  String? getServerUrl() => _baseUrl;

  @override
  String? getUserId() => _userId;

  @override
  bool getRememberMe() => _remember;

  @override
  bool isLoggedIn() => _loggedIn;

  @override
  Future<void> setAccessToken(String token) async => _token = token;

  @override
  Future<void> setLoggedIn(bool loggedIn) async => _loggedIn = loggedIn;

  @override
  Future<void> setRefreshToken(String token) async => _refresh = token;

  @override
  Future<void> setRememberMe(bool rememberMe) async => _remember = rememberMe;

  @override
  Future<void> setServerUrl(String url) async => _baseUrl = url;

  @override
  Future<void> setUserId(String userId) async => _userId = userId;
}

/// Override http.get used by AuthenticatedImage to serve a solid color image.
void installHttpImageStub(
    {Color color = const Color(0xFFE0E0E0),
    Size size = const Size(600, 400)}) {}

/// Pumps a widget into the tester with default golden-toolkit setup.
Future<void> pumpWidgetForGolden(WidgetTester tester, Widget widget,
    {Size surfaceSize = const Size(390, 844),
    ThemeMode themeMode = ThemeMode.dark}) async {
  await loadAppFonts();
  tester.binding.window.devicePixelRatioTestValue = 1.0;
  tester.binding.window.physicalSizeTestValue =
      Size(surfaceSize.width, surfaceSize.height);
  addTearDown(tester.binding.window.clearPhysicalSizeTestValue);
  await tester.pumpWidget(wrapWithApp(widget, mode: themeMode));
  await tester.pumpAndSettle(const Duration(milliseconds: 250));
}
