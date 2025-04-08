import 'package:flutter/material.dart';
import 'dart:math';
import '../../../core/theme/app_theme.dart';

/// A screen that allows students to form words by dragging letters
class WordFormationScreen extends StatefulWidget {
  /// The title of the screen
  final String title;

  /// The theme color
  final Color color;

  /// The list of word challenges
  final List<Map<String, dynamic>> challenges;

  const WordFormationScreen({
    super.key,
    required this.title,
    required this.color,
    required this.challenges,
  });

  @override
  State<WordFormationScreen> createState() => _WordFormationScreenState();
}

class _WordFormationScreenState extends State<WordFormationScreen> {
  int _currentChallengeIndex = 0;
  List<String> _shuffledLetters = [];
  List<String?> _placedLetters = [];
  bool _isCorrect = false;
  bool _showHint = false;

  @override
  void initState() {
    super.initState();
    _initializeChallenge();
  }

  void _initializeChallenge() {
    final currentChallenge = widget.challenges[_currentChallengeIndex];
    final word = currentChallenge['word'] as String;

    // Create shuffled letters
    _shuffledLetters = word.split('')..shuffle(Random());

    // Initialize placed letters with nulls (empty slots)
    _placedLetters = List.filled(word.length, null);

    _isCorrect = false;
    _showHint = false;
  }

