import '../models/restaurant_model.dart';
import '../models/promotional_banner_model.dart';
import '../services/hive_service.dart';

class HomeDataRepository {
  // Mock data for demonstration - in real app, this would come from API
  static final List<RestaurantModel> _mockRestaurants = [
    RestaurantModel(
      id: '1',
      name: 'BFC',
      cuisine: 'Burgers. American',
      imageUrl: 'assets/restaurent 1.png',
      rating: 4.5,
      deliveryTime: 10,
      tags: ['Burgers', 'American', 'Fast Food'],
    ),
    RestaurantModel(
      id: '2',
      name: 'The Shawarma Joint',
      cuisine: 'Rolls. Middle Eastern',
      imageUrl: 'assets/restaurent 2.png',
      rating: 2.9,
      deliveryTime: 35,
      tags: ['Rolls', 'Middle Eastern', 'Street Food'],
    ),
    RestaurantModel(
      id: '3',
      name: 'Pizza Palace',
      cuisine: 'Pizza. Italian',
      imageUrl: 'assets/restaurent 1.png',
      rating: 4.2,
      deliveryTime: 25,
      tags: ['Pizza', 'Italian', 'Fast Food'],
    ),
  ];

  static final List<PromotionalBannerModel> _mockBanners = [
    PromotionalBannerModel(
      id: '1',
      title: 'BURGER',
      subtitle: 'Super Delicious',
      description: "Today's Best Deal",
      imageUrl: 'assets/banner image.png',
      discountText: '50% OFF',
      buttonText: 'ORDER NOW',
      phoneNumber: '609-791-3583',
      website: 'WWW.YOURWEBSITE.COM',
    ),
    PromotionalBannerModel(
      id: '2',
      title: 'PIZZA',
      subtitle: 'Fresh & Hot',
      description: 'Limited Time Offer',
      imageUrl: 'assets/banner image.png',
      discountText: '30% OFF',
      buttonText: 'ORDER NOW',
      phoneNumber: '609-791-3583',
      website: 'WWW.YOURWEBSITE.COM',
    ),
    PromotionalBannerModel(
      id: '3',
      title: 'SHAWARMA',
      subtitle: 'Street Food',
      description: 'New Arrival',
      imageUrl: 'assets/banner image.png',
      discountText: '25% OFF',
      buttonText: 'ORDER NOW',
      phoneNumber: '609-791-3583',
      website: 'WWW.YOURWEBSITE.COM',
    ),
  ];

  // Get restaurants with caching
  static Future<List<RestaurantModel>> getRestaurants() async {
    // Check if we have cached data and it's not stale
    if (!HiveService.isHomeDataStale()) {
      final cachedData = HiveService.getLastSeenHomeData();
      if (cachedData != null) {
        final restaurants = (cachedData['restaurants'] as List<dynamic>)
            .map((r) => RestaurantModel.fromMap(r))
            .toList();
        return restaurants;
      }
    }

    // If no cache or stale, fetch fresh data
    final restaurants = await _fetchRestaurantsFromAPI();

    // Cache the fresh data
    await HiveService.cacheRestaurants(restaurants);
    await HiveService.cacheLastSeenHomeData(
      restaurants: restaurants,
      banners: _mockBanners,
      timestamp: DateTime.now(),
    );

    return restaurants;
  }

  // Get promotional banners with caching
  static Future<List<PromotionalBannerModel>> getBanners() async {
    // Check if we have cached data and it's not stale
    if (!HiveService.isHomeDataStale()) {
      final cachedData = HiveService.getLastSeenHomeData();
      if (cachedData != null) {
        final banners = (cachedData['banners'] as List<dynamic>)
            .map((b) => PromotionalBannerModel.fromMap(b))
            .toList();
        return banners;
      }
    }

    // If no cache or stale, return fresh data
    final banners = await _fetchBannersFromAPI();

    // Cache the fresh data
    await HiveService.cacheBanners(banners);

    // Get restaurants to cache together
    final restaurants = await getRestaurants();
    await HiveService.cacheLastSeenHomeData(
      restaurants: restaurants,
      banners: banners,
      timestamp: DateTime.now(),
    );

    return banners;
  }

  // Toggle restaurant favorite status
  static Future<void> toggleRestaurantFavorite(String restaurantId) async {
    final restaurants = HiveService.getCachedRestaurants();
    final restaurant = restaurants.firstWhere((r) => r.id == restaurantId);
    if (restaurant != null) {
      final updatedRestaurant = restaurant.copyWith(
        isFavorite: !restaurant.isFavorite,
      );
      await HiveService.updateRestaurantFavorite(
        restaurantId,
        updatedRestaurant.isFavorite,
      );
    }
  }

  // Search restaurants
  static Future<List<RestaurantModel>> searchRestaurants(String query) async {
    final restaurants = await getRestaurants();
    if (query.isEmpty) return restaurants;

    return restaurants.where((restaurant) {
      final searchQuery = query.toLowerCase();
      return restaurant.name.toLowerCase().contains(searchQuery) ||
          restaurant.cuisine.toLowerCase().contains(searchQuery) ||
          restaurant.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
    }).toList();
  }

  // Mock API calls - in real app, these would be actual API calls
  static Future<List<RestaurantModel>> _fetchRestaurantsFromAPI() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockRestaurants;
  }

  static Future<List<PromotionalBannerModel>> _fetchBannersFromAPI() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockBanners;
  }

  // Clear cache (useful for testing or when user logs out)
  static Future<void> clearCache() async {
    await HiveService.clearAllCache();
  }
}
