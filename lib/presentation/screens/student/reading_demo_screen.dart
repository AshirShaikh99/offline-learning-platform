import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/learning_activity_card.dart';

/// A demo screen that showcases the reading learning activities
class ReadingDemoScreen extends StatelessWidget {
  const ReadingDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(title: const Text('Interactive Reading'), elevation: 0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tap on any activity card below to explore interactive stories and improve your reading skills.',
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                color: Colors.white,
              ),
              selectionColor: Colors.white,
            ),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: isSmallScreen ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isSmallScreen ? 1.5 : 1.3,
                children: [
                  _buildStoryCard(isSmallScreen),
                  _buildFactsCard(isSmallScreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryCard(bool isSmallScreen) {
    return LearningActivityCard(
      title: 'Short Stories',
      icon: Icons.auto_stories,
      color: AppTheme.purpleColor,
      isSmallScreen: isSmallScreen,
      items: [
        {
          'reading': true,
          'title': 'The Friendly Frog',
          'pages': [
            {
              'title': 'The Friendly Frog',
              'content':
                  'Once upon a time, there was a small green frog named Freddy. Freddy lived in a beautiful pond at the edge of a forest. He loved to hop around and make friends with all the animals.',
              'image': 'forest',
              'question': {
                'text': 'Where did Freddy the frog live?',
                'options': [
                  'In a tree',
                  'In a pond',
                  'In a cave',
                  'In a house',
                ],
                'correctAnswer': 1,
                'selectedAnswer': null,
                'explanation':
                    'Freddy lived in a beautiful pond at the edge of a forest.',
                'hint': 'Frogs usually live in or near water.',
              },
            },
            {
              'title': 'Making Friends',
              'content':
                  'One sunny day, Freddy saw a rabbit who looked sad. "Hello! Why are you sad?" asked Freddy. "I have no one to play with," said the rabbit. "I will play with you!" said Freddy. They played all day and became good friends.',
              'question': {
                'text': 'Why was the rabbit sad?',
                'options': [
                  'It was hungry',
                  'It was lost',
                  'It had no one to play with',
                  'It was sick',
                ],
                'correctAnswer': 2,
                'selectedAnswer': null,
                'explanation':
                    'The rabbit was sad because it had no one to play with.',
                'hint': 'The rabbit needed a friend.',
              },
            },
            {
              'title': 'A New Problem',
              'content':
                  'The next day, Freddy and the rabbit saw a bird with a broken wing. "We need to help!" said Freddy. They carefully made a nest for the bird and brought it food. The bird was very thankful for their kindness.',
              'question': {
                'text': 'What problem did the bird have?',
                'options': [
                  'It was lost',
                  'It had a broken wing',
                  'It was hungry',
                  'It was scared',
                ],
                'correctAnswer': 1,
                'selectedAnswer': null,
                'explanation': 'The bird had a broken wing that needed help.',
                'hint': 'The bird couldn\'t fly because of this problem.',
              },
            },
            {
              'title': 'The Happy Ending',
              'content':
                  'After a few weeks, the bird\'s wing was better. "Thank you for helping me," said the bird. "You are welcome," said Freddy. "That\'s what friends do!" From that day on, the frog, the rabbit, and the bird were the best of friends and played together every day.',
              'question': {
                'text': 'What is the main lesson of this story?',
                'options': [
                  'Never talk to strangers',
                  'Always stay in the pond',
                  'Kindness and friendship are important',
                  'Birds can\'t be friends with frogs',
                ],
                'correctAnswer': 2,
                'selectedAnswer': null,
                'explanation':
                    'The story shows how kindness and friendship made all the animals happy.',
                'hint': 'Think about how the animals helped each other.',
              },
            },
          ],
        },
      ],
    );
  }

  Widget _buildFactsCard(bool isSmallScreen) {
    return LearningActivityCard(
      title: 'Amazing Facts',
      icon: Icons.lightbulb,
      color: AppTheme.orangeColor,
      isSmallScreen: isSmallScreen,
      items: [
        {
          'reading': true,
          'title': 'Ocean Wonders',
          'pages': [
            {
              'title': 'The Deep Blue Sea',
              'content':
                  'The ocean covers more than 70% of Earth\'s surface. It is home to millions of different types of plants and animals. Some parts of the ocean are so deep that sunlight cannot reach them!',
              'image': 'forest',
              'question': {
                'text': 'How much of Earth\'s surface is covered by oceans?',
                'options': [
                  'About 30%',
                  'About 50%',
                  'More than 70%',
                  'About 10%',
                ],
                'correctAnswer': 2,
                'selectedAnswer': null,
                'explanation':
                    'Oceans cover more than 70% of Earth\'s surface.',
                'hint': 'It\'s more than half of Earth\'s surface.',
              },
            },
            {
              'title': 'Amazing Octopus',
              'content':
                  'The octopus is one of the smartest animals in the ocean. It has three hearts and blue blood! Octopuses can change color to hide from predators. They can also squeeze through very small spaces because they have no bones.',
              'question': {
                'text': 'How many hearts does an octopus have?',
                'options': ['One', 'Two', 'Three', 'Four'],
                'correctAnswer': 2,
                'selectedAnswer': null,
                'explanation': 'An octopus has three hearts.',
                'hint': 'It\'s more than two but less than four.',
              },
            },
            {
              'title': 'Coral Reefs',
              'content':
                  'Coral reefs are like underwater cities. They are made up of tiny animals called coral polyps. Many fish and other sea creatures live in coral reefs. They are very colorful and beautiful, but they are in danger because of pollution and climate change.',
              'question': {
                'text': 'What are coral reefs made of?',
                'options': [
                  'Rocks and sand',
                  'Plants and seaweed',
                  'Tiny animals called coral polyps',
                  'Shells from dead sea creatures',
                ],
                'correctAnswer': 2,
                'selectedAnswer': null,
                'explanation':
                    'Coral reefs are made up of tiny animals called coral polyps.',
                'hint': 'Corals are not plants or rocks, but living creatures.',
              },
            },
            {
              'title': 'Ocean Giants',
              'content':
                  'The blue whale is the largest animal ever known to have lived on Earth. It can grow up to 100 feet long and weigh as much as 200 tons! Blue whales eat tiny shrimp-like animals called krill. A blue whale can eat up to 4 tons of krill in a single day.',
              'question': {
                'text': 'What do blue whales eat?',
                'options': ['Fish', 'Krill', 'Seaweed', 'Other whales'],
                'correctAnswer': 1,
                'selectedAnswer': null,
                'explanation':
                    'Blue whales eat tiny shrimp-like animals called krill.',
                'hint':
                    'It\'s a very small creature, despite the whale being so large.',
              },
            },
          ],
        },
      ],
    );
  }
}
