import 'package:flutter/material.dart';
import 'dart:math';

import '../../../core/theme/app_theme.dart';
import '../../../data/animal_matching_data.dart';
import '../improved_matching_game_screen.dart';

/// A demo screen that shows different matching game options
class MatchingGameDemoScreen extends StatefulWidget {
  /// Title of the screen
  final String? title;

  /// Theme color for the screen
  final Color? color;

  /// Constructor
  const MatchingGameDemoScreen({Key? key, this.title, this.color})
    : super(key: key);

  @override
  State<MatchingGameDemoScreen> createState() => _MatchingGameDemoScreenState();
}

class _MatchingGameDemoScreenState extends State<MatchingGameDemoScreen> {
  final List<Map<String, dynamic>> _pairs = [
    {'question': 'Apple', 'answer': 'سیب', 'matchId': 1},
    {'question': 'Book', 'answer': 'کتاب', 'matchId': 2},
    {'question': 'Cat', 'answer': 'بلی', 'matchId': 3},
    {'question': 'Dog', 'answer': 'کتا', 'matchId': 4},
    {'question': 'Elephant', 'answer': 'ہاتھی', 'matchId': 5},
    {'question': 'Fish', 'answer': 'مچھلی', 'matchId': 6},
  ];

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _answers = [];
  Map<int, bool> _matchedPairs = {};
  int? _selectedQuestionIndex;
  int? _selectedAnswerIndex;
  int _score = 0;
  int _attempts = 0;
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _questions = List.from(_pairs);
    _answers = List.from(_pairs);
    _questions.shuffle(Random());
    _answers.shuffle(Random());
    _matchedPairs = {};
    _selectedQuestionIndex = null;
    _selectedAnswerIndex = null;
    _score = 0;
    _attempts = 0;
    _showResults = false;
  }

  void _checkMatch() {
    if (_selectedQuestionIndex == null || _selectedAnswerIndex == null) return;

    final selectedQuestion = _questions[_selectedQuestionIndex!];
    final selectedAnswer = _answers[_selectedAnswerIndex!];
    _attempts++;

    if (selectedQuestion['matchId'] == selectedAnswer['matchId']) {
      // Match found
      setState(() {
        _matchedPairs[selectedQuestion['matchId']] = true;
        _score++;
      });

      // Check if all pairs are matched
      if (_matchedPairs.length == _pairs.length) {
        setState(() {
          _showResults = true;
        });
      }
    }

    // Reset selections after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _selectedQuestionIndex = null;
        _selectedAnswerIndex = null;
      });
    });
  }

  void _resetGame() {
    setState(() {
      _initGame();
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
          widget.title ?? 'Matching Game',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: (widget.color ?? const Color(0xFF0088FF)).withOpacity(
                0.15,
              ),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back,
              color: widget.color ?? const Color(0xFF0088FF),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          if (!_showResults) ...[
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(child: _buildQuestionList()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildAnswerList()),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(child: _buildResultsScreen()),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0088FF), Color(0xFF5D00FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0088FF).withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.games, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Match the Pairs',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Score: $_score/${_pairs.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Match each English word with its corresponding Urdu translation. Select an item from each column to check if they match.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0088FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'English Words',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final item = _questions[index];
              final isMatched = _matchedPairs[item['matchId']] ?? false;
              final isSelected = _selectedQuestionIndex == index;

              if (isMatched) {
                return _buildMatchedCard(item['question'], true);
              }

              return GestureDetector(
                onTap:
                    isMatched
                        ? null
                        : () {
                          setState(() {
                            _selectedQuestionIndex = index;
                            if (_selectedAnswerIndex != null) {
                              _checkMatch();
                            }
                          });
                        },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isSelected
                              ? [
                                const Color(0xFF0088FF),
                                const Color(0xFF5D00FF),
                              ]
                              : [
                                const Color(0xFF1A1A1A),
                                const Color(0xFF252550),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFF0088FF)
                              : const Color(0xFF3A3A3A),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: const Color(0xFF0088FF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [],
                  ),
                  child: Text(
                    item['question'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF5D00FF),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Urdu Words',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _answers.length,
            itemBuilder: (context, index) {
              final item = _answers[index];
              final isMatched = _matchedPairs[item['matchId']] ?? false;
              final isSelected = _selectedAnswerIndex == index;

              if (isMatched) {
                return _buildMatchedCard(item['answer'], false);
              }

              return GestureDetector(
                onTap:
                    isMatched
                        ? null
                        : () {
                          setState(() {
                            _selectedAnswerIndex = index;
                            if (_selectedQuestionIndex != null) {
                              _checkMatch();
                            }
                          });
                        },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors:
                          isSelected
                              ? [
                                const Color(0xFF5D00FF),
                                const Color(0xFF0088FF),
                              ]
                              : [
                                const Color(0xFF1A1A1A),
                                const Color(0xFF252550),
                              ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color:
                          isSelected
                              ? const Color(0xFF5D00FF)
                              : const Color(0xFF3A3A3A),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: const Color(0xFF5D00FF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                            : [],
                  ),
                  child: Text(
                    item['answer'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMatchedCard(String text, bool isQuestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00CC66), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFF00CC66),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(width: 8),
          const Icon(Icons.check_circle, color: Color(0xFF00CC66), size: 18),
        ],
      ),
    );
  }

  Widget _buildResultsScreen() {
    final accuracy = _attempts > 0 ? (_score / _attempts) * 100 : 0;
    final formattedAccuracy = accuracy.toStringAsFixed(1);

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A1A), Color(0xFF252550)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF0088FF), width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0088FF).withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0088FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFC107),
                size: 40,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Game Completed!',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0088FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Score: $_score/${_pairs.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Attempts: $_attempts',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Accuracy: $formattedAccuracy%',
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _resetGame,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Play Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0088FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Back to Activities',
                style: TextStyle(
                  color: Color(0xFF0088FF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
