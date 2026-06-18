import 'package:dio/dio.dart';
import 'package:get/get.dart';

enum Method { POST, GET, PUT, DELETE, PATCH }

class RestClient extends GetxService {
  late final Dio _dio;

  RestClient() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://192.168.1.20:5000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ));

    _dio.interceptors.addAll([
      LogInterceptor(
        error: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
      ),
    ]);
  }

  Dio get dio => _dio;

  Future<dynamic> request(
    String url,
    Method method, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    final defaultOptions = options ?? Options(
      followRedirects: false,
      validateStatus: (status) => status != null && status < 500,
    );

    switch (method) {
      case Method.POST:
        return await _dio.post(url, data: data, queryParameters: queryParameters, options: defaultOptions);
      case Method.GET:
        return await _dio.get(url, queryParameters: queryParameters, options: defaultOptions);
      case Method.PUT:
        return await _dio.put(url, data: data, queryParameters: queryParameters, options: defaultOptions);
      case Method.DELETE:
        return await _dio.delete(url, data: data, queryParameters: queryParameters, options: defaultOptions);
      case Method.PATCH:
        return await _dio.patch(url, data: data, queryParameters: queryParameters, options: defaultOptions);
    }
  }
}
