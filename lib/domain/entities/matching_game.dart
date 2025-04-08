import 'matching_item.dart';

/// A class representing a matching game
class MatchingGame {
  /// The title of the game
  final String title;

  /// The theme color of the game
  final int colorValue;

  /// The list of items to match
  final List<MatchingItem> items;

  /// Constructor
  const MatchingGame({
    required this.title,
    required this.colorValue,
    required this.items,
  });

  /// Create a copy of this game with the given fields replaced with the new values
  MatchingGame copyWith({
    String? title,
    int? colorValue,
    List<MatchingItem>? items,
  }) {
    return MatchingGame(
      title: title ?? this.title,
      colorValue: colorValue ?? this.colorValue,
      items: items ?? this.items,
    );
  }
}
