import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/animal_matching_data.dart';
import '../improved_matching_game_screen.dart';

/// A demo screen that shows different matching game options
class MatchingGameDemoScreen extends StatelessWidget {
  /// Constructor
  const MatchingGameDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Matching Games'),
        backgroundColor: AppTheme.purpleColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.blue.shade50],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Text(
                  'Choose a Matching Game',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.purpleColor,
                  ),
                ),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: isSmallScreen ? 2 : 3,
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                  mainAxisSpacing: isSmallScreen ? 16 : 24,
                  crossAxisSpacing: isSmallScreen ? 16 : 24,
                  children: [
                    _buildGameCard(
                      context,
                      title: 'Animals',
                      icon: Icons.pets,
                      color: AppTheme.purpleColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              final game =
                                  AnimalMatchingData.getAnimalMatchingGame();
                              return ImprovedMatchingGameScreen(game: game);
                            },
                          ),
                        );
                      },
                    ),
                    _buildGameCard(
                      context,
                      title: 'Fruits',
                      icon: Icons.apple,
                      color: AppTheme.orangeColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              final game =
                                  AnimalMatchingData.getFruitMatchingGame();
                              return ImprovedMatchingGameScreen(game: game);
                            },
                          ),
                        );
                      },
                    ),
                    _buildGameCard(
                      context,
                      title: 'Colors',
                      icon: Icons.color_lens,
                      color: AppTheme.blueColor,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) {
                              final game =
                                  AnimalMatchingData.getColorMatchingGame();
                              return ImprovedMatchingGameScreen(game: game);
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color,
                color.withAlpha(204), // 80% opacity
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withAlpha(76), // 30% opacity
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
