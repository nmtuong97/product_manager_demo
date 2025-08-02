import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache strategies and utilities for efficient data caching
/// Provides different caching durations and strategies based on data type
class CacheStrategy {
  // Cache duration constants
  static const Duration shortTerm = Duration(minutes: 5);
  static const Duration mediumTerm = Duration(hours: 1);
  static const Duration longTerm = Duration(days: 1);
  static const Duration veryLongTerm = Duration(days: 7);

  // Cache key prefixes
  static const String _productPrefix = 'cache_product_';
  static const String _categoryPrefix = 'cache_category_';
  static const String _timestampSuffix = '_timestamp';

  /// Check if cached data is still valid
  static Future<bool> isCacheValid(String key, Duration maxAge) async {
    final timestampKey = key + _timestampSuffix;
    final prefs = await SharedPreferences.getInstance();

    final timestampString = prefs.getString(timestampKey);
    if (timestampString == null) return false;

    final timestamp = DateTime.tryParse(timestampString);
    if (timestamp == null) return false;

    final age = DateTime.now().difference(timestamp);
    return age <= maxAge;
  }

  /// Get cached data if valid, null otherwise
  static Future<T?> getCachedData<T>(
    String key,
    Duration maxAge,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (!await isCacheValid(key, maxAge)) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    try {
      final jsonMap = json.decode(jsonString) as Map<String, dynamic>;
      return fromJson(jsonMap);
    } catch (e) {
      // Invalid JSON, remove corrupted cache
      await clearCacheEntry(key);
      return null;
    }
  }

  /// Clear specific cache entry
  static Future<void> clearCacheEntry(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(key),
      prefs.remove(key + _timestampSuffix),
    ]);
  }

  /// Generate cache key for products
  static String productCacheKey(String suffix) => _productPrefix + suffix;

  /// Generate cache key for categories
  static String categoryCacheKey(String suffix) => _categoryPrefix + suffix;
}

/// Cache strategy types for different data
enum CacheType {
  /// Short-lived data (5 minutes) - real-time data
  shortTerm(CacheStrategy.shortTerm),

  /// Medium-lived data (1 hour) - frequently changing data
  mediumTerm(CacheStrategy.mediumTerm),

  /// Long-lived data (1 day) - stable data
  longTerm(CacheStrategy.longTerm),

  /// Very long-lived data (7 days) - rarely changing data
  veryLongTerm(CacheStrategy.veryLongTerm);

  const CacheType(this.duration);
  final Duration duration;
}

/// Extension to easily apply cache strategies
extension CacheStrategyExtension on String {
  /// Check if this cache key is valid for the given cache type
  Future<bool> isValidCache(CacheType cacheType) {
    return CacheStrategy.isCacheValid(this, cacheType.duration);
  }

  /// Clear this specific cache entry
  Future<void> clearCache() {
    return CacheStrategy.clearCacheEntry(this);
  }
}
