import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class NumbersActivityScreen extends StatefulWidget {
  final String? title;
  final Color? color;
  final List<Map<String, dynamic>>? items;

  const NumbersActivityScreen({Key? key, this.title, this.color, this.items})
    : super(key: key);

  @override
  State<NumbersActivityScreen> createState() => _NumbersActivityScreenState();
}

class _NumbersActivityScreenState extends State<NumbersActivityScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late FlutterTts _flutterTts;
  int? _selectedNumberIndex;

  final List<Map<String, dynamic>> _numbers = [
    {'number': 1, 'word': 'One', 'pronunciation': 'one', 'spelling': 'O-N-E'},
    {'number': 2, 'word': 'Two', 'pronunciation': 'two', 'spelling': 'T-W-O'},
    {
      'number': 3,
      'word': 'Three',
      'pronunciation': 'three',
      'spelling': 'T-H-R-E-E',
    },
    {
      'number': 4,
      'word': 'Four',
      'pronunciation': 'four',
      'spelling': 'F-O-U-R',
    },
    {
      'number': 5,
      'word': 'Five',
      'pronunciation': 'five',
      'spelling': 'F-I-V-E',
    },
    {'number': 6, 'word': 'Six', 'pronunciation': 'six', 'spelling': 'S-I-X'},
    {
      'number': 7,
      'word': 'Seven',
      'pronunciation': 'seven',
      'spelling': 'S-E-V-E-N',
    },
    {
      'number': 8,
      'word': 'Eight',
      'pronunciation': 'eight',
      'spelling': 'E-I-G-H-T',
    },
    {
      'number': 9,
      'word': 'Nine',
      'pronunciation': 'nine',
      'spelling': 'N-I-N-E',
    },
    {'number': 10, 'word': 'Ten', 'pronunciation': 'ten', 'spelling': 'T-E-N'},
    {
      'number': 11,
      'word': 'Eleven',
      'pronunciation': 'eleven',
      'spelling': 'E-L-E-V-E-N',
    },
    {
      'number': 12,
      'word': 'Twelve',
      'pronunciation': 'twelve',
      'spelling': 'T-W-E-L-V-E',
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
  }

  Future<void> _speakNumber(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _controller.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(
          widget.title ?? 'Learn Numbers',
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildNumbersGrid(),
                  const SizedBox(height: 24),
                  if (_selectedNumberIndex != null) _buildDetailCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final Color headerColor = widget.color ?? const Color(0xFF0088FF);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [headerColor, headerColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: headerColor.withOpacity(0.2),
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
                child: const Icon(Icons.numbers, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'English Numbers',
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
            'Learn English numbers from 1 to 12. Tap on a number to see its details and hear its pronunciation.',
            style: TextStyle(color: Colors.white, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildNumbersGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 360 ? 2 : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 1.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _numbers.length,
      itemBuilder: (context, index) {
        final item = _numbers[index];
        final isSelected = _selectedNumberIndex == index;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedNumberIndex = index;
            });
            _speakNumber(item['word']);
            _controller.forward(from: 0);
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
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item['word'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: item['word'].length > 5 ? 18 : 22,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item['number']}',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 16,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailCard() {
    final selectedNumber = _numbers[_selectedNumberIndex!];

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: child,
        );
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF0088FF), width: 1),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0088FF).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0088FF), Color(0xFF5D00FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      selectedNumber['word'],
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: selectedNumber['word'].length > 5 ? 24 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Number ${selectedNumber['number']}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _speakNumber(selectedNumber['word']),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0088FF).withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.volume_up,
                                color: Color(0xFF0088FF),
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pronunciation: ${selectedNumber['pronunciation']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Spelling: ${selectedNumber['spelling']}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildExampleVisualization(selectedNumber['number']),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleVisualization(int number) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Example',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              number,
              (index) => Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0088FF), Color(0xFF5D00FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(Icons.star, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
