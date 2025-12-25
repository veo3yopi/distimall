import 'package:flutter/foundation.dart';

import '../data/models/category_item.dart';
import '../data/repositories/category_repository.dart';

class CategoryProvider extends ChangeNotifier {
  CategoryProvider({required CategoryRepository repository})
      : _repository = repository,
        _categories = CategoryRepository.dummyCategories;

  final CategoryRepository _repository;
  List<CategoryItem> _categories;
  bool _isLoading = false;
  String? _errorMessage;

  List<CategoryItem> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await _repository.fetchCategories();
      _categories =
          results.isNotEmpty ? results : CategoryRepository.dummyCategories;
      _errorMessage = null;
    } catch (error) {
      _categories = CategoryRepository.dummyCategories;
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
