import 'package:flutter/material.dart';
import '../screens/student/learning_activity_screen.dart';
import '../screens/student/spelling_game_screen.dart';

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
                // Handle spelling game
                return SpellingGameScreen(
                  words: List<Map<String, String>>.from(items),
                  color: color,
                );
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
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: isSmallScreen ? 40 : 48, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
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
