import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/file/file_bloc.dart';
import '../../blocs/file/file_event.dart';
import '../../blocs/file/file_state.dart';
import '../login_screen.dart';
import 'manage_courses_screen.dart';

/// Admin dashboard screen
class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  void _loadFiles() {
    context.read<FileBloc>().add(
      const LoadFilesEvent(className: '', subject: ''),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final padding = _getPadding(screenSize);

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
            _buildAppBar(screenSize),
            SliverToBoxAdapter(child: _buildWelcomeSection(screenSize)),
            SliverPadding(
              padding: EdgeInsets.all(padding),
              sliver: _buildActionGrid(screenSize),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(Size screenSize) {
    final isSmallScreen = screenSize.width < 600;
    final expandedHeight = isSmallScreen ? 100.0 : 120.0;
    final titleFontSize = isSmallScreen ? 20.0 : 24.0;
    final iconSize = isSmallScreen ? 22.0 : 24.0;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(
          left: isSmallScreen ? 16 : 24,
          bottom: isSmallScreen ? 12 : 16,
        ),
        title: Text(
          'Admin Dashboard',
          style: AppTheme.titleLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: titleFontSize,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(color: Colors.black),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.logout, color: Colors.white, size: iconSize),
          onPressed: () => context.read<AuthBloc>().add(LogoutEvent()),
        ),
        SizedBox(width: isSmallScreen ? 8 : 16),
      ],
    );
  }

  Widget _buildWelcomeSection(Size screenSize) {
    final isSmallScreen = screenSize.width < 600;
    final padding = _getPadding(screenSize);
    final titleSize = isSmallScreen ? 24.0 : 28.0;
    final subtitleSize = isSmallScreen ? 14.0 : 16.0;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding,
        isSmallScreen ? 16 : 24,
        padding,
        padding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome Admin',
            style: AppTheme.headlineMedium.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: titleSize,
            ),
          ),
          SizedBox(height: isSmallScreen ? 6 : 8),
          Text(
            'Manage your school content',
            style: AppTheme.bodyLarge.copyWith(
              color: Colors.black54,
              fontSize: subtitleSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionGrid(Size screenSize) {
    final isSmallScreen = screenSize.width < 600;
    final crossAxisCount = _getCrossAxisCount(screenSize);
    final childAspectRatio = _getChildAspectRatio(screenSize);
    final spacing = isSmallScreen ? 12.0 : 16.0;

    final actions = [
      {
        'title': 'Manage Courses',
        'icon': Icons.book,
        'color': Colors.black,
        'onTap':
            () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const ManageCoursesScreen(),
              ),
            ),
      },
      {
        'title': 'Upload Statistics',
        'icon': Icons.analytics,
        'color': Colors.black87,
        'isStats': true,
      },
    ];

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final action = actions[index];
        return action['isStats'] == true
            ? _buildStatsCard(
              title: action['title'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              screenSize: screenSize,
            )
            : _buildActionCard(
              title: action['title'] as String,
              icon: action['icon'] as IconData,
              color: action['color'] as Color,
              onTap: action['onTap'] as VoidCallback,
              screenSize: screenSize,
            );
      }, childCount: actions.length),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required Size screenSize,
  }) {
    final isSmallScreen = screenSize.width < 600;
    final padding = isSmallScreen ? 16.0 : 20.0;
    final iconSize = isSmallScreen ? 28.0 : 32.0;
    final titleSize = isSmallScreen ? 16.0 : 18.0;
    final buttonTextSize = isSmallScreen ? 12.0 : 14.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color, color.withOpacity(0.8)],
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
                child: SizedBox(
                  width: isSmallScreen ? 80 : 100,
                  height: isSmallScreen ? 80 : 100,
                  child: Icon(
                    icon,
                    size: isSmallScreen ? 80 : 100,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: iconSize,
                      height: iconSize,
                      child: Icon(icon, color: Colors.white, size: iconSize),
                    ),
                    const Spacer(),
                    Text(
                      title,
                      style: AppTheme.titleLarge.copyWith(
                        color: Colors.white,
                        fontSize: titleSize,
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
                        'Manage',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                          fontSize: buttonTextSize,
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

  Widget _buildStatsCard({
    required String title,
    required IconData icon,
    required Color color,
    required Size screenSize,
  }) {
    final isSmallScreen = screenSize.width < 600;
    final padding =
        screenSize.width >= 1200 ? 32.0 : (isSmallScreen ? 20.0 : 24.0);
    final iconSize =
        screenSize.width >= 1200 ? 40.0 : (isSmallScreen ? 32.0 : 36.0);
    final titleSize =
        screenSize.width >= 1200 ? 24.0 : (isSmallScreen ? 20.0 : 22.0);
    final statsTextSize =
        screenSize.width >= 1200 ? 18.0 : (isSmallScreen ? 16.0 : 17.0);

    return BlocBuilder<FileBloc, FileState>(
      builder: (context, state) {
        int uploadCount = 0;
        if (state is FilesLoaded) {
          uploadCount = state.files.length;
        }

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              screenSize.width >= 1200 ? 24 : (isSmallScreen ? 16 : 20),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withOpacity(0.8)],
              ),
              borderRadius: BorderRadius.circular(
                screenSize.width >= 1200 ? 24 : (isSmallScreen ? 16 : 20),
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius:
                      screenSize.width >= 1200 ? 12 : (isSmallScreen ? 6 : 8),
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Icon(
                    icon,
                    size:
                        screenSize.width >= 1200
                            ? 140
                            : (isSmallScreen ? 100 : 120),
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, color: Colors.white, size: iconSize),
                      const Spacer(),
                      Text(
                        title,
                        style: AppTheme.titleLarge.copyWith(
                          color: Colors.white,
                          fontSize: titleSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height:
                            screenSize.width >= 1200
                                ? 12
                                : (isSmallScreen ? 6 : 8),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal:
                              screenSize.width >= 1200
                                  ? 16
                                  : (isSmallScreen ? 10 : 12),
                          vertical:
                              screenSize.width >= 1200
                                  ? 8
                                  : (isSmallScreen ? 4 : 6),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          '$uploadCount Files Uploaded',
                          style: AppTheme.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: statsTextSize,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  int _getCrossAxisCount(Size screenSize) {
    if (screenSize.width >= 1200) return 3;
    if (screenSize.width >= 800) return 2;
    return 1; // Single column for smaller screens
  }

  double _getChildAspectRatio(Size screenSize) {
    if (screenSize.width >= 1200) return 2.0;
    if (screenSize.width >= 800) return 1.8;
    if (screenSize.width >= 600) return 1.6;
    return 1.4; // More height for smaller screens
  }

  double _getSpacing(Size screenSize) {
    if (screenSize.width >= 1200) return 24.0;
    if (screenSize.width >= 800) return 20.0;
    if (screenSize.width >= 600) return 16.0;
    return 12.0;
  }

  double _getPadding(Size screenSize) {
    if (screenSize.width >= 1200) return 32.0;
    if (screenSize.width >= 800) return 24.0;
    if (screenSize.width >= 600) return 20.0;
    return 16.0;
  }
}
