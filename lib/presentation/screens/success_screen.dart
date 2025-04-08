import 'package:flutter/material.dart';

import '../../domain/entities/matching_game.dart';
import '../widgets/confetti_overlay.dart';

/// A screen that displays a success message after completing a matching game
class SuccessScreen extends StatelessWidget {
  /// The matching game that was completed
  final MatchingGame game;

  /// The score achieved
  final int score;

  /// The total possible score
  final int totalPossibleScore;

  /// Callback when the user wants to play again
  final VoidCallback onPlayAgain;

  /// Constructor
  const SuccessScreen({
    super.key,
    required this.game,
    required this.score,
    required this.totalPossibleScore,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue.shade100,
                  Colors.blue.shade50,
                ],
              ),
            ),
          ),

          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Well Done!',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.purpleAccent,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'You matched all the animals correctly!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(game.colorValue),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                _buildStars(),
                const SizedBox(height: 32),
                Text(
                  'Score: $score/$totalPossibleScore',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: onPlayAgain,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(game.colorValue),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: const Text('Play Again'),
                ),
              ],
            ),
          ),

          // Confetti overlay
          const ConfettiOverlay(isActive: true),
        ],
      ),
    );
  }

  Widget _buildStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Icon(
            Icons.star,
            color: Colors.amber,
            size: 64,
            shadows: const [
              Shadow(
                blurRadius: 10.0,
                color: Colors.amber,
                offset: Offset(2.0, 2.0),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
