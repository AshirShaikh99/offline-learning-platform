import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/learning_activity_card.dart';

/// A demo screen that showcases the word formation learning activities
class WordFormationDemoScreen extends StatelessWidget {
  const WordFormationDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Formation'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.textOnDarkColor,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Word Formation Activities',
              style: AppTheme.titleLarge.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Drag and drop letters to form words. Choose a category below to start.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: isSmallScreen ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isSmallScreen ? 1.5 : 1.3,
                children: [
                  _buildAnimalsCard(isSmallScreen),
                  _buildFruitsCard(isSmallScreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimalsCard(bool isSmallScreen) {
    return LearningActivityCard(
      title: 'Animals',
      icon: Icons.pets,
      color: AppTheme.purpleColor,
      isSmallScreen: isSmallScreen,
      items: [
        {
          'wordFormation': true,
          'title': 'Animal Words',
          'challenges': [
            {
              'word': 'CAT',
              'hint': 'A small furry pet that meows',
            },
            {
              'word': 'DOG',
              'hint': 'A loyal pet that barks',
            },
            {
              'word': 'LION',
              'hint': 'The king of the jungle',
            },
            {
              'word': 'TIGER',
              'hint': 'A large wild cat with stripes',
            },
            {
              'word': 'ELEPHANT',
              'hint': 'A large animal with a trunk',
            },
          ],
        }
      ],
    );
  }

  Widget _buildFruitsCard(bool isSmallScreen) {
    return LearningActivityCard(
      title: 'Fruits',
      icon: Icons.apple,
      color: AppTheme.orangeColor,
      isSmallScreen: isSmallScreen,
      items: [
        {
          'wordFormation': true,
          'title': 'Fruit Words',
          'challenges': [
            {
              'word': 'APPLE',
              'hint': 'A round fruit that can be red or green',
            },
            {
              'word': 'BANANA',
              'hint': 'A long yellow fruit',
            },
            {
              'word': 'ORANGE',
              'hint': 'A citrus fruit with the same name as a color',
            },
            {
              'word': 'GRAPE',
              'hint': 'Small round fruits that grow in bunches',
            },
            {
              'word': 'MANGO',
              'hint': 'A sweet tropical fruit with orange flesh',
            },
          ],
        }
      ],
    );
  }
}
