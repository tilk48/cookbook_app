import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

abstract class AuthStorage {
  String? getAccessToken();
  Future<void> setAccessToken(String token);
  Future<void> clearAccessToken();

  String? getRefreshToken(); 
  Future<void> setRefreshToken(String token);
  Future<void> clearRefreshToken();

  String? getServerUrl();
  Future<void> setServerUrl(String url);

  String? getUserId();
  Future<void> setUserId(String userId);

  bool isLoggedIn();
  Future<void> setLoggedIn(bool loggedIn);

  bool getRememberMe();
  Future<void> setRememberMe(bool rememberMe);

  Future<void> clearAll();
}

class AuthStorageImpl implements AuthStorage {
  final SharedPreferences _prefs;

  const AuthStorageImpl(this._prefs);

  @override
  String? getAccessToken() {
    return _prefs.getString(AppConstants.accessTokenKey);
  }

  @override
  Future<void> setAccessToken(String token) async {
    await _prefs.setString(AppConstants.accessTokenKey, token);
  }

  @override
  Future<void> clearAccessToken() async {
    await _prefs.remove(AppConstants.accessTokenKey);
  }

  @override
  String? getRefreshToken() {
    return _prefs.getString(AppConstants.refreshTokenKey);
  }

  @override
  Future<void> setRefreshToken(String token) async {
    await _prefs.setString(AppConstants.refreshTokenKey, token);
  }

  @override
  Future<void> clearRefreshToken() async {
    await _prefs.remove(AppConstants.refreshTokenKey);
  }

  @override
  String? getServerUrl() {
    return _prefs.getString(AppConstants.serverUrlKey);
  }

  @override
  Future<void> setServerUrl(String url) async {
    await _prefs.setString(AppConstants.serverUrlKey, url);
  }

  @override
  String? getUserId() {
    return _prefs.getString(AppConstants.userIdKey);
  }

  @override
  Future<void> setUserId(String userId) async {
    await _prefs.setString(AppConstants.userIdKey, userId);
  }

  @override
  bool isLoggedIn() {
    return _prefs.getBool(AppConstants.isLoggedInKey) ?? false;
  }

  @override
  Future<void> setLoggedIn(bool loggedIn) async {
    await _prefs.setBool(AppConstants.isLoggedInKey, loggedIn);
  }

  @override
  bool getRememberMe() {
    return _prefs.getBool(AppConstants.rememberMeKey) ?? false;
  }

  @override
  Future<void> setRememberMe(bool rememberMe) async {
    await _prefs.setBool(AppConstants.rememberMeKey, rememberMe);
  }

  @override
  Future<void> clearAll() async {
    await Future.wait([
      clearAccessToken(),
      clearRefreshToken(),
      _prefs.remove(AppConstants.userIdKey),
      setLoggedIn(false),
    ]);
  }
}