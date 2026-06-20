import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeout),
      receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: AppConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        debugPrint('[API] --> ${options.method} ${options.uri}');
        debugPrint('[API] Headers: ${options.headers}');
        if (options.data != null) {
          debugPrint('[API] Body: ${options.data}');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        debugPrint('[API] <-- ${response.statusCode} ${response.requestOptions.uri}');
        debugPrint('[API] Response body: ${response.data}');
        handler.next(response);
      },
      onError: (error, handler) async {
        debugPrint('[API] <-- ERROR ${error.response?.statusCode} ${error.requestOptions.uri}');
        debugPrint('[API] Error response body: ${error.response?.data}');
        if (error.response?.statusCode == 401) {
          final refreshed = await _refreshToken();
          if (refreshed) {
            final token = await _storage.read(key: AppConstants.tokenKey);
            if (token != null) {
              error.requestOptions.headers['Authorization'] = 'Bearer $token';
              final retryResponse = await _dio.fetch(error.requestOptions);
              handler.resolve(retryResponse);
              return;
            }
          }
        }
        handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storage.read(key: AppConstants.refreshTokenKey);
      if (refreshToken == null) return false;

      final response = await Dio().post(
        ApiConstants.tokenRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        await _storage.write(
          key: AppConstants.tokenKey,
          value: response.data['access'],
        );
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.get(path, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.post(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.patch(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.put(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return _dio.delete(path, data: data, queryParameters: queryParameters, options: options, cancelToken: cancelToken);
  }

  Future<Response> uploadFile(
    String path, {
    required String filePath,
    String fieldName = 'file',
    Map<String, dynamic>? extraData,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (extraData != null) ...extraData,
    });

    return _dio.post(
      path,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }

  Future<Response> uploadMultipleFiles(
    String path, {
    required List<String> filePaths,
    String fieldName = 'files',
    Map<String, dynamic>? extraData,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
  }) async {
    final files = await Future.wait(
      filePaths.map((p) => MultipartFile.fromFile(p)),
    );

    final formData = FormData.fromMap({
      fieldName: files,
      if (extraData != null) ...extraData,
    });

    return _dio.post(
      path,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
  }
}
