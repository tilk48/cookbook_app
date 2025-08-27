import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  String? _accessToken;
  
  AuthInterceptor({String? accessToken}) : _accessToken = accessToken;

  String? get accessToken => _accessToken;

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_accessToken != null) {
      options.headers['Authorization'] = 'Bearer $_accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // Token might be expired or invalid
      // The app should handle this by redirecting to login
      _accessToken = null;
    }
    handler.next(err);
  }
}