import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/image_composition.dart' as flame_image;
import 'package:flutter/material.dart';

import '../audio/audio_controller.dart';
import '../player_progress/player_progress.dart';
import 'components/player.dart';
import 'components/projectile.dart';
import 'critter_world.dart';

/// This is the base of the game which is added to the [GameWidget].
///
/// This class defines a few different properties for the game:
///  - That it should run collision detection, this is done through the
///  [HasCollisionDetection] mixin.
///  - That it should have a [FixedResolutionViewport] with a size of 1600x720,
///  this means that even if you resize the window, the game itself will keep
///  the defined virtual resolution.
///  - That the default world that the camera is looking at should be the
///  [CritterWorld].
///
/// Note that both of the last are passed in to the super constructor, they
/// could also be set inside of `onLoad` for example.
class CritterClashFlame extends FlameGame
    with PanDetector, HasCollisionDetection {
  CritterClashFlame({
    // required this.level,
    required PlayerProgress playerProgress,
    required this.audioController,
    required this.onGameOver,
    required this.onGameStateUpdate,
  }) : super(
        // world: CritterWorld(),
        // camera:
        // CameraComponent.withFixedResolution(width: 1920, height: 1080),
        // camera: CameraComponent.withFixedResolution(width: 1600, height: 720),
        );

  static const int _initialHealthPoints = 100;

  /// Callback to notify the parent when the game ends.
  final void Function(bool didWin) onGameOver;

  /// Callback for when the game state updates.
  final void Function(Vector2 position, int health) onGameStateUpdate;

  /// `Player` instance of the player
  late Player _player;

  // late Player _opponent;
  /// `List<Player>` instances of opponents
  late List<Player> _opponents;

  bool isGameOver = true;

  int _playerHealthPoint = _initialHealthPoints;

  // TODO get projectile images from [Player]
  late final flame_image.Image _playerProjectileImage;
  late final flame_image.Image _opponentProjectileImage;

  /// What the properties of the level that is played has.
  // final GameLevel level;

  /// A helper for playing sound effects and background audio.
  final AudioController audioController;

  // @override
  // Color backgroundColor() {
  //   return Colors
  //       .transparent; // TODO this is because the background image is set, fix if not
  // }

  /// In the [onLoad] method you load different type of assets and set things
  /// that only needs to be set once when the level starts up.
  @override
  Future<void> onLoad() async {
    // The backdrop is a static layer behind the world that the camera is
    // looking at, so here we add our parallax background.
    // camera.backdrop.add(Background(speed: world.speed));

    // With the `TextPaint` we define what properties the text that we are going
    // to render will have, like font family, size and color in this instance.
    final textRenderer = TextPaint(
      style: const TextStyle(
        fontSize: 30,
        color: Colors.white,
        fontFamily: 'Press Start 2P',
      ),
    );

    // final scoreText = 'Embers: 0 / ${level.winScore}';

    // The component that is responsible for rendering the text that contains
    // the current score.
    final scoreComponent = TextComponent(
      // text: scoreText,
      text: "Score",
      position: Vector2.all(30),
      textRenderer: textRenderer,
    );

    // The scoreComponent is added to the viewport, which means that even if the
    // camera's viewfinder move around and looks at different positions in the
    // world, the score is always static to the viewport.
    camera.viewport.add(scoreComponent);

    // Here we add a listener to the notifier that is updated when the player
    // gets a new point, in the callback we update the text of the
    // `scoreComponent`.
    // world.scoreNotifier.addListener(() {
    // scoreComponent.text =
    //     scoreText.replaceFirst('0', '${world.scoreNotifier.value}');
    // });

    // From Supabase tutorial
    final playerImage = await images.load('player.png');
    _player = Player(isMe: true, playerIndex: 0); // TODO pass in Player Index!
    final spriteSize = Vector2.all(Player.radius * 2);
    _player.add(SpriteComponent(sprite: Sprite(playerImage), size: spriteSize));
    add(_player);

    // final opponentImage = await images.load('opponent.png');
    // _opponent = Player(isMe: false);
    // _opponent.add(SpriteComponent.fromImage(opponentImage, size:spriteSize));
    // add(_opponent);
    //
    // _playerProjectileImage = await images.load('player-bullet.png');
    // _opponentBulletImage = await images.load('opponent-bullet.png');

    await super.onLoad();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _player.move(info.delta.global);
    // final mirroredPosition = _player.getMirroredPercentPosition();
    onGameStateUpdate(_player.position, _playerHealthPoint);
    super.onPanUpdate(info);
  }

  // @override
  // void update(double dt) {
  //   super.update(dt);
  //   if (isGameOver) {
  //     return;
  //   }
  //   for (final child in children) {
  //     if (child is Projectile && child.hasBeenHit && !child.isMine) {
  //       _playerHealthPoint = _playerHealthPoint - child.damage;
  //       // final mirroredPosition = _player.getMirroredPercentPosition();
  //       onGameStateUpdate(_player.position, _playerHealthPoint);
  //       // _player.updateHealth(_playerHealthPoint / _initialHealthPoints);
  //     }
  //   }
  //   if (_playerHealthPoint <= 0) {
  //     endGame(false); // TODO ends game for just two players...
  //   }
  // }

  void startNewGame() {
    isGameOver = false;
    _playerHealthPoint = _initialHealthPoints;

    for (final child in children) {
      if (child is Player) {
        child.position = child.initialPosition;
      } else if (child is Projectile) {
        child.removeFromParent();
      }
    }

    // _shootProjectiles(); // Only used to shoot a continuous string of bullets
    // from the asteroids example...
  }

  /// Throws a projectile from the player
  Future<void> _throwProjectile() async {
    /// Player's projectile
    final playerProjectileInitialPosition = Vector2.copy(_player.position)
      ..y -= Player.radius;
    final playerProjectileVelocities = [
      // TODO Get these velocities based on where they are aiming
      Vector2(0, -100),
      // Vector2(60, -80),
      // Vector2(-60, -80),
    ];
    for (final projectileVelocity in playerProjectileVelocities) {
      add((Projectile(
        isMine: true,
        velocity: projectileVelocity,
        image: _playerProjectileImage,
        initialPosition: playerProjectileInitialPosition,
      )));
    }
  }

  void updateOpponent({required Vector2 position, required int health}) {
    // TODO make this a list...
    // TODO TODO TODO uncomment this and make it work for more players!!!
    // _opponent.position = Vector2(size.x * position.x, size.y * position.y);
    // _opponent.updateHealth(health / _initialHealthPoints);
  }

  /// Called when either the player or the opponent has run out of health points
  void endGame(bool playerWon) {
    isGameOver = true;
    onGameOver(playerWon);
  }
}
