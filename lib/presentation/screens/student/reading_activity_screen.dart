import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// A screen that displays interactive reading activities
class ReadingActivityScreen extends StatefulWidget {
  final String? title;
  final Color? color;
  final Map<String, dynamic>? content;

  const ReadingActivityScreen({Key? key, this.title, this.color, this.content})
    : super(key: key);

  @override
  State<ReadingActivityScreen> createState() => _ReadingActivityScreenState();
}

class _ReadingActivityScreenState extends State<ReadingActivityScreen> {
  final FlutterTts flutterTts = FlutterTts();
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;
  bool _showQuestion = false;
  int? _selectedAnswerIndex;
  bool _showExplanation = false;

  // Default story pages if none provided through content
  final List<Map<String, dynamic>> _defaultStoryPages = [
    {
      'title': 'The Friendly Robot',
      'content':
          'Once upon a time, there was a small robot named Beep. Beep was created to help children learn new things. Beep could talk, sing, and tell amazing stories!',
      'image': 'robot',
    },
    {
      'title': 'Making Friends',
      'content':
          'One day, Beep met a little girl named Lily. Lily was shy at first, but soon she and Beep became best friends. They spent their days exploring and learning together.',
      'image': 'friends',
    },
    {
      'title': 'The Adventure Begins',
      'content':
          'Beep and Lily decided to go on an adventure to the magical forest. In the forest, they discovered talking trees, friendly animals, and a sparkling blue lake.',
      'image': 'forest',
    },
    {
      'title': 'The Challenge',
      'content':
          'At the lake, they met a wise old turtle who gave them a challenge. To cross the lake, they needed to answer three questions about friendship.',
      'image': 'turtle',
      'question': {
        'text': 'What makes someone a good friend?',
        'options': [
          'They give you lots of toys',
          'They listen to you and help you when you need it',
          'They are always better than you at games',
          'They never disagree with you',
        ],
        'correctAnswer': 1,
        'explanation':
            'Good friends listen to each other and help each other when needed. They care about your feelings and support you.',
      },
    },
  ];

  List<Map<String, dynamic>> get _storyPages {
    // Use content from widget if provided, otherwise use default
    if (widget.content != null && widget.content!.containsKey('pages')) {
      return List<Map<String, dynamic>>.from(widget.content!['pages']);
    }
    return _defaultStoryPages;
  }

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    flutterTts.stop();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  void _nextPage() {
    if (_currentPageIndex < _storyPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPageIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _selectAnswer(int index) {
    setState(() {
      _selectedAnswerIndex = index;
      _showExplanation = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.title ?? 'Interactive Reading',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: (widget.color ?? const Color(0xFFFF2D95)).withOpacity(
                0.15,
              ),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back,
              color: widget.color ?? const Color(0xFFFF2D95),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _storyPages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPageIndex = index;
                    _showQuestion = false;
                    _selectedAnswerIndex = null;
                    _showExplanation = false;
                  });
                },
                itemBuilder: (context, index) {
                  final page = _storyPages[index];
                  return _buildStoryPage(page);
                },
              ),
            ),
            _buildPageControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryPage(Map<String, dynamic> page) {
    final hasQuestion = page.containsKey('question');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF121212), Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (widget.color ?? const Color(0xFFFF2D95)).withOpacity(
                    0.1,
                  ),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF2D95).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.auto_stories,
                          color: Color(0xFFFF2D95),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          page['title'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up,
                          color: Color(0xFFFF2D95),
                        ),
                        onPressed: () => _speak(page['content']),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF252550),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Icon(
                        _getImageIcon(page['image']),
                        size: 100,
                        color: const Color(0xFFFF2D95).withOpacity(0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    page['content'],
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasQuestion) ...[
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _showQuestion = true;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color ?? const Color(0xFFFF2D95),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Answer Question',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (_showQuestion) _buildQuestionSection(page['question']),
          ],
        ],
      ),
    );
  }

  Widget _buildQuestionSection(Map<String, dynamic> question) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF252550),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00E5FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E5FF).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.quiz,
                  color: Color(0xFF00E5FF),
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Question',
                  style: TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            question['text'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            question['options'].length,
            (index) => _buildAnswerOption(
              index,
              question['options'][index],
              question['correctAnswer'],
            ),
          ),
          if (_showExplanation) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF39FF14).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF39FF14).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.lightbulb, color: Color(0xFF39FF14), size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Explanation:',
                        style: TextStyle(
                          color: Color(0xFF39FF14),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    question['explanation'],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerOption(int index, String text, int correctAnswer) {
    final isSelected = _selectedAnswerIndex == index;
    final isCorrect = index == correctAnswer;

    Color borderColor = Colors.grey.withOpacity(0.3);
    Color fillColor = Colors.transparent;

    if (isSelected) {
      borderColor =
          isCorrect ? const Color(0xFF39FF14) : const Color(0xFFFF3131);
      fillColor =
          isCorrect
              ? const Color(0xFF39FF14).withOpacity(0.1)
              : const Color(0xFFFF3131).withOpacity(0.1);
    }

    return GestureDetector(
      onTap: _selectedAnswerIndex == null ? () => _selectAnswer(index) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSelected
                        ? (isCorrect
                            ? const Color(0xFF39FF14)
                            : const Color(0xFFFF3131))
                        : Colors.transparent,
                border: Border.all(
                  color:
                      isSelected
                          ? (isCorrect
                              ? const Color(0xFF39FF14)
                              : const Color(0xFFFF3131))
                          : Colors.grey,
                  width: 1.5,
                ),
              ),
              child:
                  isSelected
                      ? Icon(
                        isCorrect ? Icons.check : Icons.close,
                        color: Colors.black,
                        size: 16,
                      )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color:
                      isSelected
                          ? (isCorrect
                              ? const Color(0xFF39FF14)
                              : const Color(0xFFFF3131))
                          : Colors.white,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        border: Border(top: BorderSide(color: Color(0xFF252550), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            onPressed: _currentPageIndex > 0 ? _previousPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF252550),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFF252550).withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Previous (${_currentPageIndex}/${_storyPages.length - 1})',
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed:
                _currentPageIndex < _storyPages.length - 1 ? _nextPage : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.color ?? const Color(0xFFFF2D95),
              foregroundColor: Colors.white,
              disabledBackgroundColor: (widget.color ?? const Color(0xFFFF2D95))
                  .withOpacity(0.3),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Next (${_currentPageIndex + 1}/${_storyPages.length - 1})',
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward_ios, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getImageIcon(String image) {
    switch (image) {
      case 'robot':
        return Icons.smart_toy;
      case 'friends':
        return Icons.people;
      case 'forest':
        return Icons.forest;
      case 'turtle':
        return Icons.pets;
      default:
        return Icons.image;
    }
  }
}
