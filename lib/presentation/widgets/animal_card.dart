import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/matching_item.dart';

/// A widget that displays an animal card with an image
class AnimalCard extends StatelessWidget {
  /// The matching item to display
  final MatchingItem item;

  /// Whether the card is connected to another card
  final bool isConnected;

  /// Whether the connection is correct
  final bool isCorrect;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Callback when a drag starts from this card
  final Function(Offset position)? onDragStart;

  /// Callback when a drag ends on this card
  final Function(Offset position)? onDragEnd;

  /// Constructor
  const AnimalCard({
    super.key,
    required this.item,
    this.isConnected = false,
    this.isCorrect = false,
    this.onTap,
    this.onDragStart,
    this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.width < 600;
    final cardSize = isSmallScreen ? 100.0 : 120.0;

    return Draggable<String>(
      // Data is the item ID
      data: item.id,
      // Feedback is what's shown while dragging
      feedback: Material(
        elevation: 4.0,
        child: Container(
          width: cardSize,
          height: cardSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.blue, width: 3),
          ),
          child: Center(child: _getIconForItem(item.name)),
        ),
      ),
      // ChildWhenDragging is what's shown in the original position while dragging
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: Container(
          width: cardSize,
          height: cardSize,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300, width: 3),
          ),
          child: Center(child: _getIconForItem(item.name)),
        ),
      ),
      // Callback when drag starts
      onDragStarted: () {
        HapticFeedback.lightImpact();
        if (onDragStart != null) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final position =
              box.localToGlobal(Offset.zero) +
              Offset(box.size.width / 2, box.size.height / 2);
          onDragStart!(position);
        }
      },
      // Callback when drag ends
      onDragEnd: (details) {
        HapticFeedback.mediumImpact();
      },
      // Callback when drag is completed (dropped on a valid target)
      onDragCompleted: () {
        HapticFeedback.heavyImpact();
      },
      child: Container(
        width: cardSize,
        height: cardSize,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  isConnected
                      ? (isCorrect
                          ? const Color.fromRGBO(76, 175, 80, 0.5)
                          : const Color.fromRGBO(244, 67, 54, 0.5))
                      : const Color.fromRGBO(0, 0, 0, 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color:
                isConnected
                    ? (isCorrect ? Colors.green : Colors.red)
                    : Colors.grey.shade300,
            width: 3,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child:
              item.imagePath.endsWith('.txt')
                  ? Container(
                    color: Color(item.colorValue ?? 0xFF9C27B0),
                    child: Center(child: _getIconForItem(item.name)),
                  )
                  : Image.asset(item.imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }

  // Helper method to get an appropriate icon for each animal or fruit
  Widget _getIconForItem(String name) {
    // Map of item names to their corresponding icons/emojis
    final Map<String, IconData> animalIcons = {
      'Cat': Icons.pets,
      'Dog': Icons.pets,
      'Elephant': Icons.pets,
      'Lion': Icons.pets,
      'Monkey': Icons.pets,
      'Giraffe': Icons.pets,
      'Zebra': Icons.pets,
      'Cow': Icons.pets,
    };

    final Map<String, IconData> fruitIcons = {
      'Apple': Icons.apple,
      'Banana': Icons.lunch_dining,
      'Orange': Icons.circle,
      'Strawberry': Icons.spa,
      'Watermelon': Icons.circle,
      'Grapes': Icons.grain,
    };

    final Map<String, IconData> colorIcons = {
      'Red': Icons.circle,
      'Blue': Icons.circle,
      'Green': Icons.circle,
      'Yellow': Icons.circle,
      'Purple': Icons.circle,
      'Orange': Icons.circle,
    };

    // Check if we have a specific icon for this item
    IconData? icon = animalIcons[name] ?? fruitIcons[name] ?? colorIcons[name];

    // If no specific icon is found, use a generic one
    icon ??= Icons.image;

    // For colors, use a colored circle
    if (colorIcons.containsKey(name)) {
      Color color = Colors.grey;
      switch (name) {
        case 'Red':
          color = Colors.red;
          break;
        case 'Blue':
          color = Colors.blue;
          break;
        case 'Green':
          color = Colors.green;
          break;
        case 'Yellow':
          color = Colors.yellow;
          break;
        case 'Purple':
          color = Colors.purple;
          break;
        case 'Orange':
          color = Colors.orange;
          break;
      }

      return Icon(icon, size: 48, color: color);
    }

    // For animals, use emoji text instead of icons for better visuals
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

    String? emoji = animalEmojis[name] ?? fruitEmojis[name];

    if (emoji != null) {
      return Text(emoji, style: const TextStyle(fontSize: 48));
    }

    return Icon(icon, size: 48, color: Colors.white);
  }
}
