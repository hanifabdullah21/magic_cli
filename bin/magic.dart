import 'dart:io';

void main(List<String> arguments) {

  final pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    print('⚠️ pubspec.yaml not found!');
    return;
  }

  final lines = pubspec.readAsLinesSync();
  final projectName = lines.firstWhere((line) => line.startsWith('name:'))
      .split(':')[1].trim();
  
  if (arguments.isNotEmpty && arguments.first == 'init') {
    installDependencies();  //install dependencies from pub
    addGitDependency();
    createDefaultStructure(projectName);
  } else if (arguments.isNotEmpty && arguments.first == 'create'){
    if(arguments.length > 2){
      print("❌ unknown");
      return;
    }

    String repositoryName = arguments[1];
    String repositoryNameLower = repositoryName.toLowerCase();
    String repositoryNameCap = "";
    final repositoryNameSplit = arguments[1].split("_");
    for(var name in repositoryNameSplit){
      repositoryNameCap = repositoryNameCap + name[0].toUpperCase() + name.substring(1);
    }
    createModuleFeature(projectName, repositoryName, repositoryNameLower, repositoryNameCap);
  } else {
    print('Usage: magic init');
  }
}

void createDefaultStructure(String projectName) {
  final directories = [
    'lib/data',
    'lib/data/model',
    'lib/data/repository',
    'lib/data/sources',
    'lib/domain',
    'lib/domain/local',
    'lib/domain/local/repository',
    'lib/domain/local/entities',
    'lib/domain/remote',
    'lib/domain/remote/helper',
    'lib/domain/remote/repository',
    'lib/utils',
    'lib/utils/constants',
    'lib/utils/exception',
    'lib/utils/helper',
    'lib/utils/widgets',
  ];

  final files = {
    // 'lib/controllers/home_controller.dart': '// HomeController',
    'lib/domain/remote/helper/api_exception.dart': '''
    
import 'package:${projectName}/domain/remote/helper/failure_model.dart';

class ApiException implements Exception {
  final FailureModel failureModel;

  ApiException(this.failureModel);

  @override
  String toString() {
    return 'ApiException (Error Code \${failureModel.code}-\${failureModel
        .msgSystem}): \${failureModel.msgShow}';
  }
}

    ''',
    'lib/domain/remote/helper/basic_model.dart': '''
    
class BasicModel {
  bool success = false;
  String? message;
  dynamic error;
  dynamic data;

  BasicModel({this.success = false, this.message, this.error, this.data});

  BasicModel.fromJson(Map<String, dynamic>? json) {
    success = json?['success'];
    message = json?['message'];
    data = json?['data'];
    error = json?['error'];
  }

  Map<String, dynamic> toJson(BasicModel model) => <String, dynamic>{
    'success': model.success,
    'message': model.message,
    'error': model.error,
    'data': model.data
  };
}

extension BasicExtension on dynamic {
  BasicModel get toBasic{
    if (this == null) {
      return Basic(
          success: false,
          message: this["message"],
          error: this["error"] ?? "An Error Occurred");
    } else {
      Map<String, dynamic> data = this as Map<String, dynamic>;
      data["success"] = data["success"] ?? false;
      data["message"] = this["message"];
      data["data"] = data["data"];
      return BasicModel.fromJson(data);
    }
  }
}

    ''',
    'lib/domain/remote/helper/failure_model.dart': '''

class FailureModel {
  int? code;
  String msgShow;
  String msgSystem;

  FailureModel(this.code, this.msgShow, this.msgSystem);
}
    
''',
    'lib/domain/remote/helper/request_dio.dart': '''
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:$projectName/domain/remote/helper/basic_model.dart';
import 'package:$projectName/domain/remote/helper/failure_model.dart';

import 'api_exception.dart';

enum Method { POST, GET, PUT, DELETE, PATCH }

class RequestDio {
  Dio? _dio;
  static const BASE_URL = "https://your_base_url";

  Future<RequestDio> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: BASE_URL,
        headers: {'Content-Type': 'application/json'},
        // connectTimeout: Duration(seconds: MicropackInit.requestTimeout),
        // receiveTimeout: Duration(seconds: MicropackInit.requestTimeout),
        // sendTimeout: Duration(seconds: MicropackInit.requestTimeout),
      ),
    );
    initInterceptors();
    return this;
  }

  void initInterceptors() {
    _dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (requestOptions, handler) {
          return handler.next(requestOptions);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (err, handler) {
          return handler.next(err);
        },
      ),
    );
  }

  Future<dynamic> request({
    required String url,
    required Method method,
    // Map<String, dynamic>? headers,
    Map<String, dynamic>? parameters,
    FormData? formData,
    // bool isToken = true,
    bool isCustomResponse = false,
  }) async {
    Response response;

    final params = parameters ?? <String, dynamic>{};

    try {
      if (_dio == null) {
        _dio = Dio(BaseOptions(
          baseUrl: BASE_URL,
          // headers: headers,
          // connectTimeout: Duration(seconds: MicropackInit.requestTimeout),
          // receiveTimeout: Duration(seconds: MicropackInit.requestTimeout),
          // sendTimeout: Duration(seconds: MicropackInit.requestTimeout),
        ));
        initInterceptors();
      }

      if (method == Method.POST) {
        response = await _dio!.post(url, data: formData ?? parameters);
      } else if (method == Method.PUT) {
        response = await _dio!.put(url, data: formData ?? parameters);
      } else if (method == Method.DELETE) {
        response = await _dio!.delete(url, queryParameters: params);
      } else if (method == Method.PATCH) {
        response = await _dio!.patch(url);
      } else {
        response = await _dio!.get(url, queryParameters: params);
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (isCustomResponse) {
          return response.data;
        } else {
          BasicModel basic = response.toBasic;
          return basic.data;
        }
      } else if (response.statusCode == 401) {
        throw ApiException(
            FailureModel(401, "Token Kadaluarsa", "Unauthorized"));
      } else if (response.statusCode == 500) {
        throw ApiException(FailureModel(
            500, "Internal Server Error", "\${response.statusMessage}"));
      } else {
        throw ApiException(
          FailureModel(
            response.statusCode,
            "Terjadi Kesalahan",
            response.statusMessage ?? "Terjadi Kesalahan",
          ),
        );
      }
    } on SocketException catch (e) {
      // logSys(e.toString());
      throw ApiException(
        FailureModel(
          400,
          "Tidak Ada Koneksi Internet",
          "Tidak Ada Koneksi Internet (\${e.message}).",
        ),
      );
    } on FormatException catch (e) {
      // logSys(e.toString());
      throw ApiException(
        FailureModel(
          400,
          "Terjadi Kesalahan Konversi Data",
          "Terjadi Kesalahan Konversi Data (\${e.message}).",
        ),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.badResponse) {
        final response = e.response;
        try {
          if (response != null) {
            return response.data;
          }
        } catch (e) {
          throw Exception('Internal Error : \$e');
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout) {
        throw ApiException(
          FailureModel(
            400,
            "Waktu Habis",
            "Waktu Habis",
          ),
        );
      } else if (e.type == DioExceptionType.connectionError) {
        throw ApiException(
          FailureModel(
            400,
            "Terjadi Kesalahan Koneksi",
            "Terjadi Kesalahan Koneksi",
          ),
        );
      } else if (e.error is SocketException) {
        throw ApiException(
          FailureModel(
            400,
            "Terjadi Kesalahan Koneksi",
            "Terjadi Kesalahan Koneksi",
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}

''',
    'lib/domain/remote/helper/status_request.dart': '''
import 'failure_model.dart';

enum StatusRequest { NONE, LOADING, SUCCESS, EMPTY, ERROR }

class StatusRequestModel<T> {
  StatusRequest statusRequest = StatusRequest.NONE;
  T? data;
  FailureModel? failure;

  StatusRequestModel(
      {this.statusRequest = StatusRequest.NONE, this.data, this.failure});

  factory StatusRequestModel.fromStatus(StatusRequest status,
      {T? data, FailureModel? failure}) {
    switch (status) {
      case StatusRequest.LOADING:
        return StatusRequestModel.loading();
      case StatusRequest.SUCCESS:
        return StatusRequestModel.success(data);
      case StatusRequest.EMPTY:
        return StatusRequestModel.empty();
      case StatusRequest.ERROR:
        return StatusRequestModel.error(failure);
      case StatusRequest.NONE:
      default:
        return StatusRequestModel.empty();
    }
  }

  StatusRequestModel.loading() {
    statusRequest = StatusRequest.LOADING;
    data = null;
    failure = null;
  }

  StatusRequestModel.success(T? newData) {
    statusRequest = StatusRequest.SUCCESS;
    data = newData;
    failure = null;
  }

  StatusRequestModel.empty() {
    statusRequest = StatusRequest.EMPTY;
    data = null;
    failure = null;
  }

  StatusRequestModel.error(FailureModel? error) {
    statusRequest = StatusRequest.ERROR;
    data = null;
    failure = error;
  }

  // Method to handle different statuses with optional callbacks
  void handle({
    Function()? onLoading,
    Function(T? data)? onSuccess,
    Function()? onEmpty,
    Function(FailureModel? failure)? onError,
  }) {
    switch (statusRequest) {
      case StatusRequest.LOADING:
        if (onLoading != null) onLoading();
        break;
      case StatusRequest.SUCCESS:
        if (onSuccess != null) onSuccess(data);
        break;
      case StatusRequest.EMPTY:
      case StatusRequest.NONE: // Handle NONE as EMPTY
        if (onEmpty != null) onEmpty();
        break;
      case StatusRequest.ERROR:
        if (onError != null) onError(failure);
        break;
    }
  }
}

    ''',
    /* **************************
     *      EXAMPLE OF CODE     *
     * **************************/
    'lib/data/model/example_model.dart': '''
import 'dart:convert';

class ExampleModel {
    int? id;
    String? name;

    ExampleModel({
        this.id,
        this.name,
    });

    ExampleModel copyWith({
        int? id,
        String? name,
    }) => 
        ExampleModel(
            id: id ?? this.id,
            name: name ?? this.name,
        );

    factory ExampleModel.fromRawJson(String str) => ExampleModel.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory ExampleModel.fromJson(Map<String, dynamic> json) => ExampleModel(
        id: json["id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
    };
}
''',
    'lib/domain/remote/repository/example_repository.dart': '''
    
import '../../../data/model/example_model.dart';
import '../helper/status_request.dart';

abstract class ExampleRepository {
  Future<StatusRequestModel<List<ExampleModel>>> getExampleAll();
  Future<StatusRequestModel<ExampleModel>> getExample();
}

    ''',
    'lib/data/sources/example_datasource.dart': '''
    
import 'package:$projectName/data/model/example_model.dart';
import 'package:$projectName/domain/remote/helper/request_dio.dart';

import '../../domain/remote/helper/api_exception.dart';
import '../../domain/remote/helper/status_request.dart';

class ExampleDatasource extends RequestDio {
  Future<StatusRequestModel<List<ExampleModel>>> getAll() async {
    try {
      final result = await request(
          url: '/your_endpoint', method: Method.GET, isCustomResponse: false);
      final list = List<ExampleModel>.from(
          (result).map((u) => ExampleModel.fromJson(u)));
      if (list.isEmpty) {
        return StatusRequestModel.empty();
      }
      return StatusRequestModel.success(list);
    } on ApiException catch (e) {
      return StatusRequestModel.error(e.failureModel);
    }
  }

  Future<StatusRequestModel<ExampleModel>> getObject() async {
    try {
      final result = await request(
          url: '/your_endpoint', method: Method.GET, isCustomResponse: false);
      final list = ExampleModel.fromJson(result);
      return StatusRequestModel.success(list);
    } on ApiException catch (e) {
      return StatusRequestModel.error(e.failureModel);
    }
  }
}

    ''',
    'lib/data/repository/example_repository_impl.dart': '''
    
import 'package:$projectName/data/model/example_model.dart';
import 'package:$projectName/data/sources/example_datasource.dart';
import 'package:$projectName/domain/remote/repository/example_repository.dart';

import '../../domain/remote/helper/status_request.dart';

class ExampleRepositoryImpl extends ExampleRepository {
  final ExampleDatasource _dataSource;

  ExampleRepositoryImpl(this._dataSource);

  @override
  Future<StatusRequestModel<List<ExampleModel>>> getExampleAll() async {
    return await _dataSource.getAll();
  }

  @override
  Future<StatusRequestModel<ExampleModel>> getExample() async {
    return await _dataSource.getObject();
  }
}

    
    '''
  };

  for (var dir in directories) {
    Directory(dir).createSync(recursive: true);
    print('Created directory: $dir');
  }

  for (var filePath in files.keys) {
    File file = File(filePath);
    if (!file.existsSync()) {
      file.writeAsStringSync(files[filePath]!);
      print('📄 Created file: $filePath');
    } else {
      print('⚠️ Skipped: $filePath already exists');
    }
  }

  print('✨ Magic init completed! ✨');
}

