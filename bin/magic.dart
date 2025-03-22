import 'dart:io';
import 'files/api_exception.dart';
import 'files/basic_interceptor.dart';
import 'files/failure_model.dart';
import 'files/basic_model.dart';
import 'files/request_dio.dart';
import 'files/status_request.dart';
import 'files/currency_extension.dart';
import 'files/date_extension.dart';

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
    filename_api_exception : file_api_exception(projectName),
    filename_basic_interceptor : file_basic_interceptor(projectName),
    filename_failure_model : file_failure_model(projectName),
    filename_basic_model : file_basic_model(projectName),
    filename_request_dio : file_request_dio(projectName),
    filename_status_request : file_status_request(projectName),
    filename_currency_extension : file_currency_extension(projectName),
    filename_date_extension : file_date_extension(projectName),
    // filename_ : file_(projectName),

  };

  for (var dir in directories) {
    Directory directory = Directory(dir);
    if(!directory.existsSync()){
      directory.createSync(recursive: true);
      print('📂 Created directory: $dir');
    }else{
      print('⚠️ Skipped: $dir already exists');
    }
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

  final pubspecFileString = pubspecFile.readAsStringSync();
  if(pubspecFileString.contains(gitDependency)){
    print('⚠️ Skipped: MagicView already exists');
    return;
  }

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
      updatedLines.insert(updatedLines.length - 2, gitDependency);
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