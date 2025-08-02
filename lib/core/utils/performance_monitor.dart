import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Performance monitoring utilities for tracking app performance
/// Helps identify bottlenecks and optimize user experience
class PerformanceMonitor {
  static const String _tag = 'PerformanceMonitor';
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _measurements = {};

  /// Track widget build performance
  static void trackWidgetBuild(String widgetName, VoidCallback buildFunction) {
    if (!kDebugMode) {
      buildFunction();
      return;
    }

    final stopwatch = Stopwatch()..start();
    buildFunction();
    stopwatch.stop();

    final duration = stopwatch.elapsed;
    _recordMeasurement('widget_build_$widgetName', duration);

    if (duration.inMilliseconds > 16) {
      // Frame budget exceeded (60fps = 16.67ms per frame)
      developer.log(
        'Widget build took ${duration.inMilliseconds}ms (>16ms frame budget)',
        name: _tag,
        level: 900, // Warning level
      );
    }
  }

  /// Track API call performance
  static void trackApiCall(String endpoint, Duration duration) {
    if (!kDebugMode) return;

    _recordMeasurement('api_call_$endpoint', duration);

    developer.log(
      'API call to $endpoint took ${duration.inMilliseconds}ms',
      name: _tag,
    );

    if (duration.inSeconds > 5) {
      developer.log(
        'Slow API call detected: $endpoint (${duration.inSeconds}s)',
        name: _tag,
        level: 900, // Warning level
      );
    }
  }

  /// Start timing an operation
  static void startTiming(String operationName) {
    if (!kDebugMode) return;
    _startTimes[operationName] = DateTime.now();
  }

  /// End timing an operation and log the result
  static void endTiming(String operationName) {
    if (!kDebugMode) return;

    final startTime = _startTimes[operationName];
    if (startTime == null) {
      developer.log(
        'No start time found for operation: $operationName',
        name: _tag,
        level: 1000, // Error level
      );
      return;
    }

    final duration = DateTime.now().difference(startTime);
    _startTimes.remove(operationName);
    _recordMeasurement(operationName, duration);

    developer.log(
      'Operation $operationName completed in ${duration.inMilliseconds}ms',
      name: _tag,
    );
  }

  /// Track memory usage (simplified)
  static void trackMemoryUsage(String context) {
    if (!kDebugMode) return;

    // Note: Actual memory tracking would require platform-specific implementation
    developer.log('Memory checkpoint: $context', name: _tag);
  }

  /// Record a measurement for an operation
  static void _recordMeasurement(String operationName, Duration duration) {
    _measurements.putIfAbsent(operationName, () => <Duration>[]);
    _measurements[operationName]!.add(duration);

    // Keep only last 100 measurements to prevent memory leaks
    if (_measurements[operationName]!.length > 100) {
      _measurements[operationName]!.removeAt(0);
    }
  }
}

/// Extension to easily wrap functions with performance tracking
extension PerformanceTrackingExtension<T> on T Function() {
  /// Execute function with performance tracking
  T trackPerformance(String operationName) {
    PerformanceMonitor.startTiming(operationName);
    try {
      return this();
    } finally {
      PerformanceMonitor.endTiming(operationName);
    }
  }
}

/// Extension for async functions
extension AsyncPerformanceTrackingExtension<T> on Future<T> Function() {
  /// Execute async function with performance tracking
  Future<T> trackPerformance(String operationName) async {
    PerformanceMonitor.startTiming(operationName);
    try {
      return await this();
    } finally {
      PerformanceMonitor.endTiming(operationName);
    }
  }
}
