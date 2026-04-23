import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bloom_local_data_source.dart';

final localDataSourceProvider = Provider<BloomLocalDataSource>((ref) {
  return BloomLocalDataSource();
});
