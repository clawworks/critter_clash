import 'package:endless_runner/player_progress/player_progress.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:provider/provider.dart' as old;

import 'app_lifecycle/app_lifecycle.dart';
import 'audio/audio_controller.dart';
import 'router.dart';
import 'settings/settings.dart';
import 'style/palette.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.setLandscape();
  await Flame.device.fullScreen();
  runApp(
    ProviderScope(
      child: const CritterClashGame(),
    ),
  );
}

class CritterClashGame extends ConsumerWidget {
  const CritterClashGame({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppLifecycleObserver(
      child: old.MultiProvider(
        providers: [
          old.Provider(create: (context) => ref.watch(pPalette)),
          old.ChangeNotifierProvider(
              create: (context) => ref.watch(pPlayerProgress)),
          old.Provider(create: (context) => ref.watch(pSettingsController)),
          // Set up audio.
          old.ProxyProvider2<SettingsController, AppLifecycleStateNotifier,
              AudioController>(
            // Ensures that music starts immediately.
            lazy: false,
            create: (context) => ref.watch(pAudioController),
            update: (context, settings, lifecycleNotifier, audio) {
              audio!.attachDependencies(lifecycleNotifier, settings);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
          ),
        ],
        child: Builder(builder: (context) {
          final palette = ref.watch(pPalette);

          return MaterialApp.router(
            title: 'Endless Runner',
            theme: flutterNesTheme().copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: palette.seed.color,
                surface: palette.backgroundMain.color,
              ),
              textTheme: GoogleFonts.pressStart2pTextTheme().apply(
                bodyColor: palette.text.color,
                displayColor: palette.text.color,
              ),
            ),
            routerConfig: router,
          );
        }),
      ),
    );
  }
}
