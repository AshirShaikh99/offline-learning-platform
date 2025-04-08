import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:off/games/spelling_game/spelling_game.dart';

class FlameSpellingGameScreen extends StatelessWidget {
  final List<Map<String, String>> words;
  final Color color;

  const FlameSpellingGameScreen({
    super.key,
    required this.words,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spelling Game'),
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      body: GameWidget(game: SpellingGame(wordList: words)),
    );
  }
}
