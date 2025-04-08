import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../core/theme/app_theme.dart';

/// A screen that displays interactive reading activities
class ReadingActivityScreen extends StatefulWidget {
  /// The title of the screen
  final String title;

  /// The theme color
  final Color color;

  /// The reading content
  final Map<String, dynamic> content;

  const ReadingActivityScreen({
    super.key,
    required this.title,
    required this.color,
    required this.content,
  });

  @override
  State<ReadingActivityScreen> createState() => _ReadingActivityScreenState();
}

class _ReadingActivityScreenState extends State<ReadingActivityScreen> {
  late final FlutterTts flutterTts;
  bool _isReading = false;
  int _currentPage = 0;
  List<String> _highlightedWords = [];

  @override
  void initState() {
    super.initState();
    flutterTts = FlutterTts();
    _setupTts();
  }

  Future<void> _setupTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts.setSpeechRate(0.5);

    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() {
          _isReading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (_isReading) {
      await flutterTts.stop();
      setState(() {
        _isReading = false;
      });
      return;
    }

    setState(() {
      _isReading = true;
    });

    await flutterTts.speak(text);
  }

  void _nextPage() {
    if (_currentPage < widget.content['pages'].length - 1) {
      setState(() {
        _currentPage++;
        _highlightedWords = [];
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
        _highlightedWords = [];
      });
    }
  }

  void _toggleWordHighlight(String word) {
    setState(() {
      if (_highlightedWords.contains(word)) {
        _highlightedWords.remove(word);
      } else {
        _highlightedWords.add(word);
        _speak(word);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    final currentPageData = widget.content['pages'][_currentPage];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.color,
        foregroundColor: AppTheme.textOnDarkColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (_currentPage + 1) / widget.content['pages'].length,
            backgroundColor: Theme.of(context).colorScheme.surface,
            color: widget.color,
          ),

          // Main content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(200),
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
              padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    currentPageData['title'],
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: isSmallScreen ? 24 : 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Image if available
                  if (currentPageData.containsKey('image'))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Center(
                        child: Image.asset(
                          currentPageData['image'],
                          height: isSmallScreen ? 150 : 200,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildInteractiveText(
                        currentPageData['content'],
                        isSmallScreen,
                      ),
                    ),
                  ),

                  // Question if available
                  if (currentPageData.containsKey('question'))
                    _buildQuestion(currentPageData['question'], isSmallScreen),
                ],
              ),
            ),
          ),

          // Controls
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous button
                IconButton(
                  onPressed: _currentPage > 0 ? _previousPage : null,
                  icon: const Icon(Icons.arrow_back),
                  color: _currentPage > 0 ? Colors.white : Colors.grey,
                ),

                // Read aloud button
                ElevatedButton.icon(
                  onPressed: () => _speak(currentPageData['content']),
                  icon: Icon(_isReading ? Icons.stop : Icons.volume_up),
                  label: Text(_isReading ? 'Stop' : 'Read Aloud'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.color,
                    foregroundColor: AppTheme.textOnDarkColor,
                  ),
                ),

                // Next button
                IconButton(
                  onPressed:
                      _currentPage < widget.content['pages'].length - 1
                          ? _nextPage
                          : null,
                  icon: const Icon(Icons.arrow_forward),
                  color:
                      _currentPage < widget.content['pages'].length - 1
                          ? Colors.white
                          : Colors.grey,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveText(String text, bool isSmallScreen) {
    final words = text.split(' ');

    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children:
          words.map((word) {
            final cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '');
            final isPunctuation = cleanWord.isEmpty;
            final isHighlighted = _highlightedWords.contains(cleanWord);

            return GestureDetector(
              onTap:
                  isPunctuation ? null : () => _toggleWordHighlight(cleanWord),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      isHighlighted
                          ? widget.color.withAlpha(51)
                          : null, // 0.2 * 255 = 51
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 18 : 22,
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.normal,
                    color: isHighlighted ? widget.color : Colors.white,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildQuestion(Map<String, dynamic> question, bool isSmallScreen) {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question:',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontSize: isSmallScreen ? 18 : 20,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question['text'],
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            question['options'].length,
            (index) => RadioListTile<int>(
              title: Text(
                question['options'][index],
                style: TextStyle(color: Colors.white),
              ),
              value: index,
              groupValue: question['selectedAnswer'],
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  question['selectedAnswer'] = value;
                });
              },
            ),
          ),
          const SizedBox(height: 8),
          if (question['selectedAnswer'] != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color:
                    question['selectedAnswer'] == question['correctAnswer']
                        ? AppTheme.secondaryColor.withAlpha(
                          100,
                        ) // 0.4 * 255 = 102
                        : AppTheme.errorColor.withAlpha(100), // 0.4 * 255 = 102
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    question['selectedAnswer'] == question['correctAnswer']
                        ? Icons.check_circle
                        : Icons.cancel,
                    color:
                        question['selectedAnswer'] == question['correctAnswer']
                            ? AppTheme.secondaryColor
                            : AppTheme.errorColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      question['selectedAnswer'] == question['correctAnswer']
                          ? 'Correct! ${question['explanation']}'
                          : 'Try again. Hint: ${question['hint']}',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white,
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
}
