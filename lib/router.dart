import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'flame_game/game_screen.dart';
import 'level_selection/level_selection_screen.dart';
import 'level_selection/levels.dart';
import 'lobby_page/lobby_page.dart';
import 'main_menu/main_menu_screen.dart';
import 'settings/settings_screen.dart';
import 'style/page_transition.dart';
import 'style/palette.dart';

/// The router describes the game's navigational hierarchy, from the main
/// screen through settings screens all the way to each individual level.
///
final pGoRouter = Provider<GoRouter>((ref) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) =>
            const MainMenuScreen(key: Key('main menu')),
        routes: [
          GoRoute(
            path: 'play',
            pageBuilder: (context, state) => buildPageTransition<void>(
              key: const ValueKey('play'),
              color: ref.watch(pPalette).backgroundLevelSelection.color,
              child: const LevelSelectionScreen(
                key: Key('level selection'),
              ),
            ),
            routes: [
              GoRoute(
                path: 'session/:level',
                pageBuilder: (context, state) {
                  final levelNumber = int.parse(state.pathParameters['level']!);
                  final level = gameLevels[levelNumber - 1];
                  return buildPageTransition<void>(
                    key: const ValueKey('level'),
                    color: ref.watch(pPalette).backgroundPlaySession.color,
                    child: GameScreen(level: level),
                  );
                },
              ),
            ],
          ),
          GoRoute(
            path: 'lobby',
            pageBuilder: (context, state) => buildPageTransition<void>(
              key: const ValueKey('lobby'),
              color: ref.watch(pPalette).backgroundLevelSelection.color,
              child: const LobbyPage(),
            ),
          ),
          GoRoute(
            path: 'settings',
            builder: (context, state) => const SettingsScreen(
              key: Key('settings'),
            ),
          ),
        ],
      ),
    ],
  );
  return router;
});
