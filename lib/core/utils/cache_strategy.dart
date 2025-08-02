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
  static bool isCacheValid(String key, Duration maxAge) {
    final timestampKey = key + _timestampSuffix;
    final prefs = _getPrefsSync();
    if (prefs == null) return false;

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
    if (!isCacheValid(key, maxAge)) {
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

  /// Get cached list data if valid, null otherwise
  static Future<List<T>?> getCachedListData<T>(
    String key,
    Duration maxAge,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    if (!isCacheValid(key, maxAge)) {
      return null;
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return null;

    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      return jsonList
          .map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Invalid JSON, remove corrupted cache
      await clearCacheEntry(key);
      return null;
    }
  }

  /// Cache data with timestamp
  static Future<void> cacheData<T>(
    String key,
    T data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(toJson(data));
    final timestamp = DateTime.now().toIso8601String();

    await Future.wait([
      prefs.setString(key, jsonString),
      prefs.setString(key + _timestampSuffix, timestamp),
    ]);
  }

  /// Cache list data with timestamp
  static Future<void> cacheListData<T>(
    String key,
    List<T> data,
    Map<String, dynamic> Function(T) toJson,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = data.map(toJson).toList();
    final jsonString = json.encode(jsonList);
    final timestamp = DateTime.now().toIso8601String();

    await Future.wait([
      prefs.setString(key, jsonString),
      prefs.setString(key + _timestampSuffix, timestamp),
    ]);
  }

  /// Clear specific cache entry
  static Future<void> clearCacheEntry(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.remove(key),
      prefs.remove(key + _timestampSuffix),
    ]);
  }

  /// Clear all cache entries with a specific prefix
  static Future<void> clearCacheByPrefix(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(prefix));
    
    final futures = keys.map((key) => prefs.remove(key)).toList();
    await Future.wait(futures);
  }

  /// Clear all product cache
  static Future<void> clearProductCache() async {
    await clearCacheByPrefix(_productPrefix);
  }

  /// Clear all category cache
  static Future<void> clearCategoryCache() async {
    await clearCacheByPrefix(_categoryPrefix);
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Get cache size information
  static Future<Map<String, int>> getCacheInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    
    int productCacheCount = 0;
    int categoryCacheCount = 0;
    int otherCacheCount = 0;
    
    for (final key in allKeys) {
      if (key.startsWith(_productPrefix)) {
        productCacheCount++;
      } else if (key.startsWith(_categoryPrefix)) {
        categoryCacheCount++;
      } else {
        otherCacheCount++;
      }
    }
    
    return {
      'total': allKeys.length,
      'products': productCacheCount,
      'categories': categoryCacheCount,
      'others': otherCacheCount,
    };
  }

  /// Clean expired cache entries
  static Future<int> cleanExpiredCache() async {
    final prefs = await SharedPreferences.getInstance();
    final allKeys = prefs.getKeys();
    final timestampKeys = allKeys.where((key) => key.endsWith(_timestampSuffix));
    
    int cleanedCount = 0;
    final now = DateTime.now();
    
    for (final timestampKey in timestampKeys) {
      final timestampString = prefs.getString(timestampKey);
      if (timestampString == null) continue;
      
      final timestamp = DateTime.tryParse(timestampString);
      if (timestamp == null) {
        // Invalid timestamp, remove entry
        final dataKey = timestampKey.replaceAll(_timestampSuffix, '');
        await Future.wait([
          prefs.remove(dataKey),
          prefs.remove(timestampKey),
        ]);
        cleanedCount++;
        continue;
      }
      
      // Check if cache is older than very long term (7 days)
      final age = now.difference(timestamp);
      if (age > veryLongTerm) {
        final dataKey = timestampKey.replaceAll(_timestampSuffix, '');
        await Future.wait([
          prefs.remove(dataKey),
          prefs.remove(timestampKey),
        ]);
        cleanedCount++;
      }
    }
    
    return cleanedCount;
  }

  /// Generate cache key for products
  static String productCacheKey(String suffix) => _productPrefix + suffix;

  /// Generate cache key for categories
  static String categoryCacheKey(String suffix) => _categoryPrefix + suffix;

  /// Get SharedPreferences synchronously (for validation checks)
  static SharedPreferences? _getPrefsSync() {
    // Note: This is a simplified approach. In a real app, you might want to
    // maintain a singleton instance of SharedPreferences
    return null; // Would need platform-specific implementation
  }
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
  bool isValidCache(CacheType cacheType) {
    return CacheStrategy.isCacheValid(this, cacheType.duration);
  }
  
  /// Clear this specific cache entry
  Future<void> clearCache() {
    return CacheStrategy.clearCacheEntry(this);
  }
}