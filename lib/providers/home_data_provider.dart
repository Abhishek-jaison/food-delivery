import 'package:flutter/material.dart';
import '../models/restaurant_model.dart';
import '../models/promotional_banner_model.dart';
import '../repositories/home_data_repository.dart';

class HomeDataProvider extends ChangeNotifier {
  List<RestaurantModel> _restaurants = [];
  List<PromotionalBannerModel> _banners = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  int _currentBannerIndex = 0;

  // Getters
  List<RestaurantModel> get restaurants => _restaurants;
  List<PromotionalBannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  int get currentBannerIndex => _currentBannerIndex;

  // Filtered restaurants based on search
  List<RestaurantModel> get filteredRestaurants {
    if (_searchQuery.isEmpty) return _restaurants;
    return _restaurants.where((restaurant) {
      final query = _searchQuery.toLowerCase();
      return restaurant.name.toLowerCase().contains(query) ||
          restaurant.cuisine.toLowerCase().contains(query) ||
          restaurant.tags.any((tag) => tag.toLowerCase().contains(query));
    }).toList();
  }

  // Initialize data
  Future<void> initializeData() async {
    _setLoading(true);
    _clearError();

    try {
      // Load data in parallel for better performance
      final futures = await Future.wait([
        HomeDataRepository.getRestaurants(),
        HomeDataRepository.getBanners(),
      ]);

      _restaurants = futures[0] as List<RestaurantModel>;
      _banners = futures[1] as List<PromotionalBannerModel>;

      _setLoading(false);
    } catch (e) {
      _setError('Failed to load data: $e');
      _setLoading(false);
    }
  }

  // Refresh data
  Future<void> refreshData() async {
    await initializeData();
  }

  // Update search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Clear search
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  // Update banner index
  void updateBannerIndex(int index) {
    _currentBannerIndex = index;
    notifyListeners();
  }

  // Toggle restaurant favorite
  Future<void> toggleRestaurantFavorite(String restaurantId) async {
    try {
      await HomeDataRepository.toggleRestaurantFavorite(restaurantId);

      // Update local state
      final index = _restaurants.indexWhere((r) => r.id == restaurantId);
      if (index != -1) {
        final restaurant = _restaurants[index];
        _restaurants[index] = restaurant.copyWith(
          isFavorite: !restaurant.isFavorite,
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update favorite: $e');
    }
  }

  // Search restaurants
  Future<void> searchRestaurants(String query) async {
    _setLoading(true);
    _clearError();

    try {
      _searchQuery = query;
      final results = await HomeDataRepository.searchRestaurants(query);
      _restaurants = results;
      _setLoading(false);
    } catch (e) {
      _setError('Search failed: $e');
      _setLoading(false);
    }
  }

  // Clear error
  void clearError() {
    _clearError();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Dispose
  @override
  void dispose() {
    super.dispose();
  }
}
