/// A class representing an item in a matching game
class MatchingItem {
  /// Unique identifier for the item
  final String id;

  /// The display name of the item
  final String name;

  /// The asset path to the image
  final String imagePath;

  /// The color associated with this item (optional)
  final int? colorValue;

  /// Constructor
  const MatchingItem({
    required this.id,
    required this.name,
    required this.imagePath,
    this.colorValue,
  });

  /// Create a copy of this item with the given fields replaced with the new values
  MatchingItem copyWith({
    String? id,
    String? name,
    String? imagePath,
    int? colorValue,
  }) {
    return MatchingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      imagePath: imagePath ?? this.imagePath,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}
