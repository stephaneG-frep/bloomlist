import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_error_logger.dart';

final appErrorLoggerProvider = Provider<AppErrorLogger>((ref) {
  return AppErrorLogger();
});
