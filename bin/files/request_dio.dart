var filename_request_dio = 'lib/domain/remote/helper/request_dio.dart';
String file_request_dio(String projectName) => '''
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:$projectName/domain/remote/helper/basic_interceptor.dart';
import 'package:$projectName/domain/remote/helper/basic_model.dart';
import 'package:$projectName/domain/remote/helper/failure_model.dart';

import 'api_exception.dart';

enum Method { POST, GET, PUT, DELETE, PATCH }

class RequestDio {
  Dio? _dio;
  static const _BASE_URL = \"https://your_base_url\";
  final Map<String, dynamic> _header = {
    \"Content-Type\": \"application/json\",
  };
  final List<Interceptor> _interceptors = [
    BasicInterceptor(),
  ];

  Future<dynamic> request({
    required String endpoint,
    required Method method,
    String? baseUrl,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? parameters,
    List<Interceptor>? interceptors,
    FormData? formData,
    bool isCustomResponse = false,
  }) async {
    Response response;

    final params = parameters ?? <String, dynamic>{};
    _header.addAll(headers ?? {});
    _interceptors.addAll(interceptors ?? []);

    try {
      _dio = Dio(BaseOptions(
        baseUrl: baseUrl ?? _BASE_URL,
        headers: _header,
        // connectTimeout: Duration(seconds: MicropackInit.requestTimeout),
        // receiveTimeout: Duration(seconds: MicropackInit.requestTimeout),
        // sendTimeout: Duration(seconds: MicropackInit.requestTimeout),
      ));
      _dio!.interceptors.addAll(_interceptors);

      if (method == Method.POST) {
        response = await _dio!.post(endpoint, data: formData ?? parameters);
      } else if (method == Method.PUT) {
        response = await _dio!.put(endpoint, data: formData ?? parameters);
      } else if (method == Method.DELETE) {
        response = await _dio!.delete(endpoint, queryParameters: params);
      } else if (method == Method.PATCH) {
        response = await _dio!.patch(endpoint);
      } else {
        response = await _dio!.get(endpoint, queryParameters: params);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isCustomResponse) {
          return response.data;
        } else {
          BasicModel basic = BasicModel.fromJson(response.data);
          return basic.data;
        }
      } else if (response.statusCode == 401) {
        throw ApiException(
          FailureModel(
            401,
            FailureMessage.MSG_401,
            FailureMessage.MSG_401_SYSTEM,
          ),
        );
      } else if (response.statusCode == 500) {
        throw ApiException(
          FailureModel(
            500,
            FailureMessage.MSG_500,
            \"\${response.statusMessage}\",
          ),
        );
      } else {
        throw ApiException(
          FailureModel(
            response.statusCode,
            FailureMessage.MSG_UNDEFINED,
            \"\${FailureMessage.MSG_UNDEFINED_SYSTEM} | Status Message : \${response.statusMessage}\",
          ),
        );
      }
    } on SocketException catch (e) {
      throw ApiException(
        FailureModel(
          400,
          FailureMessage.MSG_SOCKET_EXCEPTION,
          \"\${FailureMessage.MSG_SOCKET_EXCEPTION_SYSTEM} | Status Message : \${e.message}\",
        ),
      );
    } on FormatException catch (e) {
      throw ApiException(
        FailureModel(
          400,
          FailureMessage.MSG_FORMAT_EXCEPTION,
          \"\${FailureMessage.MSG_FORMAT_EXCEPTION_SYSTEM} | Status Message : \${e.message}\",
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        try {
          if (response != null &&
              response.data[BasicModel.BASIC_MESSAGE] != null) {
            return BasicModel.fromJson(response.data);
          } else {
            throw ApiException(
              FailureModel(
                400,
                FailureMessage.MSG_DIO_NULL,
                \"\${FailureMessage.MSG_DIO_NULL_SYSTEM} | Status Message : \${response?.statusMessage}\",
              ),
            );
          }
        } catch (e) {
          rethrow;
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw ApiException(
          FailureModel(
            400,
            FailureMessage.MSG_DIO_TIMEOUT,
            \"\${FailureMessage.MSG_DIO_TIMEOUT_SYSTEM} | Status Message : \${e.message}\",
          ),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiException(
          FailureModel(
            400,
            FailureMessage.MSG_SOCKET_EXCEPTION,
            \"\${FailureMessage.MSG_SOCKET_EXCEPTION} | Status Message : \${e.message}\",
          ),
        );
      } else {
        throw ApiException(
          FailureModel(
            400,
            FailureMessage.MSG_UNDEFINED,
            \"Dio\${FailureMessage.MSG_UNDEFINED_SYSTEM} | Status Message : \${e.message}\",
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

''';