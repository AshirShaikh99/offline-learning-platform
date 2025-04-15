import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/user.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../login_screen.dart';
import 'content_viewer_screen.dart';
import 'learn_urdu_screen.dart';
import '../../widgets/learning_activity_card.dart';

/// Student dashboard screen
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  final List<Map<String, dynamic>> _subjects = [
    {'name': 'English', 'icon': Icons.book, 'color': const Color(0xFFFF2D95)},
    {'name': 'Math', 'icon': Icons.calculate, 'color': const Color(0xFF00E5FF)},
    {
      'name': 'Science',
      'icon': Icons.science,
      'color': const Color(0xFF39FF14),
    },
    {
      'name': 'Social Studies',
      'icon': Icons.public,
      'color': const Color(0xFFFFA500),
    },
    {
      'name': 'Computer',
      'icon': Icons.computer,
      'color': const Color(0xFFAA00FF),
    },
    {
      'name': 'Islamiat',
      'icon': Icons.mosque,
      'color': const Color(0xFF00FFCC),
    },
    {'name': 'GK', 'icon': Icons.psychology, 'color': const Color(0xFFFFD700)},
    {'name': 'Urdu', 'icon': Icons.language, 'color': const Color(0xFF1E90FF)},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is Unauthenticated,
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return Scaffold(
              backgroundColor: Colors.black,
              body: SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(isSmallScreen),
                    SliverToBoxAdapter(
                      child: _buildWelcomeSection(isSmallScreen, state.user),
                    ),
                    SliverToBoxAdapter(
                      child: _buildActivitiesSection(isSmallScreen),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      sliver: _buildSubjectGrid(isSmallScreen),
                    ),
                    // Add bottom padding to prevent overflow
                    SliverToBoxAdapter(
                      child: SizedBox(
                        height: MediaQuery.of(context).padding.bottom + 16,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFFF2D95)),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(bool isSmallScreen) {
    return SliverAppBar(
      expandedHeight: isSmallScreen ? 80 : 100,
      floating: true,
      pinned: true,
      stretch: true,
      automaticallyImplyLeading: false,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: isSmallScreen ? 16 : 24,
          bottom: isSmallScreen ? 16 : 24,
          right: isSmallScreen ? 16 : 24,
        ),
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2D95).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.school,
                    color: const Color(0xFFFF2D95),
                    size: isSmallScreen ? 18 : 22,
                  ),
                ),
                const SizedBox(width: 10),
                const Flexible(
                  child: Text(
                    'Learning Space',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
      ),
      actions: [
        IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(
              Icons.logout_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
        ),
        SizedBox(width: isSmallScreen ? 8 : 16),
      ],
    );
  }

  Widget _buildWelcomeSection(bool isSmallScreen, User user) {
    return Container(
      margin: EdgeInsets.fromLTRB(
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24,
        isSmallScreen ? 16 : 24,
      ),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF121212), Color(0xFF1A1A1A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF2D95).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFF2D95).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.person,
              color: const Color(0xFFFF2D95),
              size: isSmallScreen ? 28 : 36,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: isSmallScreen ? 12 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.username,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF2D95).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Class ${user.className}',
                    style: TextStyle(
                      color: const Color(0xFFFF2D95),
                      fontSize: isSmallScreen ? 10 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
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
        childAspectRatio: isSmallScreen ? 0.95 : 1.0,
        crossAxisSpacing: isSmallScreen ? 16 : 20,
        mainAxisSpacing: isSmallScreen ? 16 : 20,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final subject = _subjects[index];
        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            // Staggered animation effect
            final itemStartTime = index * 0.1;
            final animationValue = _animationController.value;
            final itemAnimationValue =
                animationValue > itemStartTime
                    ? (animationValue - itemStartTime) / (1 - itemStartTime)
                    : 0.0;

            return Transform.scale(
              scale: 0.8 + (0.2 * itemAnimationValue),
              child: Opacity(opacity: itemAnimationValue, child: child),
            );
          },
          child: _buildSubjectCard(
            subject['name'] as String,
            subject['icon'] as IconData,
            subject['color'] as Color,
            isSmallScreen,
          ),
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
            elevation: 8,
            color: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
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
              borderRadius: BorderRadius.circular(24),
              child: Container(
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
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -30,
                      bottom: -30,
                      child: Icon(
                        icon,
                        size: isSmallScreen ? 80 : 100,
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: isSmallScreen ? 20 : 24,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subjectName,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 14 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      'Start Learning',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 9 : 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
        'color': const Color(0xFFFF2D95),
        'items': List.generate(10, (index) => {'text': '${index + 1}'}),
      },
      {
        'title': 'Alphabets',
        'icon': Icons.abc,
        'color': const Color(0xFF00E5FF),
        'items': List.generate(
          26,
          (index) => {'text': String.fromCharCode(65 + index)},
        ),
      },
      {
        'title': 'Reading',
        'icon': Icons.auto_stories,
        'color': const Color(0xFF39FF14),
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
      {
        'title': 'Word Formation',
        'icon': Icons.text_fields,
        'color': const Color(0xFFAA00FF),
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
      {
        'title': 'Matching Games',
        'icon': Icons.connect_without_contact,
        'color': const Color(0xFF00FFCC),
        'items': [
          {'matching': true, 'title': 'Matching Games'},
        ],
      },
      {
        'title': 'Story Time',
        'icon': Icons.auto_stories,
        'color': const Color(0xFFFFD700),
        'items': [
          {'storyTime': true, 'title': 'Interactive Stories'},
        ],
      },
      {
        'title': 'Learn Urdu',
        'icon': Icons.language,
        'color': const Color(0xFF1E90FF),
        'items': [
          {'learnUrdu': true, 'title': 'Learn Urdu with Voice'},
        ],
      },
      {
        'title': 'Shapes',
        'icon': Icons.category,
        'color': const Color(0xFFFFA500),
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
        'color': const Color(0xFFFF2D95),
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
      {
        'title': 'Fruits',
        'icon': Icons.apple,
        'color': const Color(0xFF4CAF50),
        'items': [
          {'text': 'Apple', 'emoji': '🍎'},
          {'text': 'Banana', 'emoji': '🍌'},
          {'text': 'Orange', 'emoji': '🍊'},
          {'text': 'Grapes', 'emoji': '🍇'},
          {'text': 'Strawberry', 'emoji': '🍓'},
          {'text': 'Watermelon', 'emoji': '🍉'},
          {'text': 'Pineapple', 'emoji': '🍍'},
          {'text': 'Mango', 'emoji': '🥭'},
          {'text': 'Pear', 'emoji': '🍐'},
          {'text': 'Peach', 'emoji': '🍑'},
          {'text': 'Cherry', 'emoji': '🍒'},
          {'text': 'Lemon', 'emoji': '🍋'},
          {'text': 'Kiwi', 'emoji': '🥝'},
          {'text': 'Coconut', 'emoji': '🥥'},
          {'text': 'Avocado', 'emoji': '🥑'},
        ],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
          child: Row(
            children: [
              const Icon(Icons.explore, color: Color(0xFFFF2D95), size: 20),
              const SizedBox(width: 8),
              Text(
                'Learning Activities',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: isSmallScreen ? 16 : 20,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: isSmallScreen ? 160 : 200,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 16 : 24),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: activities.length,
            itemBuilder: (context, index) {
              final activity = activities[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: LearningActivityCard(
                  title: activity['title'] as String,
                  icon: activity['icon'] as IconData,
                  color: activity['color'] as Color,
                  items: List<Map<String, dynamic>>.from(
                    activity['items'] as List,
                  ),
                  isSmallScreen: isSmallScreen,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
