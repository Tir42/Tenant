import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

enum Method { post, get, put, delete, patch }

class RestClient extends GetxService {
  late final Dio _dio;

  RestClient() {
    _dio = Dio(
      BaseOptions(
        // --- 1. LOCAL BACKEND SERVER (Active) ---
        // Your current Wi-Fi IP is 192.168.1.13. For Android emulator use 10.0.2.2:5000/api
        baseUrl: 'http://192.168.1.13:5000/api',

        // --- 2. DEPLOYED PRODUCTION BACKEND SERVER (Alternative) ---
        // baseUrl: 'https://tenant-apis.vercel.app/api',
    
        connectTimeout: const Duration(seconds: 40),
        receiveTimeout: const Duration(seconds: 60),
        sendTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> request(
      String url,
      Method method, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    final requestOptions = options ??
        Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        );

    switch (method) {
      case Method.post:
        return await _dio.post(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
        );

      case Method.get:
        return await _dio.get(
          url,
          queryParameters: queryParameters,
          options: requestOptions,
        );

      case Method.put:
        return await _dio.put(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
        );

      case Method.delete:
        return await _dio.delete(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
        );

      case Method.patch:
        return await _dio.patch(
          url,
          data: data,
          queryParameters: queryParameters,
          options: requestOptions,
        );
    }
  }
}