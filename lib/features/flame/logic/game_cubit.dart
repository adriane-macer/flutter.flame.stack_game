import 'package:bloc/bloc.dart';

part 'game_state.dart';


enum GameStatus { initial, playing, gameOver }

class GameCubit extends Cubit<GameState> {
  GameCubit() : super(GameState(status: GameStatus.initial, score: 0));

  void startGame() => emit(GameState(status: GameStatus.playing, score: 0));

  void incrementScore() => emit(GameState(status: GameStatus.playing, score: state.score + 1));

  void gameOver() => emit(GameState(status: GameStatus.gameOver, score: state.score));
}
