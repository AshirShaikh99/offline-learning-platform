import 'dart:ui';

/// A class representing a connection between two items in a matching game
class MatchConnection {
  /// The ID of the source item
  final String sourceId;

  /// The ID of the target item
  final String targetId;

  /// Whether the connection is correct
  final bool isCorrect;

  /// The start point of the connection line
  final Offset startPoint;

  /// The end point of the connection line
  final Offset endPoint;

  /// Constructor
  const MatchConnection({
    required this.sourceId,
    required this.targetId,
    required this.isCorrect,
    required this.startPoint,
    required this.endPoint,
  });

  /// Create a copy of this connection with the given fields replaced with the new values
  MatchConnection copyWith({
    String? sourceId,
    String? targetId,
    bool? isCorrect,
    Offset? startPoint,
    Offset? endPoint,
  }) {
    return MatchConnection(
      sourceId: sourceId ?? this.sourceId,
      targetId: targetId ?? this.targetId,
      isCorrect: isCorrect ?? this.isCorrect,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
    );
  }
}
