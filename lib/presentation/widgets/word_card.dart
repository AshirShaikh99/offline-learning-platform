import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/matching_item.dart';

/// A widget that displays a word card with text
class WordCard extends StatelessWidget {
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
  const WordCard({
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
    final cardWidth = isSmallScreen ? 120.0 : 150.0;
    final cardHeight = isSmallScreen ? 60.0 : 80.0;

    return DragTarget<String>(
      // Called when a draggable is dropped and accepted
      onAcceptWithDetails: (details) {
        HapticFeedback.heavyImpact();
        if (onDragEnd != null) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final position =
              box.localToGlobal(Offset.zero) +
              Offset(box.size.width / 2, box.size.height / 2);
          // Pass the dragged item ID to the callback
          onDragEnd!(position);
        }
      },
      // Called to determine whether this target will accept the draggable
      onWillAcceptWithDetails: (details) {
        // Accept all draggables
        return true;
      },
      // Called when a draggable enters the target
      onMove: (details) {
        HapticFeedback.selectionClick();
      },
      // Builder for the target
      builder: (context, candidateData, rejectedData) {
        // Change the appearance when a draggable is hovering over this target
        final isHovering = candidateData.isNotEmpty;
        return Container(
          width: cardWidth,
          height: cardHeight,
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isHovering ? Colors.blue.shade50 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color:
                    isHovering
                        ? Colors.blue.shade200
                        : (isConnected
                            ? (isCorrect
                                ? const Color.fromRGBO(76, 175, 80, 0.5)
                                : const Color.fromRGBO(244, 67, 54, 0.5))
                            : const Color.fromRGBO(0, 0, 0, 0.1)),
                blurRadius: isHovering ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color:
                  isHovering
                      ? Colors.blue
                      : (isConnected
                          ? (isCorrect ? Colors.green : Colors.red)
                          : Colors.grey.shade300),
              width: isHovering ? 4 : 3,
            ),
          ),
          child: Center(
            child: Text(
              item.name,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }
}
