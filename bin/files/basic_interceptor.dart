var filename_basic_interceptor = 'lib/domain/remote/helper/basic_interceptor.dart';
String file_basic_interceptor(projectName){
  return '''
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class BasicInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint(
        \"┌─REQUEST───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────\\n\" +
            \"│ METHOD  │ \${options.method}\\n\" +
            \"│ PATH    │ \${options.path}\\n\" +
            \"│ URL     │ \${options.baseUrl}\\n\" +
            \"│ HEADER  │ \${options.headers}\\n\" +
            \"│ BODY    │ \${options.data}\\n\" +
            \"└─END REQUEST───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────\");

    if (options.data is FormData) {
      var logFormData = \"\";
      logFormData =
          \"\$logFormData┌─REQUEST─FORM─DATA─────────────────────────────────────────────────────────────────────────────────────────────────────────────────\\n\";
      for (var field in (options.data as FormData).fields) {
        logFormData = \"\$logFormData│ \${field.key}: \${field.value}\\n\";
      }
      logFormData =
          \"\$logFormData┌─END-REQUEST─FORM─DATA─────────────────────────────────────────────────────────────────────────────────────────────────────────────\\n\";
      debugPrint(logFormData);
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint("┌─RESPONSE──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────\" +
        \"│ METHOD  │ \${err.requestOptions.method}\\n\" +
        \"│ PATH    │ \${err.requestOptions.path}\\n\" +
        \"│ HEADER  │ \${err.requestOptions.headers}\\n\" +
        \"├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄\\n\" +
        \"│ TYPE    │ \${err.type}\\n\" +
        \"│ MESSAGE │ \${err.message}\\n\" +
        \"│ RESPONSE│ \${err.response}\\n\" +
        \"└─END RESPONSE──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────\");
    super.onError(err, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint("┌─RESPONSE──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────\" +
        \"│ METHOD  │ \${response.requestOptions.method}\\n\" +
        \"│ PATH    │ \${response.requestOptions.path}\\n\" +
        \"│ HEADER  │ \${response.headers}\\n\" +
        \"├┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄┄\" +
        \"│ CODE    │ \${response.statusCode}\\n\" +
        \"│ MESSAGE │ \${response.statusMessage}\\n\" +
        \"│ RESPONSE│ \${response.data}\\n\" +
        \"└─END RESPONSE──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────\");
    super.onResponse(response, handler);
  }
}

  
  ''';
}