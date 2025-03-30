import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class LearningActivityScreen extends StatefulWidget {
  final String title;
  final Color color;
  final List<Map<String, dynamic>> items;

  const LearningActivityScreen({
    super.key,
    required this.title,
    required this.color,
    required this.items,
  });

  @override
  State<LearningActivityScreen> createState() => _LearningActivityScreenState();
}

class _LearningActivityScreenState extends State<LearningActivityScreen> {
  final FlutterTts flutterTts = FlutterTts();
  int? _tappedIndex;

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    await flutterTts.speak(text);
  }

  Widget _buildIcon(Map<String, dynamic> item) {
    if (item.containsKey('emoji')) {
      return Text(item['emoji'], style: const TextStyle(fontSize: 60));
    } else if (item.containsKey('icon')) {
      return Icon(item['icon'] as IconData, size: 60, color: widget.color);
    }
    return Text(
      item['text'],
      style: TextStyle(
        fontSize: 60,
        fontWeight: FontWeight.bold,
        color: widget.color,
      ),
    );
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
                    _buildIcon(item),
                    const SizedBox(height: 12),
                    Text(
                      item['text'],
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
}
