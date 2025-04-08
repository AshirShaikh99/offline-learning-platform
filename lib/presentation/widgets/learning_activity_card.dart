import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../screens/student/flame_spelling_game_screen.dart';
import '../screens/student/learning_activity_screen.dart';
import '../screens/student/matching_game_demo_screen.dart';
import '../screens/student/reading_activity_screen.dart';
import '../screens/student/reading_demo_screen.dart';
import '../screens/student/story_time_screen.dart';
import '../screens/student/word_formation_screen.dart';
import '../screens/student/word_formation_demo_screen.dart';

class LearningActivityCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<Map<String, dynamic>> items;
  final bool isSmallScreen;

  const LearningActivityCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              if (items.first.containsKey('word')) {
                // Navigate to Flame spelling game
                return FlameSpellingGameScreen(
                  words: List<Map<String, String>>.from(items),
                  color: color,
                );
              } else if (items.first.containsKey('reading')) {
                // Check if this is the main reading card from dashboard
                if (items.first['title'] == 'Interactive Reading') {
                  // Navigate to Reading Demo screen
                  return const ReadingDemoScreen();
                } else {
                  // Navigate to specific Reading Activity screen
                  return ReadingActivityScreen(
                    title: title,
                    color: color,
                    content: items.first,
                  );
                }
              } else if (items.first.containsKey('wordFormation')) {
                // Check if this is the main word formation card from dashboard
                if (items.first['title'] == 'Word Formation') {
                  // Navigate to Word Formation Demo screen
                  return const WordFormationDemoScreen();
                } else {
                  // Navigate to specific Word Formation Activity screen
                  return WordFormationScreen(
                    title: title,
                    color: color,
                    challenges:
                        items.first['challenges'] as List<Map<String, dynamic>>,
                  );
                }
              } else if (items.first.containsKey('matching')) {
                // Check if this is the main matching card from dashboard
                if (items.first['title'] == 'Matching Games') {
                  // Navigate to Matching Game Demo screen
                  return const MatchingGameDemoScreen();
                }
              } else if (items.first.containsKey('storyTime')) {
                // Navigate to Story Time screen
                return StoryTimeScreen(title: title, color: color);
              }
              // Handle other activities
              return LearningActivityScreen(
                title: title,
                color: color,
                items: items,
              );
            },
          ),
        );
      },
      child: Container(
        width: isSmallScreen ? 160 : 200,
        margin: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withAlpha((0.8 * 255).toInt())],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.3 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSmallScreen ? 40 : 48,
              color: AppTheme.textOnDarkColor,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.textOnDarkColor,
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
