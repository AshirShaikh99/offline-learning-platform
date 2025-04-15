import 'package:flutter/material.dart';
import 'learn_urdu_screen.dart';
import 'numbers_activity_screen.dart';
import 'reading_activity_screen.dart';
import 'story_time_screen.dart';
import 'matching_game_demo_screen.dart';
import 'word_formation_demo_screen.dart';

class LearningActivityScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> items;
  final Color color;

  const LearningActivityScreen({
    Key? key,
    required this.title,
    required this.items,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D95).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFFFF2D95),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            Expanded(child: _buildActivityContent(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _getIconForActivity(title),
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getDescriptionForActivity(title),
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityContent(BuildContext context) {
    // Handle special activity types
    if (_hasSpecialActivity()) {
      return _buildSpecialActivity(context);
    }

    // Regular grid activity
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _buildItemCard(item);
      },
    );
  }

  Widget _buildItemCard(Map<String, dynamic> item) {
    final hasEmoji = item.containsKey('emoji');
    final hasIcon = item.containsKey('icon');

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF121212),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(16),
          splashColor: color.withOpacity(0.3),
          highlightColor: color.withOpacity(0.1),
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (hasEmoji)
                  Text(
                    item['emoji'] as String,
                    style: const TextStyle(fontSize: 32),
                  ),
                if (hasIcon)
                  Icon(item['icon'] as IconData, color: color, size: 36),
                if (!hasEmoji && !hasIcon)
                  Text(
                    item['text'] as String,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  item['text'] as String,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasSpecialActivity() {
    if (items.isEmpty) return false;
    final item = items.first;
    return item.containsKey('reading') ||
        item.containsKey('wordFormation') ||
        item.containsKey('matching') ||
        item.containsKey('storyTime') ||
        item.containsKey('learnUrdu');
  }

  Widget _buildSpecialActivity(BuildContext context) {
    final type = title.toLowerCase();

    if (type.contains('urdu')) {
      return const LearnUrduScreen();
    } else if (type.contains('numbers')) {
      return NumbersActivityScreen(title: title, color: color);
    } else if (type.contains('reading')) {
      return ReadingActivityScreen(title: title, color: color);
    } else if (type.contains('story')) {
      return StoryTimeScreen(title: title, color: color);
    } else if (type.contains('match')) {
      return MatchingGameDemoScreen(title: title, color: color);
    } else if (type.contains('word')) {
      return WordFormationDemoScreen(title: title, color: color);
    }

    // Fallback
    return Center(
      child: Text(
        'Activity coming soon!',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  IconData _getIconForActivity(String title) {
    final type = title.toLowerCase();

    if (type.contains('urdu') || type.contains('sindhi')) {
      return Icons.language;
    } else if (type.contains('number')) {
      return Icons.format_list_numbered;
    } else if (type.contains('alphabet')) {
      return Icons.abc;
    } else if (type.contains('read')) {
      return Icons.menu_book;
    } else if (type.contains('word')) {
      return Icons.text_fields;
    } else if (type.contains('match')) {
      return Icons.extension;
    } else if (type.contains('story')) {
      return Icons.auto_stories;
    } else if (type.contains('shape')) {
      return Icons.category;
    } else if (type.contains('animal')) {
      return Icons.pets;
    }

    return Icons.school;
  }

  String _getDescriptionForActivity(String title) {
    final type = title.toLowerCase();

    if (type.contains('urdu') || type.contains('sindhi')) {
      return 'Learn language with interactive exercises';
    } else if (type.contains('number')) {
      return 'Practice counting and number recognition';
    } else if (type.contains('alphabet')) {
      return 'Learn letters and basic phonics';
    } else if (type.contains('read')) {
      return 'Improve reading skills with interactive stories';
    } else if (type.contains('word')) {
      return 'Build vocabulary and spelling skills';
    } else if (type.contains('match')) {
      return 'Match items to improve memory and recognition';
    } else if (type.contains('story')) {
      return 'Enjoy interactive stories with animations';
    } else if (type.contains('shape')) {
      return 'Learn different shapes and their properties';
    } else if (type.contains('animal')) {
      return 'Discover amazing animals and their habitats';
    }

    return 'Interactive learning activities for kids';
  }
}
