enum ErrorCode {
  authentication,
  authorization,
  network,
  database,
  validation,
  duplicate,
  conflict,
  inventory,
  accounting,
  ocr,
  sync,
  unknown,
}

class AppException implements Exception {
  const AppException(this.code);
  final ErrorCode code;
  @override
  String toString() => 'AppException(${code.name})';
}
