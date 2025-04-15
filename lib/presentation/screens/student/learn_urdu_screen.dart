import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../core/theme/app_theme.dart';

/// A screen for learning Urdu with touch-based voice activity
class LearnUrduScreen extends StatefulWidget {
  const LearnUrduScreen({super.key});

  @override
  State<LearnUrduScreen> createState() => _LearnUrduScreenState();
}

class _LearnUrduScreenState extends State<LearnUrduScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String _currentWord = '';
  
  // List of Urdu letters with their transliterations and meanings
  final List<Map<String, String>> _urduLetters = [
    {
      'letter': 'ا',
      'transliteration': 'Alif',
      'example': 'Anaar (Pomegranate)',
      'image': 'assets/images/urdu/alif.png',
    },
    {
      'letter': 'ب',
      'transliteration': 'Bay',
      'example': 'Bakri (Goat)',
      'image': 'assets/images/urdu/bay.png',
    },
    {
      'letter': 'پ',
      'transliteration': 'Pay',
      'example': 'Pankha (Fan)',
      'image': 'assets/images/urdu/pay.png',
    },
    {
      'letter': 'ت',
      'transliteration': 'Tay',
      'example': 'Titli (Butterfly)',
      'image': 'assets/images/urdu/tay.png',
    },
    {
      'letter': 'ٹ',
      'transliteration': 'Ttay',
      'example': 'Tamatar (Tomato)',
      'image': 'assets/images/urdu/ttay.png',
    },
    {
      'letter': 'ث',
      'transliteration': 'Say',
      'example': 'Samar (Fruit)',
      'image': 'assets/images/urdu/say.png',
    },
    {
      'letter': 'ج',
      'transliteration': 'Jeem',
      'example': 'Jahaz (Airplane)',
      'image': 'assets/images/urdu/jeem.png',
    },
    {
      'letter': 'چ',
      'transliteration': 'Chay',
      'example': 'Chaand (Moon)',
      'image': 'assets/images/urdu/chay.png',
    },
    {
      'letter': 'ح',
      'transliteration': 'Hay',
      'example': 'Halwa (Sweet)',
      'image': 'assets/images/urdu/hay.png',
    },
    {
      'letter': 'خ',
      'transliteration': 'Khay',
      'example': 'Khargosh (Rabbit)',
      'image': 'assets/images/urdu/khay.png',
    },
  ];
  
  // List of common Urdu words with their meanings
  final List<Map<String, String>> _urduWords = [
    {
      'word': 'سلام',
      'transliteration': 'Salaam',
      'meaning': 'Peace/Hello',
      'image': 'assets/images/urdu/salaam.png',
    },
    {
      'word': 'شکریہ',
      'transliteration': 'Shukriya',
      'meaning': 'Thank you',
      'image': 'assets/images/urdu/shukriya.png',
    },
    {
      'word': 'پانی',
      'transliteration': 'Paani',
      'meaning': 'Water',
      'image': 'assets/images/urdu/paani.png',
    },
    {
      'word': 'کھانا',
      'transliteration': 'Khana',
      'meaning': 'Food',
      'image': 'assets/images/urdu/khana.png',
    },
    {
      'word': 'گھر',
      'transliteration': 'Ghar',
      'meaning': 'Home',
      'image': 'assets/images/urdu/ghar.png',
    },
  ];
  
  // List of Urdu numbers with their transliterations
  final List<Map<String, String>> _urduNumbers = [
    {
      'number': '١',
      'transliteration': 'Aik',
      'meaning': 'One',
      'image': 'assets/images/urdu/one.png',
    },
    {
      'number': '٢',
      'transliteration': 'Do',
      'meaning': 'Two',
      'image': 'assets/images/urdu/two.png',
    },
    {
      'number': '٣',
      'transliteration': 'Teen',
      'meaning': 'Three',
      'image': 'assets/images/urdu/three.png',
    },
    {
      'number': '٤',
      'transliteration': 'Chaar',
      'meaning': 'Four',
      'image': 'assets/images/urdu/four.png',
    },
    {
      'number': '٥',
      'transliteration': 'Paanch',
      'meaning': 'Five',
      'image': 'assets/images/urdu/five.png',
    },
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
    await _flutterTts.setLanguage('ur-PK');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _speak(String text) async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      setState(() {
        _isSpeaking = false;
      });
      
      if (_currentWord == text) {
        return;
      }
    }
    
    setState(() {
      _isSpeaking = true;
      _currentWord = text;
    });
    
    HapticFeedback.mediumImpact();
    await _flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Learn Urdu',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppTheme.indigoColor,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'Letters', icon: Icon(Icons.text_fields)),
              Tab(text: 'Words', icon: Icon(Icons.translate)),
              Tab(text: 'Numbers', icon: Icon(Icons.format_list_numbered)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLettersGrid(isSmallScreen),
            _buildWordsGrid(isSmallScreen),
            _buildNumbersGrid(isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildLettersGrid(bool isSmallScreen) {
    return GridView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 3,
        childAspectRatio: isSmallScreen ? 1.0 : 1.2,
        crossAxisSpacing: isSmallScreen ? 12 : 16,
        mainAxisSpacing: isSmallScreen ? 12 : 16,
      ),
      itemCount: _urduLetters.length,
      itemBuilder: (context, index) {
        final letter = _urduLetters[index];
        return _buildLetterCard(
          letter['letter']!,
          letter['transliteration']!,
          letter['example']!,
          isSmallScreen,
        );
      },
    );
  }

  Widget _buildWordsGrid(bool isSmallScreen) {
    return GridView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 1 : 2,
        childAspectRatio: isSmallScreen ? 2.0 : 2.2,
        crossAxisSpacing: isSmallScreen ? 12 : 16,
        mainAxisSpacing: isSmallScreen ? 12 : 16,
      ),
      itemCount: _urduWords.length,
      itemBuilder: (context, index) {
        final word = _urduWords[index];
        return _buildWordCard(
          word['word']!,
          word['transliteration']!,
          word['meaning']!,
          isSmallScreen,
        );
      },
    );
  }

  Widget _buildNumbersGrid(bool isSmallScreen) {
    return GridView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 3,
        childAspectRatio: isSmallScreen ? 1.0 : 1.2,
        crossAxisSpacing: isSmallScreen ? 12 : 16,
        mainAxisSpacing: isSmallScreen ? 12 : 16,
      ),
      itemCount: _urduNumbers.length,
      itemBuilder: (context, index) {
        final number = _urduNumbers[index];
        return _buildNumberCard(
          number['number']!,
          number['transliteration']!,
          number['meaning']!,
          isSmallScreen,
        );
      },
    );
  }

  Widget _buildLetterCard(
    String letter,
    String transliteration,
    String example,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _speak(transliteration),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.indigoColor,
                AppTheme.indigoColor.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                letter,
                style: TextStyle(
                  fontSize: isSmallScreen ? 48 : 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                transliteration,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                example,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Icon(
                _isSpeaking && _currentWord == transliteration
                    ? Icons.volume_up
                    : Icons.touch_app,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWordCard(
    String word,
    String transliteration,
    String meaning,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _speak(transliteration),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.tealColor,
                AppTheme.tealColor.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      word,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 32 : 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      transliteration,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 18 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      meaning,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 14 : 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  decoration: BoxDecoration(
                    color: _isSpeaking && _currentWord == transliteration
                        ? Colors.white.withOpacity(0.3)
                        : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSpeaking && _currentWord == transliteration
                        ? Icons.volume_up
                        : Icons.touch_app,
                    color: Colors.white,
                    size: isSmallScreen ? 40 : 48,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberCard(
    String number,
    String transliteration,
    String meaning,
    bool isSmallScreen,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => _speak(transliteration),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.orangeColor,
                AppTheme.orangeColor.withAlpha(200),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontSize: isSmallScreen ? 48 : 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                transliteration,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                meaning,
                style: TextStyle(
                  fontSize: isSmallScreen ? 12 : 14,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Icon(
                _isSpeaking && _currentWord == transliteration
                    ? Icons.volume_up
                    : Icons.touch_app,
                color: Colors.white,
                size: isSmallScreen ? 20 : 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
