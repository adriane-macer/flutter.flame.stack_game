import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_flame_stack_game/features/flame/games/stack_game.dart';
import 'package:flutter_flame_stack_game/features/flame/logic/game_cubit.dart';

class StackGameWidget extends StatelessWidget {
  const StackGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<GameCubit>();
    final game = StackGame(cubit);

    return Scaffold(
      body: BlocBuilder<GameCubit, GameState>(
        builder: (context, state) {
          return GameWidget(
            game: game,
            overlayBuilderMap: {
              'StartMenu': (context, StackGame game) {
                return Center(
                child: ElevatedButton(
                  onPressed: () {
                    game.overlays.remove('StartMenu');
                    cubit.startGame();
                  },
                  child: Text("Start Game"),
                ),
              );
              },
              'GameOver': (context, StackGame game) => Center(
                child: Container(
                  color: Colors.black54,
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Game Over!", style: TextStyle(color: Colors.white, fontSize: 30)),
                      Text("Score: ${state.score}", style: TextStyle(color: Colors.white)),
                      ElevatedButton(
                        onPressed: () {
                          game.overlays.remove('GameOver');
                          game.reset();
                          cubit.startGame();
                        },
                        child: Text("Play Again"),
                      ),
                    ],
                  ),
                ),
              ),
            },
            // initialActiveOverlays: const ['StartMenu'],
          );
        },
      ),
    );
  }

}