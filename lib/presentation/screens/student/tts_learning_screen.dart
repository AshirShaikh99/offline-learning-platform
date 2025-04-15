import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io' show Platform;

/// A screen for learning content like alphabets, shapes, and animals with text-to-speech
class TtsLearningScreen extends StatefulWidget {
  final String title;
  final Color color;
  final List<Map<String, dynamic>> items;

  const TtsLearningScreen({
    Key? key,
    required this.title,
    required this.color,
    required this.items,
  }) : super(key: key);

  @override
  State<TtsLearningScreen> createState() => _TtsLearningScreenState();
}

class _TtsLearningScreenState extends State<TtsLearningScreen> {
  late FlutterTts _flutterTts;
  bool _isSpeaking = false;
  int? _selectedItemIndex;
  bool _ttsInitialized = false;
  String _ttsStatus = "Initializing...";

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  // Check if TTS is available
  Future<bool> _isTtsAvailable() async {
    try {
      final languages = await _flutterTts.getLanguages;
      return languages.isNotEmpty;
    } catch (e) {
      print("Error checking TTS availability: $e");
      return false;
    }
  }

  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    // Debug available languages
    print("Initializing TTS");

    try {
      final available = await _flutterTts.getLanguages;
      print("Available languages: $available");

      final isAvailable = await _isTtsAvailable();
      if (!isAvailable) {
        setState(() {
          _ttsStatus = "TTS not available";
        });
        print("TTS not available");
        return;
      }

      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      // Set platform-specific options
      if (Platform.isIOS) {
        try {
          await _flutterTts.setIosAudioCategory(
            IosTextToSpeechAudioCategory.playback,
            [
              IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
              IosTextToSpeechAudioCategoryOptions.allowBluetooth,
              IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
              IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            ],
            IosTextToSpeechAudioMode.defaultMode,
          );
        } catch (e) {
          print("Error setting iOS audio category: $e");
        }
      }

      setState(() {
        _ttsInitialized = true;
        _ttsStatus = "Ready";
      });
      print("TTS initialized successfully");
    } catch (e) {
      setState(() {
        _ttsStatus = "Error: $e";
      });
      print("Error initializing TTS: $e");
    }

    _flutterTts.setCompletionHandler(() {
      print("TTS completed");
      setState(() {
        _isSpeaking = false;
      });
    });

    _flutterTts.setErrorHandler((error) {
      print("TTS error: $error");
      setState(() {
        _isSpeaking = false;
        _ttsStatus = "Error: $error";
      });
    });
  }

  Future<void> _speak(String text) async {
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
      // Clean text (remove emoji if any) for better pronunciation
      String textToSpeak = text;

      // Debug the TTS process
      print("Speaking: $textToSpeak");

      await _flutterTts.speak(textToSpeak);
    } catch (e) {
      print("Error during TTS: $e");
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate screen size to make the grid responsive
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    // Determine grid columns based on screen width
    final crossAxisCount = isSmallScreen ? 2 : 3;
    // Adjust aspect ratio based on content type and screen size
    double childAspectRatio = 0.9;

    // Alphabets need less height than animals or shapes
    if (widget.title == 'Alphabets') {
      childAspectRatio = isSmallScreen ? 0.9 : 1.0;
    } else if (widget.title == 'Animals' || widget.title == 'Shapes') {
      childAspectRatio = isSmallScreen ? 0.8 : 0.9;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: Container(
            decoration: BoxDecoration(
              color: widget.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: Icon(Icons.arrow_back, color: widget.color, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Debug action to check TTS status
          IconButton(
            icon: Icon(Icons.info_outline, color: widget.color),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('TTS Status: $_ttsStatus'),
                  backgroundColor: Colors.black87,
                  duration: const Duration(seconds: 3),
                ),
              );

              // Try to speak a test message
              if (_ttsInitialized) {
                _speak("Text to speech is working");
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: isSmallScreen ? 8 : 12,
                mainAxisSpacing: isSmallScreen ? 8 : 12,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return _buildItemCard(item, index, isSmallScreen);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    // Get screen size for responsiveness
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.fromLTRB(16, 8, 16, isSmallScreen ? 8 : 16),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            widget.color.withOpacity(0.8),
            widget.color.withOpacity(0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            ),
            child: Icon(
              _getIconForTitle(widget.title),
              color: Colors.white,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Learn ${widget.title}",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 8),
                Text(
                  "Tap on the ${widget.title.toLowerCase()} to hear them pronounced",
                  style: TextStyle(
                    fontSize: isSmallScreen ? 12 : 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(
    Map<String, dynamic> item,
    int index,
    bool isSmallScreen,
  ) {
    final isSelected = _selectedItemIndex == index;
    final hasEmoji = item.containsKey('emoji');
    final hasIcon = item.containsKey('icon');

    // Adjust sizes based on screen size
    final double iconSize = isSmallScreen ? 28 : 32;
    final double textSize = isSmallScreen ? 14 : 18;
    final double fontSize = isSmallScreen ? 12 : 14;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedItemIndex = index;
        });

        // Get the text to speak based on item type
        String textToSpeak = item['text'] as String;

        // Add additional context for certain categories
        if (widget.title == 'Shapes') {
          textToSpeak = "This is a $textToSpeak";
        } else if (widget.title == 'Animals') {
          textToSpeak = "This is a $textToSpeak";
        }

        print("Will speak: $textToSpeak");
        _speak(textToSpeak);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color:
              isSelected
                  ? widget.color.withOpacity(0.3)
                  : const Color(0xFF121212),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? widget.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  isSelected
                      ? widget.color.withOpacity(0.4)
                      : Colors.black.withOpacity(0.2),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (hasEmoji)
                  Text(
                    item['emoji'] as String,
                    style: TextStyle(fontSize: iconSize),
                  ),
                if (hasIcon)
                  Icon(
                    item['icon'] as IconData,
                    color: widget.color,
                    size: iconSize,
                  ),
                if (!hasEmoji && !hasIcon)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      item['text'] as String,
                      style: TextStyle(
                        fontSize: textSize,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    item['text'] as String,
                    style: TextStyle(
                      fontSize: fontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isSelected && _isSpeaking)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForTitle(String title) {
    switch (title.toLowerCase()) {
      case 'alphabets':
        return Icons.abc;
      case 'shapes':
        return Icons.category;
      case 'animals':
        return Icons.pets;
      default:
        return Icons.school;
    }
  }
}
