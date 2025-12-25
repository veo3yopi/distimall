import 'package:flutter/foundation.dart';

import '../data/models/banner_item.dart';
import '../data/repositories/banner_repository.dart';

class BannerProvider extends ChangeNotifier {
  BannerProvider({required BannerRepository repository})
      : _repository = repository,
        _banners = BannerRepository.dummyBanners;

  final BannerRepository _repository;
  List<BannerItem> _banners;
  bool _isLoading = false;
  String? _errorMessage;

  List<BannerItem> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadBanners() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await _repository.fetchBanners();
      _banners = results.isNotEmpty ? results : BannerRepository.dummyBanners;
      _errorMessage = null;
    } catch (error) {
      _banners = BannerRepository.dummyBanners;
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
