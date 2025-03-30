import 'package:flutter/material.dart';
import 'dart:math';

class SpellingGameScreen extends StatefulWidget {
  final List<Map<String, String>> words;
  final Color color;

  const SpellingGameScreen({
    super.key,
    required this.words,
    required this.color,
  });

  @override
  State<SpellingGameScreen> createState() => _SpellingGameScreenState();
}

class _SpellingGameScreenState extends State<SpellingGameScreen> {
  late Map<String, String> currentWord;
  late List<String> shuffledLetters;
  List<String?> userAnswer = [];
  bool isCorrect = false;
  int currentWordIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeWord();
  }

  void _initializeWord() {
    currentWord = widget.words[currentWordIndex];
    shuffledLetters = currentWord['word']!.split('')..shuffle();
    userAnswer = List.filled(currentWord['word']!.length, null);
    isCorrect = false;
  }

  void _checkAnswer() {
    final String userWord = userAnswer.join();
    isCorrect = userWord == currentWord['word'];

    if (isCorrect) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => AlertDialog(
              title: const Text('Excellent! 🎉'),
              content: Text('You spelled "${currentWord['word']}" correctly!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (currentWordIndex < widget.words.length - 1) {
                      setState(() {
                        currentWordIndex++;
                        _initializeWord();
                      });
                    } else {
                      Navigator.pop(context); // Return to dashboard
                    }
                  },
                  child: Text(
                    currentWordIndex < widget.words.length - 1
                        ? 'Next Word'
                        : 'Finish',
                  ),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spelling Game'),
        backgroundColor: widget.color,
      ),
      body: Column(
        children: [
          // Hint Section
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            margin: EdgeInsets.all(isSmallScreen ? 16 : 24),
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.color.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                const Icon(Icons.lightbulb_outline, size: 32),
                const SizedBox(height: 8),
                Text(
                  'Hint: ${currentWord['hint']}',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Answer Section
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                currentWord['word']!.length,
                (index) => _buildAnswerSlot(index, isSmallScreen),
              ),
            ),
          ),

          const Spacer(),

          // Letters Section
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: Wrap(
              spacing: isSmallScreen ? 8 : 12,
              runSpacing: isSmallScreen ? 8 : 12,
              alignment: WrapAlignment.center,
              children:
                  shuffledLetters
                      .asMap()
                      .entries
                      .map(
                        (entry) =>
                            _buildDraggableLetter(entry.value, isSmallScreen),
                      )
                      .toList(),
            ),
          ),

          // Reset Button
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: ElevatedButton.icon(
              onPressed: () => setState(() => _initializeWord()),
              icon: const Icon(Icons.refresh),
              label: const Text('Reset Word'),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 24,
                  vertical: isSmallScreen ? 12 : 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSlot(int index, bool isSmallScreen) {
    return DragTarget<String>(
      onWillAccept: (data) => userAnswer[index] == null,
      onAccept: (data) {
        setState(() {
          userAnswer[index] = data;
          _checkAnswer();
        });
      },
      builder:
          (context, candidateData, rejectedData) => Container(
            width: isSmallScreen ? 40 : 50,
            height: isSmallScreen ? 40 : 50,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color:
                  userAnswer[index] != null
                      ? widget.color.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: userAnswer[index] != null ? widget.color : Colors.grey,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                userAnswer[index] ?? '',
                style: TextStyle(
                  fontSize: isSmallScreen ? 20 : 24,
                  fontWeight: FontWeight.bold,
                  color: widget.color,
                ),
              ),
            ),
          ),
    );
  }

  Widget _buildDraggableLetter(String letter, bool isSmallScreen) {
    final bool isUsed = userAnswer.contains(letter);

    return Draggable<String>(
      data: letter,
      dragAnchorStrategy: (draggable, context, position) {
        return Offset(
          draggable.feedbackOffset.dx + (isSmallScreen ? 20 : 25),
          draggable.feedbackOffset.dy + (isSmallScreen ? 20 : 25),
        );
      },
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          width: isSmallScreen ? 40 : 50,
          height: isSmallScreen ? 40 : 50,
          decoration: BoxDecoration(
            color: widget.color.withOpacity(0.9),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: isSmallScreen ? 40 : 50,
        height: isSmallScreen ? 40 : 50,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Container(
        width: isSmallScreen ? 40 : 50,
        height: isSmallScreen ? 40 : 50,
        decoration: BoxDecoration(
          color:
              isUsed
                  ? Colors.grey.withOpacity(0.2)
                  : widget.color.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              fontSize: isSmallScreen ? 20 : 24,
              fontWeight: FontWeight.bold,
              color: isUsed ? Colors.grey : Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
