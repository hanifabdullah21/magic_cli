var filename_failure_model = 'lib/domain/remote/helper/failure_model.dart';
String file_failure_model(projectName) => '''
class FailureModel {
  int? code;
  String msgShow;
  String msgSystem;

  FailureModel(this.code, this.msgShow, this.msgSystem);
}
    
class FailureMessage {
  static const MSG_401 = \"401 | Akses Tidak Diijinkan\";
  static const MSG_401_SYSTEM = \"Request Unauthorized\";
  static const MSG_500 = \"500 | Terjadi kesalahan di server. Silahkan coba lagi nanti\";
  static const MSG_500_SYSTEM = \"Request Internal Server Error\";
  static const MSG_UNDEFINED = \"Maaf, terjadi kesalahan. Silahkan coba lagi nanti\";
  static const MSG_UNDEFINED_SYSTEM = \"Request Undefined Error\";
  static const MSG_SOCKET_EXCEPTION = \"SocketException | Tidak ada koneksi. Silahkan periksa sambungan internet anda\";
  static const MSG_SOCKET_EXCEPTION_SYSTEM = \"Request SocketException\";
  static const MSG_FORMAT_EXCEPTION = \"FormatException | Terjadi kesalahan konversi atau format keliru\";
  static const MSG_FORMAT_EXCEPTION_SYSTEM = \"Request FormatException\";
  static const MSG_DIO_NULL = \"Terjadi kesalahan (null)\";
  static const MSG_DIO_NULL_SYSTEM = \"Request DioException Response null\";
  static const MSG_DIO_TIMEOUT = \"TimeoutException | Waktu permintaan habis. Silahkan coba lagi.\";
  static const MSG_DIO_TIMEOUT_SYSTEM = \"Request DioTimeoutException\";
  static const MSG_ = \" | \";
  static const MSG__SYSTEM = \"\";
}
''';