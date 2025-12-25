import 'package:flutter/foundation.dart';

import '../data/models/product_item.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({required ProductRepository repository})
      : _repository = repository,
        _products = ProductRepository.dummyFeaturedProducts,
        _featuredProducts = ProductRepository.dummyFeaturedProducts;

  final ProductRepository _repository;
  List<ProductItem> _products;
  List<ProductItem> _featuredProducts;
  bool _isLoading = false;
  String? _errorMessage;
  int? _categoryId;

  List<ProductItem> get products => _products;
  List<ProductItem> get featuredProducts => _featuredProducts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int? get categoryId => _categoryId;

  Future<void> loadProducts() async {
    _isLoading = true;
    _categoryId = null;
    notifyListeners();
    try {
      final results = await _repository.fetchProducts();
      final featured = results.where((item) => item.isFeatured == true).toList();
      _products =
          results.isNotEmpty ? results : ProductRepository.dummyFeaturedProducts;
      _featuredProducts = featured.isNotEmpty
          ? featured
          : ProductRepository.dummyFeaturedProducts;
      _errorMessage = null;
    } catch (error) {
      _products = ProductRepository.dummyFeaturedProducts;
      _featuredProducts = ProductRepository.dummyFeaturedProducts;
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchProducts(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      await loadProducts();
      return;
    }
    _isLoading = true;
    _categoryId = null;
    notifyListeners();
    try {
      final results = await _repository.searchProducts(trimmed);
      _products = results;
      _errorMessage = null;
    } catch (error) {
      _products = ProductRepository.dummyFeaturedProducts;
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByCategoryId(int? categoryId) async {
    if (categoryId == null) {
      await loadProducts();
      return;
    }
    _isLoading = true;
    _categoryId = categoryId;
    notifyListeners();
    try {
      final results = await _repository.fetchByCategoryId(categoryId);
      _products = results;
      _errorMessage = null;
    } catch (error) {
      _products = ProductRepository.dummyFeaturedProducts;
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
