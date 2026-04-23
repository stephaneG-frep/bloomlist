import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'local_notifications_service.dart';

final localNotificationsServiceProvider = Provider<LocalNotificationsService>((ref) {
  return LocalNotificationsService();
});
