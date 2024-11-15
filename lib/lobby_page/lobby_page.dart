import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../style/palette.dart';
import '../../style/wobbly_button.dart';

class LobbyPage extends ConsumerWidget {
  const LobbyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = ref.watch(pPalette);
    // final playerProgress = context.watch<PlayerProgress>();
    // final levelTextStyle =
    //     Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4);

    return Scaffold(
      backgroundColor: palette.backgroundLevelSelection.color,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lobby',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(width: 16),
                  // NesButton(
                  //   type: NesButtonType.normal,
                  //   child: NesIcon(iconData: NesIcons.questionMark),
                  //   onPressed: () {
                  // NesDialog.show<void>(
                  //   context: context,
                  //   builder: (_) => const InstructionsDialog(),
                  // );
                  // },
                  // )
                ],
              ),
            ),
          ),
          // const SizedBox(height: 50),
          // Expanded(
          //   child: SizedBox(
          //     width: 450,
          //     child: ListView(
          //       children: [
          //         for (final level in gameLevels)
          //           ListTile(
          //             enabled: playerProgress.levels.length >= level.number - 1,
          //             onTap: () {
          //               final audioController = context.read<AudioController>();
          //               audioController.playSfx(SfxType.buttonTap);
          //
          //               GoRouter.of(context)
          //                   .go('/play/session/${level.number}');
          //             },
          //             leading: Text(
          //               level.number.toString(),
          //               style: levelTextStyle,
          //             ),
          //             title: Row(
          //               children: [
          //                 Text(
          //                   'Level #${level.number}',
          //                   style: levelTextStyle,
          //                 ),
          //                 if (playerProgress.levels.length <
          //                     level.number - 1) ...[
          //                   const SizedBox(width: 10),
          //                   const Icon(Icons.lock, size: 20),
          //                 ] else if (playerProgress.levels.length >=
          //                     level.number) ...[
          //                   const SizedBox(width: 50),
          //                   Text(
          //                     '${playerProgress.levels[level.number - 1]}s',
          //                     style: levelTextStyle,
          //                   ),
          //                 ],
          //               ],
          //             ),
          //           )
          //       ],
          //     ),
          //   ),
          // ),
          const SizedBox(height: 30),
          WobblyButton(
            onPressed: () {
              GoRouter.of(context).go('/play/session/1');
            },
            child: const Text('Play'),
          ),
          const SizedBox(height: 30),
          WobblyButton(
            onPressed: () {
              GoRouter.of(context).go('/');
            },
            child: const Text('Back'),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
