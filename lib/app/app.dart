import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/state/settings_controller.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

class BloomListApp extends ConsumerStatefulWidget {
  const BloomListApp({super.key});

  @override
  ConsumerState<BloomListApp> createState() => _BloomListAppState();
}

class _BloomListAppState extends ConsumerState<BloomListApp> {
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider).valueOrNull;
    final seed = BloomPalette.seeds[(settings?.seedIndex ?? 0).clamp(0, BloomPalette.seeds.length - 1)];
    return MaterialApp.router(
      title: 'BloomList',
      debugShowCheckedModeBanner: false,
      themeMode: ref.watch(themeModeProvider),
      theme: BloomTheme.light(seed),
      darkTheme: BloomTheme.dark(seed),
      routerConfig: _router,
    );
  }
}
