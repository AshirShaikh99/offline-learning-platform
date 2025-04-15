import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NumbersActivityScreen extends StatefulWidget {
  final String title;
  final Color color;
  final List<Map<String, dynamic>> items;

  const NumbersActivityScreen({
    super.key,
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  State<NumbersActivityScreen> createState() => _NumbersActivityScreenState();
}

class _NumbersActivityScreenState extends State<NumbersActivityScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int? _tappedIndex;

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    // Set language to English
    await flutterTts.setLanguage("en-US");

    // Set other properties if needed
    await flutterTts.setSpeechRate(0.5); // Slower rate for children
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title), backgroundColor: widget.color),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: widget.items.length,
        itemBuilder: (context, index) {
          final item = widget.items[index];
          return GestureDetector(
            onTap: () {
              setState(() => _tappedIndex = index);
              Future.delayed(const Duration(milliseconds: 200), () {
                if (mounted) {
                  setState(() => _tappedIndex = null);
                }
              });
              _speak(item['text']);
            },
            child: AnimatedScale(
              scale: _tappedIndex == index ? 0.95 : 1.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: widget.color.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item['text'],
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _getNumberName(item['text']),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: widget.color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _getNumberName(String number) {
    switch (number) {
      case '1':
        return 'One';
      case '2':
        return 'Two';
      case '3':
        return 'Three';
      case '4':
        return 'Four';
      case '5':
        return 'Five';
      case '6':
        return 'Six';
      case '7':
        return 'Seven';
      case '8':
        return 'Eight';
      case '9':
        return 'Nine';
      case '10':
        return 'Ten';
      default:
        return number;
    }
  }
}
