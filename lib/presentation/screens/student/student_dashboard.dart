import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../login_screen.dart';
import 'subject_selection_screen.dart';

/// Student dashboard screen
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return BlocListener<AuthBloc, AuthState>(
      listenWhen:
          (previous, current) =>
              current is Unauthenticated && previous is! AuthInitial,
      listener: (context, state) {
        if (state is Unauthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8EAC8),
        body: CustomScrollView(
          slivers: [
            _buildAppBar(isSmallScreen),
            SliverToBoxAdapter(child: _buildWelcomeSection(isSmallScreen)),
            SliverPadding(
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              sliver: _buildClassGrid(isSmallScreen),
            ),
          ],
        ),
      ),
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

  Widget _buildWelcomeSection(bool isSmallScreen) {
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
            'Welcome Student',
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 24 : 28,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'Access your learning materials',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.black54,
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassGrid(bool isSmallScreen) {
    final List<Map<String, dynamic>> classes = [
      {'name': 'Play Group', 'icon': Icons.child_care, 'color': Colors.black},
      {
        'name': 'Nursery',
        'icon': Icons.child_friendly,
        'color': Colors.black87,
      },
      {'name': 'KG', 'icon': Icons.auto_stories, 'color': Colors.black},
      {'name': 'Class 1', 'icon': Icons.looks_one, 'color': Colors.black87},
      {'name': 'Class 2', 'icon': Icons.looks_two, 'color': Colors.black},
      {'name': 'Class 3', 'icon': Icons.looks_3, 'color': Colors.black87},
      {'name': 'Class 4', 'icon': Icons.looks_4, 'color': Colors.black},
      {'name': 'Class 5', 'icon': Icons.looks_5, 'color': Colors.black87},
      {'name': 'Class 6', 'icon': Icons.looks_6, 'color': Colors.black},
      {'name': 'Class 7', 'icon': Icons.grade, 'color': Colors.black87},
      {'name': 'Class 8', 'icon': Icons.school, 'color': Colors.black},
      {'name': 'Class 9', 'icon': Icons.menu_book, 'color': Colors.black87},
      {'name': 'Class 10', 'icon': Icons.psychology, 'color': Colors.black},
    ];

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 3,
        childAspectRatio: isSmallScreen ? 1.1 : 1.3,
        crossAxisSpacing: isSmallScreen ? 12 : 16,
        mainAxisSpacing: isSmallScreen ? 12 : 16,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final className = classes[index]['name'] as String;
        final iconData = classes[index]['icon'] as IconData;
        final color = classes[index]['color'] as Color;
        return _buildClassCard(className, iconData, color, isSmallScreen);
      }, childCount: classes.length),
    );
  }

  Widget _buildClassCard(
    String className,
    IconData icon,
    Color color,
    bool isSmallScreen,
  ) {
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
                    (context) => SubjectSelectionScreen(className: className),
              ),
            ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
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
                  color: Colors.white.withOpacity(0.2),
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
                      className,
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
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Explore Subjects',
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
}
