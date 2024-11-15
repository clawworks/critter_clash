import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../../audio/sounds.dart';
import '../critter_clash_flame.dart';
import '../critter_world.dart';
import '../effects/hurt_effect.dart';
import 'obstacle.dart';
import 'point.dart';
import 'projectile.dart';

/// The [Player] is the component that the physical player of the game is
/// controlling.
class Player extends SpriteAnimationGroupComponent<PlayerState>
    with
        CollisionCallbacks,
        HasWorldReference<CritterWorld>,
        HasGameReference<CritterClashFlame> {
  Player({
    // required this.addScore,
    // required this.resetScore,
    required this.isMe,
    required this.playerIndex,
    super.position,
  })  : _isMyPlayer = isMe,
        super(size: Vector2.all(150), anchor: Anchor.center, priority: 1);

  Vector2 velocity = Vector2.zero();

  late final Vector2 initialPosition;

  // final void Function({int amount}) addScore;
  // final VoidCallback resetScore;
  final bool isMe;
  final int playerIndex;

  /// Whether it's my player or an opponent
  final bool _isMyPlayer;

  static const radius = 30.0;

  // The current velocity that the player has that comes from being affected by
  // the gravity. Defined in virtual pixels/s².
  // double _gravityVelocity = 0;

  // The maximum length that the player can jump. Defined in virtual pixels.
  // final double _jumpLength = 600;

  // Whether the player is currently in the air, this can be used to restrict
  // movement for example.
  // bool get inAir => (position.y + size.y / 2) < world.groundLevel;

  // Used to store the last position of the player, so that we later can
  // determine which direction that the player is moving.
  // final Vector2 _lastPosition = Vector2.zero();

  // When the player has velocity pointing downwards it is counted as falling,
  // this is used to set the correct animation for the player.
  // bool get isFalling => _lastPosition.y < position.y;

  @override
  Future<void> onLoad() async {
    // This defines the different animation states that the player can be in.
    animations = {
      PlayerState.running: await game.loadSpriteAnimation(
        'dash/dash_running.png',
        SpriteAnimationData.sequenced(
          amount: 4,
          textureSize: Vector2.all(16),
          stepTime: 0.15,
        ),
      ),
      // TODO add player state sprite animations...
      // PlayerState.jumping: SpriteAnimation.spriteList(
      //   [await game.loadSprite('dash/dash_jumping.png')],
      //   stepTime: double.infinity,
      // ),
      // PlayerState.falling: SpriteAnimation.spriteList(
      //   [await game.loadSprite('dash/dash_falling.png')],
      //   stepTime: double.infinity,
      // ),
    };
    // The starting state will be that the player is running.
    current = PlayerState.running;
    // _lastPosition.setFrom(position);

    // From Supabase Asteroids tutorial
    anchor = Anchor.center;
    width = radius * 2;
    height = radius * 2;

    final initialX =
        playerIndex % 2 == 0 ? game.size.x * 0.2 : game.size.x * 0.8;
    final initialY =
        playerIndex % 4 < 2 ? game.size.y * 0.2 : game.size.y * 0.8;
    initialPosition = Vector2(initialX, initialY);
    position = initialPosition;

    // When adding a CircleHitbox without any arguments it automatically
    // fills up the size of the component as much as it can without overflowing
    // it.
    add(CircleHitbox());
    // add(_Guage()); // add a health gage if needed

    await super.onLoad();
  }

  void move(Vector2 delta) {
    position += delta;
  }

  // Add this if you want a health gauge
  // void updateHealth(double healthLeft) {
  //   for (final child in children) {
  //     if (child is _Gauge) {
  //       child._healthLeft = healthLeft;
  //     }
  //   }
  // }

  @override
  void update(double dt) {
    super.update(dt);
    // When we are in the air the gravity should affect our position and pull
    // us closer to the ground.
    // if (inAir) {
    //   _gravityVelocity += world.gravity * dt;
    //   position.y += _gravityVelocity;
    //   if (isFalling) {
    //     current = PlayerState.falling;
    //   }
    // }

    // If we want to add walls handle them here... (aka, don't let us run through them)
    final belowGround = position.y + size.y / 2 > world.groundLevel;
    // If the player's new position would overshoot the ground level after
    // updating its position we need to move the player up to the ground level
    // again.
    if (belowGround) {
      position.y = world.groundLevel - size.y / 2;
      // _gravityVelocity = 0;
      current = PlayerState.running;
    }

    // _lastPosition.setFrom(position);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);
    // When the player collides with an obstacle it should lose all its points.
    if (other is Projectile) {
      game.audioController.playSfx(SfxType.damage);
      other.hasBeenHit = true;
      other.removeFromParent();
      // resetScore();
      add(HurtEffect());
    } else if (other is Obstacle) {
      game.audioController.playSfx(SfxType.damage);
      // TODO stop them from moving...?
    } else if (other is Point) {
      // When the player collides with a point it should gain a point and remove
      // the `Point` from the game.
      game.audioController.playSfx(SfxType.score);
      other.removeFromParent();
      // addScore();
    }
  }

  // /// [towards] should be a normalized vector that points in the direction that
  // /// the player should jump.
  // void jump(Vector2 towards) {
  //   current = PlayerState.jumping;
  //   // Since `towards` is normalized we need to scale (multiply) that vector by
  //   // the length that we want the jump to have.
  //   final jumpEffect = JumpEffect(towards..scaleTo(_jumpLength));
  //
  //   // We only allow jumps when the player isn't already in the air.
  //   if (!inAir) {
  //     game.audioController.playSfx(SfxType.jump);
  //     add(jumpEffect);
  //   }
  // }
}

enum PlayerState {
  idle,
  running,
  aiming,
  throwing,
  hit,
  out,
}
