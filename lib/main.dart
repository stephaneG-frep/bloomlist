import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/logging/app_error_logger.dart';
import 'core/logging/error_logger_provider.dart';
import 'core/notifications/local_notifications_service.dart';
import 'core/notifications/notification_providers.dart';
import 'core/storage/bloom_local_data_source.dart';
import 'core/storage/storage_providers.dart';

Future<void> main() async {
  AppErrorLogger? errorLogger;
  await runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting();
    final local = BloomLocalDataSource();
    final notifications = LocalNotificationsService();
    errorLogger = AppErrorLogger();
    await local.init();
    await notifications.init();
    await notifications.requestPermissions();
    await errorLogger!.init();

    FlutterError.onError = (FlutterErrorDetails details) {
      unawaited(errorLogger!.logFlutterError(details));
      FlutterError.presentError(details);
    };

    runApp(
      ProviderScope(
        overrides: [
          localDataSourceProvider.overrideWithValue(local),
          localNotificationsServiceProvider.overrideWithValue(notifications),
          appErrorLoggerProvider.overrideWithValue(errorLogger!),
        ],
        child: const BloomListApp(),
      ),
    );
  }, (error, stackTrace) {
    if (errorLogger != null) {
      unawaited(errorLogger!.logZoneError(error, stackTrace));
    }
  });
}
