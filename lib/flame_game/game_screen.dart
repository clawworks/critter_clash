import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:nes_ui/nes_ui.dart';

import '../audio/audio_controller.dart';
import '../level_selection/levels.dart';
import '../player_progress/player_progress.dart';
import 'endless_runner.dart';
import 'game_win_dialog.dart';

/// This widget defines the properties of the game screen.
///
/// It mostly sets up the overlays (widgets shown on top of the Flame game) and
/// the gets the [AudioController] from the context and passes it in to the
/// [CritterClashFlame] class so that it can play audio.
class GameScreen extends ConsumerWidget {
  const GameScreen({required this.level, super.key});

  final GameLevel level;

  static const String winDialogKey = 'win_dialog';
  static const String backButtonKey = 'back_buttton';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioController = ref.read(pAudioController);
    return Scaffold(
      body: GameWidget<CritterClashFlame>(
        key: const Key('play session'),
        game: CritterClashFlame(
          level: level,
          playerProgress: ref.read(pPlayerProgress),
          audioController: audioController,
        ),
        overlayBuilderMap: {
          backButtonKey: (BuildContext context, CritterClashFlame game) {
            return Positioned(
              top: 20,
              right: 10,
              child: NesButton(
                type: NesButtonType.normal,
                onPressed: GoRouter.of(context).pop,
                child: NesIcon(iconData: NesIcons.leftArrowIndicator),
              ),
            );
          },
          winDialogKey: (BuildContext context, CritterClashFlame game) {
            return GameWinDialog(
              level: level,
              levelCompletedIn: game.world.levelCompletedIn,
            );
          },
        },
      ),
    );
  }
}
