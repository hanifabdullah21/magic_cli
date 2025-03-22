var filename_api_exception = 'lib/domain/remote/helper/api_exception.dart';
String file_api_exception(String projectName) {
  return '''
  import 'package:flutter/cupertino.dart';
  import 'package:${projectName}/domain/remote/helper/failure_model.dart';

  class ApiException implements Exception {
    final FailureModel failureModel;

    ApiException(this.failureModel) {
      debugPrint("❌ ApiException: \${toString()}");
    }

    @override
    String toString() {
      return 'ApiException (Error Code \${failureModel.code}-\${failureModel.msgSystem}): \${failureModel.msgShow}';
    }
  }
  
''';
}