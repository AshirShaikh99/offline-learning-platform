import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/matching_item.dart';

/// A simple matching game screen that uses Flutter's built-in drag and drop functionality
class SimpleMatchingGameScreen extends StatefulWidget {
  final String title;
  final Color color;
  final List<MatchingItem> leftItems;
  final List<MatchingItem> rightItems;

  const SimpleMatchingGameScreen({
    Key? key,
    required this.title,
    required this.color,
    required this.leftItems,
    required this.rightItems,
  }) : super(key: key);

  @override
  State<SimpleMatchingGameScreen> createState() =>
      _SimpleMatchingGameScreenState();
}

class _SimpleMatchingGameScreenState extends State<SimpleMatchingGameScreen> {
  // Map to track matched pairs (leftItemId -> rightItemId)
  final Map<String, String> _matches = {};

  // Map to track if matches are correct
  final Map<String, bool> _correctMatches = {};

  // Track if all items are correctly matched
  bool _allMatched = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: widget.color,
        foregroundColor: Colors.white,
        actions: [
          // Reset button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetGame,
            tooltip: 'Reset Game',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Text(
            'Drag from an item to its matching name!',
            style: TextStyle(
              fontSize: isSmallScreen ? 18 : 22,
              fontWeight: FontWeight.bold,
              color: widget.color,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Main game area
          Expanded(
            child:
                orientation == Orientation.portrait
                    ? _buildPortraitLayout()
                    : _buildLandscapeLayout(),
          ),

          // Success message when all items are matched correctly
          if (_allMatched)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    'Great job! All matches are correct!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade800,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column (items)
        Expanded(child: _buildLeftItems()),

        // Right column (names)
        Expanded(child: _buildRightItems()),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Column(
      children: [
        // Top row (items)
        Expanded(child: _buildLeftItems(horizontal: true)),

        // Bottom row (names)
        Expanded(child: _buildRightItems(horizontal: true)),
      ],
    );
  }

  Widget _buildLeftItems({bool horizontal = false}) {
    return ListView.builder(
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      itemCount: widget.leftItems.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final item = widget.leftItems[index];
        final isMatched = _matches.containsKey(item.id);
        final isCorrect = _correctMatches[item.id] ?? false;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Draggable<String>(
            // The data is the item's ID
            data: item.id,

            // What the user drags
            feedback: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue, width: 3),
                ),
                child: Center(child: _buildItemContent(item)),
              ),
            ),

            // What's shown in the original position while dragging
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: _buildItemCard(item, isMatched, isCorrect),
            ),

            // Callbacks
            onDragStarted: () {
              HapticFeedback.lightImpact();
            },
            onDragEnd: (details) {
              HapticFeedback.mediumImpact();
            },
            onDragCompleted: () {
              HapticFeedback.heavyImpact();
            },

