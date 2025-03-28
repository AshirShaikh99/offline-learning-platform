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
        backgroundColor: const Color(
          0xFFF8EAC8,
        ), // Cream background color to match login screen
        body: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildWelcomeSection()),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: _buildClassGrid(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false, // This removes the back button
      backgroundColor: Colors.black, // Black to match login button
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
        title: Text(
          'Student Dashboard',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Student',
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Access your learning materials',
            style: AppTheme.bodyLarge.copyWith(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildClassGrid() {
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final className = classes[index]['name'] as String;
        final iconData = classes[index]['icon'] as IconData;
        final color = classes[index]['color'] as Color;
        return _buildClassCard(className, iconData, color);
      }, childCount: classes.length),
    );
  }

  Widget _buildClassCard(String className, IconData icon, Color color) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => SubjectSelectionScreen(className: className),
              ),
            ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 8,
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
                  size: 100,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icon, color: Colors.white, size: 32),
                    const Spacer(),
                    Text(
                      className,
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        'Explore Subjects',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontSize: 12,
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
