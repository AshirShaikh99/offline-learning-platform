import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import 'content_viewer_screen.dart';
import 'learn_urdu_screen.dart';
import '../../widgets/learning_activity_card.dart';

/// Student dashboard screen
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final List<Map<String, dynamic>> _subjects = [
    {'name': 'English', 'icon': Icons.book, 'color': Colors.blue},
    {'name': 'Math', 'icon': Icons.calculate, 'color': Colors.red},
    {'name': 'Science', 'icon': Icons.science, 'color': Colors.green},
    {'name': 'Social Studies', 'icon': Icons.public, 'color': Colors.orange},
    {'name': 'Computer', 'icon': Icons.computer, 'color': Colors.purple},
    {'name': 'Islamiat', 'icon': Icons.mosque, 'color': Colors.teal},
    {'name': 'GK', 'icon': Icons.psychology, 'color': Colors.brown},
    {'name': 'Urdu', 'icon': Icons.language, 'color': Colors.indigo},
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8EAC8),
            body: CustomScrollView(
              slivers: [
                _buildAppBar(isSmallScreen),
                SliverToBoxAdapter(
                  child: _buildWelcomeSection(isSmallScreen, state.user),
                ),
                // Use SliverMainAxisGroup for better performance
                SliverMainAxisGroup(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildActivitiesSection(isSmallScreen),
                    ),
                  ],
                ),
                SliverPadding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  sliver: _buildSubjectGrid(isSmallScreen),
                ),
              ],
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildAppBar(bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 100 : 120,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: isSmallScreen ? 12 : 16,
          bottom: isSmallScreen ? 12 : 16,
        ),
        title: Text(
          'Student Dashboard',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 20 : 24,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.logout,
            color: Colors.white,
            size: isSmallScreen ? 22 : 24,
          ),
          onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
        ),
        SizedBox(width: isSmallScreen ? 8 : 16),
      ],
    );
  }

  Widget _buildWelcomeSection(bool isSmallScreen, User user) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        isSmallScreen ? 12 : 16,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 12 : 16,
        isSmallScreen ? 12 : 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Welcome ${user.username}',
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 24 : 28,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'Class: ${user.className}',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.black54,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectGrid(bool isSmallScreen) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 3,
        childAspectRatio: isSmallScreen ? 1.1 : 1.3,
        crossAxisSpacing: isSmallScreen ? 12 : 16,
        mainAxisSpacing: isSmallScreen ? 12 : 16,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final subject = _subjects[index];
        return _buildSubjectCard(
          subject['name'] as String,
          subject['icon'] as IconData,
          subject['color'] as Color,
          isSmallScreen,
        );
      }, childCount: _subjects.length),
    );
  }

  Widget _buildSubjectCard(
    String subjectName,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            ),
            child: InkWell(
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ContentViewerScreen(
                            className: state.user.className!,
                            subject: subjectName,
                          ),
                    ),
                  ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withAlpha((0.8 * 255).toInt())],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha((0.2 * 255).toInt()),
                      blurRadius: isSmallScreen ? 6 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -20,
                      bottom: -20,
                      child: Icon(
                        icon,
                        size: isSmallScreen ? 80 : 100,
                        color: Colors.white.withAlpha(51), // 0.2 * 255 = 51
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            color: Colors.white,
                            size: isSmallScreen ? 28 : 32,
                          ),
                          const Spacer(),
                          Text(
                            subjectName,
                            style: AppTheme.titleLarge.copyWith(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 16 : 18,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 6 : 8),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 10 : 12,
                              vertical: isSmallScreen ? 4 : 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(
                                51,
                              ), // 0.2 * 255 = 51
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'View Content',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 10 : 12,
                              ),
                            ),
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
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildActivitiesSection(bool isSmallScreen) {
    final activities = [
      {
        'title': 'Numbers',
        'icon': Icons.format_list_numbered,
        'color': AppTheme.primaryColor,
        'items': List.generate(10, (index) => {'text': '${index + 1}'}),
      },
      {
        'title': 'Alphabets',
        'icon': Icons.abc,
        'color': AppTheme.secondaryColor,
        'items': List.generate(
          26,
          (index) => {'text': String.fromCharCode(65 + index)},
        ),
      },
      // Interactive Reading Activities
      {
        'title': 'Reading',
        'icon': Icons.auto_stories,
        'color': AppTheme.tealColor,
        'items': [
          {
            'reading': true,
            'title': 'Interactive Reading',
            'pages': [
              {
                'title': 'Welcome to Reading',
                'content':
                    'Tap on this card to explore interactive stories and improve your reading skills. You can read stories, learn facts, and answer questions.',
                'question': {
                  'text': 'What can you do with reading activities?',
                  'options': [
                    'Only look at pictures',
                    'Read stories and answer questions',
                    'Play music',
                    'Draw pictures',
                  ],
                  'correctAnswer': 1,
                  'selectedAnswer': null,
                  'explanation':
                      'You can read stories and answer questions to improve your reading skills.',
                  'hint': 'Think about what you do when reading a book.',
                },
              },
            ],
          },
        ],
      },
      // Word Formation Activity
      {
        'title': 'Word Formation',
        'icon': Icons.text_fields,
        'color': AppTheme.purpleColor,
        'items': [
          {
            'wordFormation': true,
            'title': 'Word Formation',
            'challenges': [
              {
                'word': 'WORD',
                'hint':
                    'A single unit of language that has meaning and can be spoken or written',
              },
            ],
          },
        ],
      },
      // Matching Game Activity
      {
        'title': 'Matching Games',
        'icon': Icons.connect_without_contact,
        'color': Colors.teal,
        'items': [
          {'matching': true, 'title': 'Matching Games'},
        ],
      },
      // Story Time Activity
      {
        'title': 'Story Time',
        'icon': Icons.auto_stories,
        'color': Colors.indigo,
        'items': [
          {'storyTime': true, 'title': 'Interactive Stories'},
        ],
      },
      // Learn Urdu Activity
      {
        'title': 'Learn Urdu',
        'icon': Icons.language,
        'color': AppTheme.indigoColor,
        'items': [
          {'learnUrdu': true, 'title': 'Learn Urdu with Voice'},
        ],
      },
      {
        'title': 'Shapes',
        'icon': Icons.category,
        'color': Colors.orange,
        'items': [
          {'text': 'Circle', 'icon': Icons.circle_outlined},
          {'text': 'Square', 'icon': Icons.square_outlined},
          {'text': 'Triangle', 'icon': Icons.change_history_outlined},
          {'text': 'Rectangle', 'icon': Icons.rectangle_outlined},
          {'text': 'Diamond', 'icon': Icons.diamond_outlined},
          {'text': 'Star', 'icon': Icons.star_outline},
          {'text': 'Pentagon', 'icon': Icons.pentagon_outlined},
          {'text': 'Oval', 'icon': Icons.panorama_fish_eye},
        ],
      },
      {
        'title': 'Animals',
        'icon': Icons.pets,
        'color': Colors.purple,
        'items': [
          {'text': 'Lion', 'emoji': '🦁'},
          {'text': 'Tiger', 'emoji': '🐯'},
          {'text': 'Elephant', 'emoji': '🐘'},
          {'text': 'Giraffe', 'emoji': '🦒'},
          {'text': 'Monkey', 'emoji': '🐒'},
          {'text': 'Zebra', 'emoji': '🦓'},
          {'text': 'Panda', 'emoji': '🐼'},
          {'text': 'Penguin', 'emoji': '🐧'},
          {'text': 'Koala', 'emoji': '🐨'},
          {'text': 'Kangaroo', 'emoji': '🦘'},
          {'text': 'Horse', 'emoji': '🐎'},
          {'text': 'Dog', 'emoji': '🐕'},
          {'text': 'Cat', 'emoji': '🐈'},
          {'text': 'Rabbit', 'emoji': '🐇'},
          {'text': 'Bear', 'emoji': '🐻'},
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
          child: Text(
            'Learning Activities',
            style: AppTheme.titleLarge.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 20 : 24,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: isSmallScreen ? 160 : 200,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return LearningActivityCard(
                title: activity['title'] as String,
                icon: activity['icon'] as IconData,
                color: activity['color'] as Color,
                items: List<Map<String, dynamic>>.from(
                  activity['items'] as List,
                ),
                isSmallScreen: isSmallScreen,
              );
            },
          ),
        ),
      ],
    );
  }
}
