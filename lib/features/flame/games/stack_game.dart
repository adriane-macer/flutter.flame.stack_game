import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flame_stack_game/features/flame/logic/game_cubit.dart';

class StackGame extends FlameGame with TapCallbacks {
  final GameCubit cubit;

  // Track the block currently moving and the one it must land on
  late RectangleComponent movingBlock;
  RectangleComponent? lastBlock;

  double currentWidth = 200.0;
  double speed = 250.0;
  int direction = 1;
  late TextComponent scoreText;

  final List<RectangleComponent> _movingBlocks = <RectangleComponent>[];

  StackGame(this.cubit);

  @override
  Future<void> onLoad() async {
    _addInitialPlatform();
    _spawnMovingBlock();
    // Add Score Text to the HUD
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(60, 60),
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(blurRadius: 10, color: Colors.black)],
        ),
      ),
    );

    add(scoreText);

    overlays.add('StartMenu');
  }

  void _addInitialPlatform() {
    // This is the base that never moves
    lastBlock = RectangleComponent(
      size: Vector2(currentWidth, 20),
      position: Vector2((size.x - currentWidth) / 2, size.y - 100),
      paint: Paint()..color = Colors.grey,
    );
    add(lastBlock!);
  }

  void _spawnMovingBlock() {
    movingBlock = RectangleComponent(
      size: Vector2(currentWidth, 20),
      // Spawn slightly higher based on score
      position: Vector2(0, lastBlock!.position.y - 20),
      paint: Paint()..color = Colors.blueAccent,
    );
    _movingBlocks.add(movingBlock);
    add(movingBlock);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (cubit.state.status != GameStatus.playing) return;

    movingBlock.position.x += direction * speed * dt;

    // Bounce off screen edges
    if (direction == 1 && movingBlock.position.x + movingBlock.width > size.x) {
      direction = -1;
    } else if(direction == -1 && movingBlock.position.x < 0){
      direction = 1;
    }
  }

  @override
  void onTapDown(event) {
    if (cubit.state.status != GameStatus.playing) return;


    final double diff = movingBlock.position.x - lastBlock!.position.x;

    //  Check if the block completely missed the one below
    if (diff.abs() >= currentWidth) {
      cubit.gameOver();
      overlays.add('GameOver');
      return;
    }

    //  Calculate new width (Old Width - Absolute Difference)
    currentWidth -= diff.abs();

    // Update the moving block to be the "new" static lastBlock
    // We adjust its size and position to represent the 'trimmed' version
    movingBlock.size.x = currentWidth;

    if (diff > 0) {
      // Overhang was on the right, position stays the same
    } else {
      // Overhang was on the left, shift position to match the edge
      movingBlock.position.x = lastBlock!.position.x;
    }

    lastBlock = movingBlock; // The current moving block becomes the new base
    cubit.incrementScore();
    scoreText.text = 'Score: ${cubit.state.score}'; // Update Score UI

    // // --- CAMERA FOLLOW LOGIC ---
    // // We want the camera to look at the top of the stack.
    // // As the stack grows (y decreases), we move the camera up.
    // final targetY = movingBlock.position.y - (size.y * 0.4);
    // camera.viewfinder.position = Vector2(size.x / 2, targetY);

    //  Increase difficulty and spawn next
    speed += 10;
    _spawnMovingBlock();
  }

  void reset() {
    for (final block in _movingBlocks) {
      remove(block);
    }
    scoreText.text = 'Score: 0';
    _movingBlocks.clear();

    currentWidth = 200.0;
    speed = 250.0;
    _addInitialPlatform();
    _spawnMovingBlock();
    resumeEngine();
  }
}
