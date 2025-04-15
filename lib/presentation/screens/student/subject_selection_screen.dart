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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Select Subject',
          style: TextStyle(
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF121212), Color(0xFF1A1A1A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2D95).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF2D95).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.school,
                        color: Color(0xFFFF2D95),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select a Subject',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap a subject to view available content',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GridView.count(
                  crossAxisCount: _getColumnCount(context),
                  childAspectRatio: 1.0,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children:
                      _subjects.map((subject) {
                        return _buildSubjectCard(subject);
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    return Card(
      elevation: 8,
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: () => _navigateToContentViewer(subject['name']),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (subject['color'] as Color).withOpacity(0.8),
                (subject['color'] as Color).withOpacity(0.5),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: (subject['color'] as Color).withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 0,
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
                  subject['icon'] as IconData,
                  size: 100,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
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
                        subject['icon'] as IconData,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subject['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
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
                              const Text(
                                'View Content',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
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

  void _navigateToContentViewer(String subjectName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ContentViewerScreen(
              className: widget.className,
              subject: subjectName,
            ),
      ),
    );
  }

  int _getColumnCount(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final isMediumScreen = screenSize.width >= 600 && screenSize.width < 1200;
    final isLargeScreen = screenSize.width >= 1200;

    if (isLargeScreen) return 4;
    if (isMediumScreen) return 3;
    if (isSmallScreen) return 2;
    return 2;
  }
}