            // The actual widget
            child: _buildItemCard(item, isMatched, isCorrect),
          ),
        );
      },
    );
  }

  Widget _buildRightItems({bool horizontal = false}) {
    return ListView.builder(
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      itemCount: widget.rightItems.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final item = widget.rightItems[index];
        final isMatched = _matches.containsValue(item.id);
        final isCorrect =
            _matches.entries
                .where((entry) => entry.value == item.id)
                .map((entry) => _correctMatches[entry.key] ?? false)
                .firstOrNull ??
            false;

        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: DragTarget<String>(
            onAcceptWithDetails: (details) {
              // Get the dragged item ID
              final draggedItemId = details.data;

              // Check if this item is already matched
              if (_matches.containsKey(draggedItemId)) {
                // Remove the old match
                _matches.remove(draggedItemId);
                _correctMatches.remove(draggedItemId);
              }

              // Create a new match
              setState(() {
                _matches[draggedItemId] = item.id;

                // Check if the match is correct (IDs should match)
                final draggedItem = widget.leftItems.firstWhere(
                  (leftItem) => leftItem.id == draggedItemId,
                  orElse:
                      () => const MatchingItem(id: '', name: '', imagePath: ''),
                );

                _correctMatches[draggedItemId] = draggedItem.id == item.id;

                // Check if all items are correctly matched
                _checkAllMatched();
              });

              HapticFeedback.heavyImpact();
            },

            // Always accept drops
            onWillAcceptWithDetails: (details) => true,

            // Provide feedback when hovering
            onMove: (details) {
              HapticFeedback.selectionClick();
            },

            // Builder for the target
            builder: (context, candidateData, rejectedData) {
              final isHovering = candidateData.isNotEmpty;

              return _buildNameCard(item, isMatched, isCorrect, isHovering);
            },
          ),
        );
      },
    );
  }

  Widget _buildItemCard(MatchingItem item, bool isMatched, bool isCorrect) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isMatched
                    ? (isCorrect
                        ? const Color(0x804CAF50) // Green with 50% opacity
                        : const Color(0x80F44336)) // Red with 50% opacity
                    : const Color(0x1A000000), // Black with 10% opacity
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              isMatched
                  ? (isCorrect ? Colors.green : Colors.red)
                  : const Color(0xFFE0E0E0), // Grey shade 300
          width: 3,
        ),
      ),
      child: Center(child: _buildItemContent(item)),
    );
  }

  Widget _buildNameCard(
    MatchingItem item,
    bool isMatched,
    bool isCorrect,
    bool isHovering,
  ) {
    return Container(
      width: 120,
      height: 60,
      decoration: BoxDecoration(
        color:
            isHovering
                ? const Color(0xFFE3F2FD)
                : Colors.white, // Light blue shade
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isHovering
                    ? const Color(0x4D2196F3) // Blue with 30% opacity
                    : (isMatched
                        ? (isCorrect
                            ? const Color(0x804CAF50) // Green with 50% opacity
                            : const Color(0x80F44336)) // Red with 50% opacity
                        : const Color(0x1A000000)), // Black with 10% opacity
            blurRadius: isHovering ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color:
              isHovering
                  ? const Color(0xFF2196F3) // Blue
                  : (isMatched
                      ? (isCorrect
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFF44336)) // Green or Red
                      : const Color(0xFFE0E0E0)), // Grey shade 300
          width: isHovering ? 4 : 3,
        ),
      ),
      child: Center(
        child: Text(
          item.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildItemContent(MatchingItem item) {
    // If the item has an image path that ends with .txt, show an emoji or icon
    if (item.imagePath.endsWith('.txt')) {
      return _getIconForItem(item.name);
    } else {
      // Otherwise, show the image
      return Image.asset(item.imagePath, fit: BoxFit.cover);
    }
  }

  Widget _getIconForItem(String name) {
    // Map of item names to their corresponding emojis
    final Map<String, String> animalEmojis = {
      'Cat': '🐱',
      'Dog': '🐶',
      'Elephant': '🐘',
      'Lion': '🦁',
      'Monkey': '🐵',
      'Giraffe': '🦒',
      'Zebra': '🦓',
      'Cow': '🐄',
    };

    final Map<String, String> fruitEmojis = {
      'Apple': '🍎',
      'Banana': '🍌',
      'Orange': '🍊',
      'Strawberry': '🍓',
      'Watermelon': '🍉',
      'Grapes': '🍇',
    };

    // For colors, use a colored circle
    final Map<String, Color> colorMap = {
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Yellow': Colors.yellow,
      'Purple': Colors.purple,
      'Orange': Colors.orange,
    };

    // Check if we have an emoji for this item
    String? emoji = animalEmojis[name] ?? fruitEmojis[name];

    if (emoji != null) {
      return Text(emoji, style: const TextStyle(fontSize: 48));
    }

    // For colors, show a colored circle
    if (colorMap.containsKey(name)) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorMap[name],
          shape: BoxShape.circle,
        ),
      );
    }

    // Default fallback
    return Icon(Icons.image, size: 48, color: Colors.grey);
  }

  void _checkAllMatched() {
    // Check if all left items are matched
    if (_matches.length == widget.leftItems.length) {
      // Check if all matches are correct
      final allCorrect = _correctMatches.values.every((isCorrect) => isCorrect);

      setState(() {
        _allMatched = allCorrect;
      });
    } else {
      setState(() {
        _allMatched = false;
      });
    }
  }

  void _resetGame() {
    setState(() {
      _matches.clear();
      _correctMatches.clear();
      _allMatched = false;
    });

    HapticFeedback.mediumImpact();
  }
}
