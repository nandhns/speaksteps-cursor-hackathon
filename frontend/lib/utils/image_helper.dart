/// Helper utility to map exercise items to image asset paths
class ImageHelper {
  /// Maps a category and item name to the corresponding image asset path
  /// 
  /// Example:
  /// - category: "animals", item: "dog" -> "images/animals_dog.png"
  /// - category: "body_parts", item: "hand" -> "images/body_parts_hand.png"
  static String? getImagePath(String? category, String? item) {
    if (category == null || item == null) return null;
    
    // Normalize category name
    final normalizedCategory = category.toLowerCase().replaceAll(' ', '_');
    // Normalize item name
    final normalizedItem = item.toLowerCase().replaceAll(' ', '_');
    
    // Map category names to image folder structure
    String categoryPrefix;
    switch (normalizedCategory) {
      case 'animal':
      case 'animals':
        categoryPrefix = 'animals';
        break;
      case 'body_part':
      case 'body_parts':
        categoryPrefix = 'body_parts';
        break;
      case 'clothing':
        categoryPrefix = 'clothing';
        break;
      case 'food':
        categoryPrefix = 'food';
        break;
      default:
        return null;
    }
    
    return 'images/${categoryPrefix}_$normalizedItem.png';
  }
  
  /// Gets image path directly from item name (tries to infer category)
  /// 
  /// This is a fallback when category is not available
  static String? getImagePathFromItem(String? item) {
    if (item == null) return null;
    
    final normalizedItem = item.toLowerCase().replaceAll(' ', '_');
    
    // Try each category
    final categories = ['animals', 'body_parts', 'clothing', 'food'];
    for (final category in categories) {
      final path = 'images/${category}_$normalizedItem.png';
      // In a real app, you'd check if the asset exists
      // For now, we'll return the first match based on common items
      if (_isLikelyCategory(category, normalizedItem)) {
        return path;
      }
    }
    
    // Default to animals if unsure
    return 'images/animals_$normalizedItem.png';
  }
  
  /// Checks if an item is likely in a specific category
  static bool _isLikelyCategory(String category, String item) {
    final categoryItems = {
      'animals': ['dog', 'cat', 'bird', 'fish', 'horse', 'cow', 'pig', 'duck', 'frog', 'lion'],
      'body_parts': ['hand', 'foot', 'arm', 'leg', 'head', 'eye', 'ear', 'nose', 'mouth', 'knee'],
      'clothing': ['shirt', 'pants', 'dress', 'shoe', 'hat', 'sock', 'jacket', 'coat', 'glove', 'belt'],
      'food': ['apple', 'bread', 'milk', 'egg', 'rice', 'cheese', 'banana', 'orange', 'carrot', 'cake'],
    };
    
    return categoryItems[category]?.contains(item) ?? false;
  }
  
  /// Gets image path from exercise category enum
  static String? getImagePathFromCategory(dynamic category, String? item) {
    if (item == null) return null;
    
    String categoryName;
    if (category is Enum) {
      categoryName = category.name;
    } else if (category is String) {
      categoryName = category;
    } else {
      return getImagePathFromItem(item);
    }
    
    return getImagePath(categoryName, item);
  }
}

