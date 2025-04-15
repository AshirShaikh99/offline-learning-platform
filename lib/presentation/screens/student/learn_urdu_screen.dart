import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/theme/app_theme.dart';

/// A model class for Urdu letters
class Letter {
  final String letter;
  final String name;
  final String sound;
  final String pronunciation;

  Letter({
    required this.letter,
    required this.name,
    required this.sound,
    required this.pronunciation,
  });

  factory Letter.fromMap(Map<String, dynamic> map) {
    return Letter(
      letter: map['letter'] as String,
      name: map['name'] as String,
      sound: map['sound'] as String,
      pronunciation: map['pronunciation'] as String,
    );
  }
}

/// A screen for learning Urdu with touch-based voice activity
class LearnUrduScreen extends StatefulWidget {
  const LearnUrduScreen({Key? key}) : super(key: key);

  @override
  State<LearnUrduScreen> createState() => _LearnUrduScreenState();
}

class _LearnUrduScreenState extends State<LearnUrduScreen> {
  int _selectedIndex = -1;
  Letter? _selectedLetter;
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;

  final List<Letter> _letters = [
    Letter(letter: 'ا', name: 'Alif', sound: 'ah', pronunciation: 'الف'),
    Letter(letter: 'ب', name: 'Bay', sound: 'b', pronunciation: 'بے'),
    Letter(letter: 'پ', name: 'Pay', sound: 'p', pronunciation: 'پے'),
    Letter(letter: 'ت', name: 'Tay', sound: 't', pronunciation: 'تے'),
    Letter(letter: 'ٹ', name: 'Ttay', sound: 't (hard)', pronunciation: 'ٹے'),
    Letter(letter: 'ث', name: 'Say', sound: 's', pronunciation: 'سے'),
    Letter(letter: 'ج', name: 'Jeem', sound: 'j', pronunciation: 'جیم'),
    Letter(letter: 'چ', name: 'Chay', sound: 'ch', pronunciation: 'چے'),
    Letter(letter: 'ح', name: 'Hay', sound: 'h (heavy)', pronunciation: 'حے'),
    Letter(letter: 'خ', name: 'Khay', sound: 'kh', pronunciation: 'خے'),
    Letter(letter: 'د', name: 'Daal', sound: 'd', pronunciation: 'دال'),
    Letter(letter: 'ڈ', name: 'Ddaal', sound: 'd (hard)', pronunciation: 'ڈال'),
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setSpeechRate(0.5);

    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setErrorHandler((error) {
      setState(() {
        _isSpeaking = false;
      });
      debugPrint('TTS error: $error');
    });
  }

  Future<void> _speak(String text, {bool isEnglish = false}) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _isSpeaking = true;
    });

    try {
      await _flutterTts.setLanguage(isEnglish ? "en-US" : "ur-PK");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint('Error playing TTS: $e');
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  void _playSound(Letter letter) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
      await Future.delayed(const Duration(milliseconds: 200));
    }

    setState(() {
      _isSpeaking = true;
    });

    try {
      // Play the English pronunciation
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(letter.name);

      // Wait a moment before playing the Urdu pronunciation
      await Future.delayed(const Duration(milliseconds: 1500));

      // Play the Urdu pronunciation
      await _flutterTts.setLanguage("ur-PK");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(letter.pronunciation);
    } catch (e) {
      debugPrint('Error playing TTS: $e');
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Learn Urdu Alphabet',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF0088FF).withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: const Icon(
              Icons.arrow_back,
              color: Color(0xFF0088FF),
              size: 20,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.1,
              ),
              itemCount: _letters.length,
              itemBuilder: (context, index) {
                return _buildLetterCard(index);
              },
            ),
          ),
          if (_selectedIndex != -1) _buildDetailCard(),
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
                child: const Icon(
                  Icons.translate,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Urdu Learning',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Learn the Urdu alphabet with interactive cards. Tap on a letter to hear its pronunciation and see examples.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.lightbulb, color: Colors.yellow, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap on any card to learn more!',
                  style: TextStyle(
                    color: Colors.yellow.shade200,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLetterCard(int index) {
    final letter = _letters[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? -1 : index;
          _selectedLetter = isSelected ? null : letter;
        });
        _playSound(letter);
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:
                isSelected
                    ? [const Color(0xFF0088FF), const Color(0xFF5D00FF)]
                    : [const Color(0xFF1A1A1A), const Color(0xFF252550)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color:
                isSelected ? const Color(0xFF0088FF) : const Color(0xFF3A3A3A),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              letter.letter,
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF0088FF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              letter.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard() {
    if (_selectedIndex == -1 || _selectedLetter == null)
      return const SizedBox();

    final letter = _selectedLetter!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0088FF).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF0088FF).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    letter.letter,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0088FF),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      letter.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pronounced: ${letter.sound}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.volume_up, color: Color(0xFF0088FF)),
                    onPressed: () => _playSound(letter),
                    tooltip: 'Speak in Urdu',
                  ),
                  IconButton(
                    icon: const Icon(Icons.language, color: Colors.green),
                    onPressed: () => _speak(letter.name, isEnglish: true),
                    tooltip: 'Speak in English',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.arrow_right, color: Color(0xFF0088FF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Pronunciation in Urdu: ${letter.pronunciation}',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedIndex = -1;
                    _selectedLetter = null;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF252550),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: () => _playSound(letter),
                icon: const Icon(Icons.volume_up, size: 18),
                label: const Text('Urdu'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0088FF),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () => _speak(letter.name, isEnglish: true),
                icon: const Icon(Icons.language, size: 18),
                label: const Text('English'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
