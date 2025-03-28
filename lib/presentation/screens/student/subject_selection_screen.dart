import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'content_viewer_screen.dart';

class SubjectSelectionScreen extends StatefulWidget {
  final String className;

  const SubjectSelectionScreen({super.key, required this.className});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  final List<Map<String, dynamic>> _subjects = [
    {'name': 'English', 'icon': Icons.language, 'color': Colors.black},
    {'name': 'Mathematics', 'icon': Icons.calculate, 'color': Colors.black87},
    {'name': 'Science', 'icon': Icons.science, 'color': Colors.black},
    {
      'name': 'Social Studies',
      'icon': Icons.history_edu,
      'color': Colors.black87,
    },
    {'name': 'Computer', 'icon': Icons.computer, 'color': Colors.black},
    {'name': 'Islamiat', 'icon': Icons.menu_book, 'color': Colors.black87},
    {'name': 'GK', 'icon': Icons.psychology, 'color': Colors.black},
    {'name': 'Urdu', 'icon': Icons.translate, 'color': Colors.black87},
    {'name': 'Sindhi', 'icon': Icons.text_fields, 'color': Colors.black},
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
    final isLargeScreen = screenSize.width >= 1200;

    return Scaffold(
      backgroundColor: const Color(0xFFF8EAC8),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, screenSize),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: _getHorizontalPadding(screenSize),
              vertical: 16,
            ),
            sliver: _buildSubjectGrid(context, screenSize),
          ),
        ],
      ),
    );
  }

  double _getHorizontalPadding(Size screenSize) {
    if (screenSize.width >= 1200) return screenSize.width * 0.15;
    if (screenSize.width >= 600) return screenSize.width * 0.1;
    return 16.0;
  }

  Widget _buildAppBar(BuildContext context, Size screenSize) {
    final isSmallScreen = screenSize.width < 600;
    final expandedHeight = _getExpandedHeight(screenSize);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      floating: false,
      pinned: true,
      backgroundColor: Colors.black,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.className,
          style: TextStyle(
            color: Colors.white,
            fontSize: _getTitleFontSize(screenSize),
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          color: Colors.black,
          child: Stack(
            children: [
              Positioned(
                right: -50,
                top: -50,
                child: CircleAvatar(
                  radius: isSmallScreen ? 100 : 150,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
              Positioned(
                left: -30,
                bottom: -30,
                child: CircleAvatar(
                  radius: isSmallScreen ? 80 : 120,
                  backgroundColor: Colors.white.withOpacity(0.1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double _getExpandedHeight(Size screenSize) {
    if (screenSize.width >= 1200) return 200;
    if (screenSize.width >= 600) return 180;
    return 150;
  }

  double _getTitleFontSize(Size screenSize) {
    if (screenSize.width >= 1200) return 32;
    if (screenSize.width >= 600) return 28;
    return 24;
  }

  Widget _buildSubjectGrid(BuildContext context, Size screenSize) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(screenSize),
        childAspectRatio: _getChildAspectRatio(screenSize),
        crossAxisSpacing: _getSpacing(screenSize),
        mainAxisSpacing: _getSpacing(screenSize),
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final subject = _subjects[index];
        return _buildSubjectCard(context, subject, screenSize);
      }, childCount: _subjects.length),
    );
  }

  int _getCrossAxisCount(Size screenSize) {
    if (screenSize.width >= 1200) return 4;
    if (screenSize.width >= 800) return 3;
    if (screenSize.width >= 600) return 2;
    return 2;
  }

  double _getChildAspectRatio(Size screenSize) {
    if (screenSize.width >= 1200) return 1.2;
    if (screenSize.width >= 800) return 1.1;
    if (screenSize.width >= 600) return 1.0;
    return 0.95;
  }

  double _getSpacing(Size screenSize) {
    if (screenSize.width >= 1200) return 24.0;
    if (screenSize.width >= 800) return 20.0;
    if (screenSize.width >= 600) return 16.0;
    return 12.0;
  }

  Widget _buildSubjectCard(
    BuildContext context,
    Map<String, dynamic> subject,
    Size screenSize,
  ) {
    final isSmallScreen = screenSize.width < 600;
    final cardPadding = isSmallScreen ? 16.0 : 24.0;
    final iconSize = isSmallScreen ? 32.0 : 40.0;
    final titleSize = isSmallScreen ? 16.0 : 20.0;
    final buttonTextSize = isSmallScreen ? 12.0 : 14.0;

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
                      className: widget.className,
                      subject: subject['name'],
                    ),
              ),
            ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [subject['color'], subject['color'].withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: isSmallScreen ? 6 : 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Icon
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  subject['icon'],
                  size: iconSize * 2.5,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              // Content
              Padding(
                padding: EdgeInsets.all(cardPadding),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Icon
                    Icon(subject['icon'], color: Colors.white, size: iconSize),
                    // Spacer
                    const Spacer(),
                    // Subject Name and Button
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Subject Name
                        Text(
                          subject['name'],
                          style: AppTheme.titleLarge.copyWith(
                            color: Colors.white,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isSmallScreen ? 8 : 12),
                        // View Content Button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                            vertical: isSmallScreen ? 6 : 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'View Content',
                            style: AppTheme.bodyMedium.copyWith(
                              color: Colors.white,
                              fontSize: buttonTextSize,
                              fontWeight: FontWeight.w500,
                            ),
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
}
