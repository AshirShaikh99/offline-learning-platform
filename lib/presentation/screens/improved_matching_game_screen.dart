import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/matching_game.dart';
import '../../domain/entities/matching_item.dart';

/// An improved matching game screen that uses Flutter's built-in drag and drop functionality
class ImprovedMatchingGameScreen extends StatefulWidget {
  /// The matching game to display
  final MatchingGame game;

  const ImprovedMatchingGameScreen({
    super.key,
    required this.game,
  });

  @override
  State<ImprovedMatchingGameScreen> createState() => _ImprovedMatchingGameScreenState();
}

class _ImprovedMatchingGameScreenState extends State<ImprovedMatchingGameScreen> {
  // Lists for left and right items
  late List<MatchingItem> leftItems;
  late List<MatchingItem> rightItems;
  
  // Map to track matched pairs (leftItemId -> rightItemId)
  final Map<String, String> _matches = {};
  
  // Map to track if matches are correct
  final Map<String, bool> _correctMatches = {};
  
  // Track if all items are correctly matched
  bool _allMatched = false;

  @override
  void initState() {
    super.initState();
    _setupGame();
  }
  
  void _setupGame() {
    // Create two copies of each item
    final allItems = List<MatchingItem>.from(widget.game.items);
    
    // Shuffle the items to randomize the order
    allItems.shuffle();
    
    // Split the items into left and right
    leftItems = [];
    rightItems = [];
    
    // Create pairs of items with the same ID
    for (final item in widget.game.items) {
      // Create a copy for the left side (image/icon)
      leftItems.add(item);
      
      // Create a copy for the right side (text)
      rightItems.add(item);
    }
    
    // Shuffle both lists to randomize the order
    leftItems.shuffle();
    rightItems.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final orientation = MediaQuery.of(context).orientation;
    final gameColor = Color(widget.game.colorValue);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.game.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: gameColor,
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
              color: gameColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Main game area
          Expanded(
            child: orientation == Orientation.portrait
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
                  const Icon(Icons.check_circle, color: Colors.green, size: 24),
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
        Expanded(
          child: _buildLeftItems(),
        ),
        
        // Right column (names)
        Expanded(
          child: _buildRightItems(),
        ),
      ],
    );
  }

  Widget _buildLandscapeLayout() {
    return Column(
      children: [
        // Top row (items)
        Expanded(
          child: _buildLeftItems(horizontal: true),
        ),
        
        // Bottom row (names)
        Expanded(
          child: _buildRightItems(horizontal: true),
        ),
      ],
    );
  }

  Widget _buildLeftItems({bool horizontal = false}) {
    return ListView.builder(
      scrollDirection: horizontal ? Axis.horizontal : Axis.vertical,
      itemCount: leftItems.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final item = leftItems[index];
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
                  border: Border.all(
                    color: const Color(0xFF2196F3),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: _buildItemContent(item),
                ),
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
      itemCount: rightItems.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        final item = rightItems[index];
        final isMatched = _matches.values.contains(item.id);
        final matchedLeftItemId = _matches.entries
            .where((entry) => entry.value == item.id)
            .map((entry) => entry.key)
            .firstOrNull;
        final isCorrect = matchedLeftItemId != null ? 
            (_correctMatches[matchedLeftItemId] ?? false) : false;
        
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
                _correctMatches[draggedItemId] = draggedItemId == item.id;
                
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
            color: isMatched
                ? (isCorrect
                    ? const Color(0x804CAF50) // Green with 50% opacity
                    : const Color(0x80F44336)) // Red with 50% opacity
                : const Color(0x1A000000), // Black with 10% opacity
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isMatched
              ? (isCorrect ? const Color(0xFF4CAF50) : const Color(0xFFF44336))
              : const Color(0xFFE0E0E0), // Grey shade 300
          width: 3,
        ),
      ),
      child: Center(
        child: _buildItemContent(item),
      ),
    );
  }

  Widget _buildNameCard(MatchingItem item, bool isMatched, bool isCorrect, bool isHovering) {
    return Container(
      width: 120,
      height: 60,
      decoration: BoxDecoration(
        color: isHovering
            ? const Color(0xFFE3F2FD)
            : Colors.white, // Light blue shade
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isHovering
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
          color: isHovering
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
          style: const TextStyle(
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
    // If the item has a color value, show a colored circle
    if (item.colorValue != null) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Color(item.colorValue!),
          shape: BoxShape.circle,
        ),
      );
    }
    
    // Check if the item is an animal or fruit based on its name
    final animalEmojis = {
      'Cat': '🐱',
      'Dog': '🐶',
      'Elephant': '🐘',
      'Lion': '🦁',
      'Monkey': '🐵',
      'Giraffe': '🦒',
      'Zebra': '🦓',
      'Cow': '🐄',
    };
    
    final fruitEmojis = {
      'Apple': '🍎',
      'Banana': '🍌',
      'Orange': '🍊',
      'Strawberry': '🍓',
      'Watermelon': '🍉',
      'Grapes': '🍇',
    };
    
    // Check if we have an emoji for this item
    String? emoji = animalEmojis[item.name] ?? fruitEmojis[item.name];
    
    if (emoji != null) {
      return Text(
        emoji,
        style: const TextStyle(fontSize: 48),
      );
    }
    
    // Default fallback
    return const Icon(
      Icons.image,
      size: 48,
      color: Colors.grey,
    );
  }

  void _checkAllMatched() {
    // Check if all left items are matched
    if (_matches.length == leftItems.length) {
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
      
      // Re-shuffle the items
      leftItems.shuffle();
      rightItems.shuffle();
    });
    
    HapticFeedback.mediumImpact();
  }
}