void installDependencies() {
  print('📦 Installing dependencies...');

  List<String> dependencies = ['dio',];

  for (var package in dependencies) {
    print('🚀 Installing $package...');
    Process.runSync('flutter', ['pub', 'add', package]);
  }

  print('✅ Dependencies installed successfully!');
}

void addGitDependency() {
  print('🔗 Adding Git dependencies...');

  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    print('⚠️ pubspec.yaml not found!');
    return;
  }

  const gitDependency = '''
  magic_view:
    git:
      url: https://github.com/hanifabdullah21/MagicView
      ref: main
''';

  final lines = pubspecFile.readAsLinesSync();
  List<String> updatedLines = [];
  bool dependenciesFound = false;

  for (var line in lines) {
    updatedLines.add(line);

    // Temukan bagian `dependencies:`
    if (line.trim() == 'dependencies:') {
      dependenciesFound = true;
    }

    // Jika kita sudah menemukan `dependencies:` dan menemukan dependensi lain, tambahkan `magic_view`
    if (dependenciesFound && line.trim().isNotEmpty && !line.startsWith(' ') && line.trim() != 'dependencies:') {
      updatedLines.insert(updatedLines.length - 1, gitDependency);
      dependenciesFound = false; // Supaya hanya menambah satu kali
    }
  }

  // Jika tidak ada dependensi lain, tambahkan langsung setelah `dependencies:`
  if (dependenciesFound) {
    updatedLines.add(gitDependency);
  }

  // Tulis ulang file pubspec.yaml
  pubspecFile.writeAsStringSync(updatedLines.join('\n'));
  print('✅ Git dependency added inside dependencies block!');

  print('🚀 Running flutter pub get...');
  Process.runSync('flutter', ['pub', 'get']);
  print('✅ Git dependencies installed successfully!');
}

