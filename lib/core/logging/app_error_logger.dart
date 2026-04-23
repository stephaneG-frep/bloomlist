import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class AppErrorLogger {
  static const _boxName = 'bloom_errors';

  Future<void> init() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox<String>(_boxName);
    }
  }

  Future<void> log(String source, Object error, StackTrace? stackTrace) async {
    try {
      final box = Hive.box<String>(_boxName);
      final now = DateTime.now().toIso8601String();
      final payload = '[$now][$source] $error\n${stackTrace ?? ''}';
      await box.add(payload);
      if (box.length > 200) {
        await box.deleteAt(0);
      }
      if (kDebugMode) {
        debugPrint(payload);
      }
    } catch (_) {
      // Never crash the app because logging failed.
    }
  }

  Future<void> logFlutterError(FlutterErrorDetails details) async {
    await log('flutter_error', details.exception, details.stack);
  }

  Future<void> logZoneError(Object error, StackTrace stackTrace) async {
    await log('zone_error', error, stackTrace);
  }

  List<String> latest({int limit = 20}) {
    try {
      final box = Hive.box<String>(_boxName);
      final all = box.values.toList().reversed.toList();
      return all.take(limit).toList();
    } catch (_) {
      return const <String>[];
    }
  }
}
