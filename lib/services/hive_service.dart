import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/restaurant_model.dart';
import '../models/promotional_banner_model.dart';

class HiveService {
  static const String _userBoxName = 'userBox';
  static const String _restaurantsBoxName = 'restaurantsBox';
  static const String _bannersBoxName = 'bannersBox';
  static const String _lastSeenHomeDataBoxName = 'lastSeenHomeDataBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(RestaurantModelAdapter());
    Hive.registerAdapter(PromotionalBannerModelAdapter());

    // Open boxes
    await Hive.openBox<UserModel>(_userBoxName);
    await Hive.openBox<RestaurantModel>(_restaurantsBoxName);
    await Hive.openBox<PromotionalBannerModel>(_bannersBoxName);
    await Hive.openBox(_lastSeenHomeDataBoxName);
  }

  // User caching
  static Future<void> cacheUser(UserModel user) async {
    final box = Hive.box<UserModel>(_userBoxName);
    await box.put(user.uid, user);
  }

  static UserModel? getCachedUser(String uid) {
    final box = Hive.box<UserModel>(_userBoxName);
    return box.get(uid);
  }

  static Future<void> clearUserCache() async {
    final box = Hive.box<UserModel>(_userBoxName);
    await box.clear();
  }

  // Restaurants caching
  static Future<void> cacheRestaurants(
    List<RestaurantModel> restaurants,
  ) async {
    final box = Hive.box<RestaurantModel>(_restaurantsBoxName);
    await box.clear();
    for (final restaurant in restaurants) {
      await box.put(restaurant.id, restaurant);
    }
  }

  static List<RestaurantModel> getCachedRestaurants() {
    final box = Hive.box<RestaurantModel>(_restaurantsBoxName);
    return box.values.toList();
  }

  static Future<void> updateRestaurantFavorite(
    String restaurantId,
    bool isFavorite,
  ) async {
    final box = Hive.box<RestaurantModel>(_restaurantsBoxName);
    final restaurant = box.get(restaurantId);
    if (restaurant != null) {
      final updatedRestaurant = restaurant.copyWith(isFavorite: isFavorite);
      await box.put(restaurantId, updatedRestaurant);
    }
  }

  // Promotional banners caching
  static Future<void> cacheBanners(List<PromotionalBannerModel> banners) async {
    final box = Hive.box<PromotionalBannerModel>(_bannersBoxName);
    await box.clear();
    for (final banner in banners) {
      await box.put(banner.id, banner);
    }
  }

  static List<PromotionalBannerModel> getCachedBanners() {
    final box = Hive.box<PromotionalBannerModel>(_bannersBoxName);
    return box.values.toList();
  }

  // Last seen home data caching
  static Future<void> cacheLastSeenHomeData({
    required List<RestaurantModel> restaurants,
    required List<PromotionalBannerModel> banners,
    required DateTime timestamp,
  }) async {
    final box = Hive.box(_lastSeenHomeDataBoxName);
    await box.put('restaurants', restaurants.map((r) => r.toMap()).toList());
    await box.put('banners', banners.map((b) => b.toMap()).toList());
    await box.put('timestamp', timestamp.millisecondsSinceEpoch);
  }

  static Map<String, dynamic>? getLastSeenHomeData() {
    final box = Hive.box(_lastSeenHomeDataBoxName);
    final restaurants = box.get('restaurants') as List<dynamic>?;
    final banners = box.get('banners') as List<dynamic>?;
    final timestamp = box.get('timestamp') as int?;

    if (restaurants != null && banners != null && timestamp != null) {
      return {
        'restaurants': restaurants,
        'banners': banners,
        'timestamp': timestamp,
      };
    }
    return null;
  }

  static bool isHomeDataStale() {
    final box = Hive.box(_lastSeenHomeDataBoxName);
    final timestamp = box.get('timestamp') as int?;
    if (timestamp == null) return true;

    final lastSeen = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final difference = now.difference(lastSeen);

    // Consider data stale after 1 hour
    return difference.inHours >= 1;
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    await clearUserCache();
    final restaurantsBox = Hive.box<RestaurantModel>(_restaurantsBoxName);
    final bannersBox = Hive.box<PromotionalBannerModel>(_bannersBoxName);
    final homeDataBox = Hive.box(_lastSeenHomeDataBoxName);

    await restaurantsBox.clear();
    await bannersBox.clear();
    await homeDataBox.clear();
  }

  // Close all boxes
  static Future<void> closeAllBoxes() async {
    await Hive.close();
  }
}