  void _checkAnswer() {
    // Check if all slots are filled
    if (_placedLetters.contains(null)) {
      return;
    }

    final currentWord =
        widget.challenges[_currentChallengeIndex]['word'] as String;
    final userWord = _placedLetters.join();

    setState(() {
      _isCorrect = userWord == currentWord;

      if (_isCorrect) {
        // Show success dialog after a short delay
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _showSuccessDialog();
        });
      } else {
        // Shake animation or feedback for incorrect answer
        _showHint = true;
      }
    });
  }

  void _showSuccessDialog() {
    final isSmallScreen = MediaQuery.of(context).size.width < 600;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.black.withAlpha(230),
            title: Text(
              'Great Job!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle,
                  color: AppTheme.secondaryColor,
                  size: isSmallScreen ? 40 : 60,
                ),
                SizedBox(height: isSmallScreen ? 8 : 16),
                Text(
                  'You formed the word correctly!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _goToNextChallenge();
                },
                child: Text(
                  _currentChallengeIndex < widget.challenges.length - 1
                      ? 'Next Word'
                      : 'Finish',
                  style: TextStyle(color: widget.color),
                ),
              ),
            ],
          ),
    );
  }

  void _goToNextChallenge() {
    if (_currentChallengeIndex < widget.challenges.length - 1) {
      setState(() {
        _currentChallengeIndex++;
        _initializeChallenge();
      });
    } else {
      // All challenges completed
      Navigator.pop(context);
    }
  }

  void _resetChallenge() {
    setState(() {
      _initializeChallenge();
    });
  }

  void _onDragLetterAccepted(int targetIndex, String letter, int sourceIndex) {
    setState(() {
      // If the target already has a letter, swap with the source
      if (_placedLetters[targetIndex] != null) {
        // Find the original position of the letter in shuffled letters
        final originalLetter = _placedLetters[targetIndex]!;
        _shuffledLetters[sourceIndex] = originalLetter;
      } else {
        // Remove the letter from shuffled letters
        _shuffledLetters[sourceIndex] = '';
      }

      // Place the letter in the target
      _placedLetters[targetIndex] = letter;

      // Check if the word is complete
      if (!_placedLetters.contains(null)) {
        _checkAnswer();
      }
    });
  }

  void _onDragLetterFromTargetAccepted(int sourceIndex) {
    setState(() {
      // Find an empty slot in shuffled letters
      final emptyIndex = _shuffledLetters.indexOf('');
      if (emptyIndex != -1) {
        _shuffledLetters[emptyIndex] = _placedLetters[sourceIndex]!;
        _placedLetters[sourceIndex] = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentChallenge = widget.challenges[_currentChallengeIndex];
    final word = currentChallenge['word'] as String;
    final hint = currentChallenge['hint'] as String;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    // Use RepaintBoundary to optimize rendering performance

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: widget.color,
        foregroundColor: AppTheme.textOnDarkColor,
        elevation: 0,
      ),
      body: RepaintBoundary(
        child: Container(
          decoration: BoxDecoration(color: Colors.black.withAlpha(200)),
          child: Column(
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: (_currentChallengeIndex + 1) / widget.challenges.length,
                backgroundColor: Theme.of(context).colorScheme.surface,
                color: widget.color,
              ),

              // Hint section
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                width: double.infinity,
                color: Colors.black.withAlpha(100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hint:',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 16 : 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hint,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                    if (_showHint) ...[
                      const SizedBox(height: 8),
                      Text(
                        'First letter: ${word[0]}',
                        style: TextStyle(
                          color: widget.color,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmallScreen ? 14 : 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Main content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Target area for placing letters
                      Container(
                        margin: EdgeInsets.symmetric(vertical: 12),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(150),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color:
                                _isCorrect
                                    ? AppTheme.secondaryColor
                                    : widget.color,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(60),
                              blurRadius: 5,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child:
                            word.length <= 5
                                ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    word.length,
                                    (index) =>
                                        _buildTargetSlot(index, isSmallScreen),
                                  ),
                                )
                                : Wrap(
                                  alignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 12,
                                  children: List.generate(
                                    word.length,
                                    (index) =>
                                        _buildTargetSlot(index, isSmallScreen),
                                  ),
                                ),
                      ),

                      const SizedBox(height: 20),

                      // Source area with letters to drag
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(100),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: List.generate(
                            _shuffledLetters.length,
                            (index) =>
                                _buildDraggableLetter(index, isSmallScreen),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Controls
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withAlpha(180),
                      Colors.black.withAlpha(220),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(70),
                      blurRadius: 6,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _resetChallenge,
                        icon: Icon(
                          Icons.refresh,
                          size: isSmallScreen ? 16 : 20,
                        ),
                        label: Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showHint = true;
                          });
                        },
                        icon: Icon(
                          Icons.lightbulb_outline,
                          size: isSmallScreen ? 16 : 20,
                        ),
                        label: Text(
                          'Hint',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[800],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _checkAnswer,
                        icon: Icon(Icons.check, size: isSmallScreen ? 16 : 20),
                        label: Text(
                          'Check',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.color,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 12 : 16,
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
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

  Widget _buildTargetSlot(int index, bool isSmallScreen) {
    final letter = _placedLetters[index];
    final size = isSmallScreen ? 35.0 : 45.0;

    return DragTarget<Map<String, dynamic>>(
      builder: (context, candidateData, rejectedData) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: isSmallScreen ? 1 : 2),
          width: size,
          height: size,
          decoration: BoxDecoration(
            color:
                letter != null
                    ? widget.color.withAlpha(100)
                    : Colors.white.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  letter != null ? widget.color : Colors.white.withAlpha(100),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 3,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child:
              letter != null
                  ? _buildDraggableTargetLetter(index, letter, isSmallScreen)
                  : Center(
                    child: Text(
                      '_',
                      style: TextStyle(
                        color: Colors.white.withAlpha(100),
                        fontSize: isSmallScreen ? 20 : 24,
                      ),
                    ),
                  ),
        );
      },
      onWillAcceptWithDetails: (details) {
        // Accept only if the data contains a letter
        final data = details.data;
        return data.containsKey('letter');
      },
      onAcceptWithDetails: (details) {
        final data = details.data;
        final letter = data['letter'] as String;
        final sourceIndex = data['index'] as int;
        _onDragLetterAccepted(index, letter, sourceIndex);
      },
    );
  }

  Widget _buildDraggableTargetLetter(
    int index,
    String letter,
    bool isSmallScreen,
  ) {
    final size = isSmallScreen ? 35.0 : 45.0;
    return Draggable<Map<String, dynamic>>(
      data: {'letter': letter, 'index': index, 'isFromTarget': true},
      feedback: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withAlpha(100), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            '_',
            style: TextStyle(color: Colors.white.withAlpha(100), fontSize: 24),
          ),
        ),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSmallScreen ? 20 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onDragCompleted: () {
        // This will be called when the drag is completed and accepted by a target
      },
      onDraggableCanceled: (velocity, offset) {
        // Return the letter to the source area
        _onDragLetterFromTargetAccepted(index);
      },
    );
  }

  Widget _buildDraggableLetter(int index, bool isSmallScreen) {
    final letter = _shuffledLetters[index];
    final size = isSmallScreen ? 35.0 : 45.0;

    // If the letter is empty (already placed), show an empty container
    if (letter.isEmpty) {
      return SizedBox(width: size, height: size);
    }

    return Draggable<Map<String, dynamic>>(
      data: {'letter': letter, 'index': index, 'isFromTarget': false},
      feedback: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(70),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      childWhenDragging: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(30),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: widget.color.withAlpha(150),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 3,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            letter,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