void createModuleFeature(String projectName, String repositoryName, String repositoryNameLower, String repositoryNameCap){
  final files = {
    // 'lib/controllers/home_controller.dart': '// HomeController',
    'lib/data/sources/${repositoryNameLower}_datasource.dart': '''
    
import 'package:$projectName/domain/remote/helper/request_dio.dart';

import '../../domain/remote/helper/api_exception.dart';
import '../../domain/remote/helper/status_request.dart';

class ${repositoryNameCap}Datasource extends RequestDio {
 
}
    
''',
    'lib/domain/remote/repository/${repositoryNameLower}_repository.dart': '''
    
import '../helper/status_request.dart';

abstract class ${repositoryNameCap}Repository {
  
}

''',
    'lib/data/repository/${repositoryNameLower}_repository_impl.dart': '''
import 'package:$projectName/data/sources/${repositoryNameLower}_datasource.dart';
import 'package:$projectName/domain/remote/repository/${repositoryNameLower}_repository.dart';

import '../../domain/remote/helper/status_request.dart';

class ${repositoryNameCap}RepositoryImpl extends ${repositoryNameCap}Repository {
  final ${repositoryNameCap}Datasource _dataSource;

  ${repositoryNameCap}RepositoryImpl(this._dataSource);
}
''',
  };

  for (var filePath in files.keys) {
    File file = File(filePath);
    if (!file.existsSync()) {
      file.writeAsStringSync(files[filePath]!);
      print('📄 Created file: $filePath');
    } else {
      print('⚠️ Skipped: $filePath already exists');
    }
  }

  print('✨ Magic create completed! ✨');
  
}