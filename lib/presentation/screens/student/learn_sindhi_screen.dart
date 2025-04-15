import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../core/theme/app_theme.dart';

/// A screen for learning Sindhi with touch-based voice activity
class LearnSindhiScreen extends StatefulWidget {
  const LearnSindhiScreen({super.key});

  @override
  State<LearnSindhiScreen> createState() => _LearnSindhiScreenState();
}

class _LearnSindhiScreenState extends State<LearnSindhiScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String _currentSound = '';
  late TabController _tabController;

  // List of Sindhi letters with their transliterations and audio paths
  final List<Map<String, String>> _sindhiLetters = [
    {
      'letter': 'ا',
      'transliteration': 'Alif',
      'example': 'Anaar (Pomegranate)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.11 PM.ogg',
    },
    {
      'letter': 'ب',
      'transliteration': 'Bay',
      'example': 'Bakro (Goat)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.12 PM.ogg',
    },
    {
      'letter': 'پ',
      'transliteration': 'Pay',
      'example': 'Pakhee (Bird)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.13 PM.ogg',
    },
    {
      'letter': 'ت',
      'transliteration': 'Tay',
      'example': 'Taro (Star)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.14 PM.ogg',
    },
    {
      'letter': 'ٽ',
      'transliteration': 'Ttay',
      'example': 'Ttopo (Hat)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.15 PM.ogg',
    },
    {
      'letter': 'ث',
      'transliteration': 'Say',
      'example': 'Samar (Fruit)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.16 PM.ogg',
    },
    {
      'letter': 'ج',
      'transliteration': 'Jeem',
      'example': 'Jahaz (Ship)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.17 PM.ogg',
    },
    {
      'letter': 'ڄ',
      'transliteration': 'Jjay',
      'example': 'Jjoli (Bag)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.18 PM.ogg',
    },
    {
      'letter': 'چ',
      'transliteration': 'Chay',
      'example': 'Chand (Moon)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.19 PM.ogg',
    },
    {
      'letter': 'ح',
      'transliteration': 'Hay',
      'example': 'Hathi (Elephant)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.20 PM.ogg',
    },
  ];

  // List of common Sindhi words with their meanings
  final List<Map<String, String>> _sindhiWords = [
    {
      'word': 'سلام',
      'transliteration': 'Salaam',
      'meaning': 'Peace/Hello',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.21 PM.ogg',
    },
    {
      'word': 'مهرباني',
      'transliteration': 'Mehrbani',
      'meaning': 'Thank you',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.22 PM.ogg',
    },
    {
      'word': 'پاڻي',
      'transliteration': 'Paani',
      'meaning': 'Water',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.23 PM.ogg',
    },
    {
      'word': 'ماني',
      'transliteration': 'Maani',
      'meaning': 'Food/Bread',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.24 PM.ogg',
    },
    {
      'word': 'گھر',
      'transliteration': 'Ghar',
      'meaning': 'Home',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.25 PM.ogg',
    },
  ];

  // List of Sindhi numbers with their transliterations
  final List<Map<String, String>> _sindhiNumbers = [
    {
      'number': '١',
      'transliteration': 'Hik',
      'meaning': 'One',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.26 PM.ogg',
    },
    {
      'number': '٢',
      'transliteration': 'Ba',
      'meaning': 'Two',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.27 PM.ogg',
    },
    {
      'number': '٣',
      'transliteration': 'Tay',
      'meaning': 'Three',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.28 PM.ogg',
    },
    {
      'number': '٤',
      'transliteration': 'Char',
      'meaning': 'Four',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.29 PM.ogg',
    },
    {
      'number': '٥',
      'transliteration': 'Panj',
      'meaning': 'Five',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.30 PM.ogg',
    },
  ];

  // List of Sindhi phonics sounds
  final List<Map<String, String>> _sindhiPhonics = [
    {
      'sound': 'آ',
      'transliteration': 'Aa',
      'example': 'آم (Mango)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.31 PM.ogg',
    },
    {
      'sound': 'اِ',
      'transliteration': 'I',
      'example': 'اِمام (Leader)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.32 PM.ogg',
    },
    {
      'sound': 'اُ',
      'transliteration': 'U',
      'example': 'اُٺ (Camel)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.33 PM.ogg',
    },
    {
      'sound': 'اے',
      'transliteration': 'Ay',
      'example': 'اےينڪ (Glasses)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.34 PM.ogg',
    },
    {
      'sound': 'او',
      'transliteration': 'O',
      'example': 'اوڙ (Drought)',
      'audio': 'assets/sindhi/WhatsApp Audio 2025-04-05 at 11.26.35 PM.ogg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupAudioPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _setupAudioPlayer() async {
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
      });
    });
  }

  Future<void> _playSound(String audioPath) async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });

      if (_currentSound == audioPath) {
        return;
      }
    }

    setState(() {
      _isPlaying = true;
      _currentSound = audioPath;
    });

    HapticFeedback.mediumImpact();

    try {
      await _audioPlayer.play(
        AssetSource(audioPath.replaceFirst('assets/', '')),
      );
    } catch (e) {
      debugPrint('Error playing sound: $e');
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Learn Sindhi',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: AppTheme.orangeColor,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Letters', icon: Icon(Icons.text_fields)),
            Tab(text: 'Words', icon: Icon(Icons.translate)),
            Tab(text: 'Numbers', icon: Icon(Icons.format_list_numbered)),
            Tab(text: 'Phonics', icon: Icon(Icons.record_voice_over)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildLettersGrid(isSmallScreen),
          _buildWordsGrid(isSmallScreen),
          _buildNumbersGrid(isSmallScreen),
          _buildPhonicsGrid(isSmallScreen),
        ],
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
      itemCount: _sindhiLetters.length,
      itemBuilder: (context, index) {
        final letter = _sindhiLetters[index];
        return _buildLetterCard(
          letter['letter']!,
          letter['transliteration']!,
          letter['example']!,
          letter['audio']!,
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
      itemCount: _sindhiWords.length,
      itemBuilder: (context, index) {
        final word = _sindhiWords[index];
        return _buildWordCard(
          word['word']!,
          word['transliteration']!,
          word['meaning']!,
          word['audio']!,
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
      itemCount: _sindhiNumbers.length,
      itemBuilder: (context, index) {
        final number = _sindhiNumbers[index];
        return _buildNumberCard(
          number['number']!,
          number['transliteration']!,
          number['meaning']!,
          number['audio']!,
          isSmallScreen,
        );
      },
    );
  }

  Widget _buildPhonicsGrid(bool isSmallScreen) {
    return GridView.builder(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isSmallScreen ? 2 : 3,
        childAspectRatio: isSmallScreen ? 1.0 : 1.2,
        crossAxisSpacing: isSmallScreen ? 12 : 16,
        mainAxisSpacing: isSmallScreen ? 12 : 16,
      ),
      itemCount: _sindhiPhonics.length,
      itemBuilder: (context, index) {
        final phonic = _sindhiPhonics[index];
        return _buildPhonicCard(
          phonic['sound']!,
          phonic['transliteration']!,
          phonic['example']!,
          phonic['audio']!,
          isSmallScreen,
        );
      },
    );
  }

  Widget _buildLetterCard(
    String letter,
    String transliteration,
    String example,
    String audioPath,
    bool isSmallScreen,
  ) {
    final isCurrentlyPlaying = _isPlaying && _currentSound == audioPath;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _playSound(audioPath),
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isCurrentlyPlaying
                          ? Colors.white.withOpacity(0.3)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCurrentlyPlaying ? Icons.volume_up : Icons.touch_app,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
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
    String audioPath,
    bool isSmallScreen,
  ) {
    final isCurrentlyPlaying = _isPlaying && _currentSound == audioPath;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _playSound(audioPath),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [AppTheme.tealColor, AppTheme.tealColor.withAlpha(200)],
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
                    color:
                        isCurrentlyPlaying
                            ? Colors.white.withOpacity(0.3)
                            : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCurrentlyPlaying ? Icons.volume_up : Icons.touch_app,
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
    String audioPath,
    bool isSmallScreen,
  ) {
    final isCurrentlyPlaying = _isPlaying && _currentSound == audioPath;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _playSound(audioPath),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                AppTheme.purpleColor,
                AppTheme.purpleColor.withAlpha(200),
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isCurrentlyPlaying
                          ? Colors.white.withOpacity(0.3)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCurrentlyPlaying ? Icons.volume_up : Icons.touch_app,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhonicCard(
    String sound,
    String transliteration,
    String example,
    String audioPath,
    bool isSmallScreen,
  ) {
    final isCurrentlyPlaying = _isPlaying && _currentSound == audioPath;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _playSound(audioPath),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [AppTheme.blueColor, AppTheme.blueColor.withAlpha(200)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                sound,
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color:
                      isCurrentlyPlaying
                          ? Colors.white.withOpacity(0.3)
                          : Colors.transparent,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCurrentlyPlaying ? Icons.volume_up : Icons.touch_app,
                  color: Colors.white,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
