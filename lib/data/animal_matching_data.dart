import '../domain/entities/matching_game.dart';
import '../domain/entities/matching_item.dart';

/// A class that provides data for animal matching games
class AnimalMatchingData {
  /// Get the animal matching game
  static MatchingGame getAnimalMatchingGame() {
    // Create a list of animal names
    final animalNames = [
      'Cat',
      'Dog',
      'Elephant',
      'Lion',
      'Monkey',
      'Giraffe',
      'Zebra',
      'Cow',
    ];

    // Create a list of items
    final items =
        animalNames.map((name) {
          final id = name.toLowerCase();
          return MatchingItem(
            id: id,
            name: name,
            // Use a placeholder image path - in a real app, you would use actual image paths
            imagePath: 'assets/images/animals/placeholder.txt',
          );
        }).toList();

    return MatchingGame(
      title: 'Match the Animals',
      colorValue: 0xFF9C27B0, // Purple
      items: items,
    );
  }

  /// Get the fruit matching game
  static MatchingGame getFruitMatchingGame() {
    // Create a list of fruit names
    final fruitNames = [
      'Apple',
      'Banana',
      'Orange',
      'Strawberry',
      'Watermelon',
      'Grapes',
    ];

    // Create a list of items
    final items =
        fruitNames.map((name) {
          final id = name.toLowerCase();
          return MatchingItem(
            id: id,
            name: name,
            // Use a placeholder image path - in a real app, you would use actual image paths
            imagePath: 'assets/images/fruits/placeholder.txt',
          );
        }).toList();

    return MatchingGame(
      title: 'Match the Fruits',
      colorValue: 0xFFFF9800, // Orange
      items: items,
    );
  }

  /// Get the color matching game
  static MatchingGame getColorMatchingGame() {
    // Create a map of color names to color values
    final colorMap = {
      'Red': 0xFFFF0000,
      'Blue': 0xFF0000FF,
      'Green': 0xFF00FF00,
      'Yellow': 0xFFFFFF00,
      'Purple': 0xFF800080,
      'Orange': 0xFFFFA500,
    };

    // Create a list of items
    final items =
        colorMap.entries.map((entry) {
          final name = entry.key;
          final colorValue = entry.value;
          final id = name.toLowerCase();
          return MatchingItem(
            id: id,
            name: name,
            // Use a placeholder image path - in a real app, you would use actual image paths
            imagePath: 'assets/images/colors/placeholder.txt',
            colorValue: colorValue,
          );
        }).toList();

    return MatchingGame(
      title: 'Match the Colors',
      colorValue: 0xFF2196F3, // Blue
      items: items,
    );
  }
}
