var filename_date_extension = 'lib/utils/helper/date_extension.dart';
String file_date_extension(projectName) => '''
import 'package:intl/intl.dart';

extension DateExtension on DateTime? {
  String toDateString({String format = "dd/MM/yyyy"}) {
    if (this==null) {
      return "-";
    } else {
      return DateFormat(format, "id").format(this!);
    }
  }
}
''';