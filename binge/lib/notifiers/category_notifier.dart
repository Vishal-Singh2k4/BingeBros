import 'package:flutter/material.dart';

class CategoryNotifier extends ChangeNotifier {
  // Default category
  String _selectedCategory = 'Anime';

  // Getter for the selected category
  String get selectedCategory => _selectedCategory;

  // Method to update the selected category and notify listeners
  void setCategory(String category) {
    if (_selectedCategory != category) {
      _selectedCategory = category;
      notifyListeners();
    }
  }
}
