import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/storage/bloom_local_data_source.dart';
import 'core/storage/storage_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final local = BloomLocalDataSource();
  await local.init();

  runApp(
    ProviderScope(
      overrides: [localDataSourceProvider.overrideWithValue(local)],
      child: const BloomListApp(),
    ),
  );
}
