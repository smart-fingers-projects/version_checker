import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/version_check_request.dart';
import '../models/version_check_response.dart';
import '../models/version_checker_config.dart';
import '../utils/version_comparator.dart';

/// Service class for handling version checking operations.
class VersionCheckerService {
  final VersionCheckerConfig config;
  final http.Client? _httpClient;

  VersionCheckerService(this.config, {http.Client? httpClient})
    : _httpClient = httpClient;

  /// Check for app updates.
  ///
  /// This method:
  /// - Optionally returns a cached response when caching is enabled.
  /// - Otherwise calls the configured API endpoint (or
  ///   [VersionCheckerConfig.versionSource] if provided).
  /// - Caches successful responses when enabled.
  /// - Falls back to any cached response (even if expired) when an error
  ///   occurs (useful for fully offline environments).
  Future<VersionCheckResponse> checkForUpdates({
    required String currentVersion,
    required String platform,
    String? buildNumber,
    String? locale,
  }) async {
    try {
      // 1. Try fresh cache first if enabled.
      if (config.enableCaching) {
        final cachedResponse = await _getCachedResponse(
          currentVersion,
          platform,
          buildNumber,
          locale,
        );
        if (cachedResponse != null) {
          return cachedResponse;
        }
      }

      // 2. Build request.
      final request = VersionCheckRequest(
        platform: platform,
        currentVersion: currentVersion,
        buildNumber: config.includeBuildNumber ? buildNumber : null,
        locale: locale ?? config.locale,
      );

      // 3. Call API or custom version source.
      final response = await _makeApiCall(request);

      // 4. Cache successful responses for future offline use.
      if (config.enableCaching && response.success) {
        await _cacheResponse(
          response,
          currentVersion,
          platform,
          buildNumber,
          locale,
        );
      }

      return response;
    } catch (e) {
      // 5. On any error (e.g., offline), try to return ANY cached response
      //    even if it is older than the configured cache duration.
      if (config.enableCaching) {
        final cachedResponse = await _getCachedResponse(
          currentVersion,
          platform,
          buildNumber,
          locale,
          ignoreAge: true,
        );
        if (cachedResponse != null) {
          return cachedResponse;
        }
      }

      // 6. If no cache is available, return an error response.
      return VersionCheckResponse(
        success: false,
        currentVersion: currentVersion,
        platform: platform,
        updateAvailable: false,
        forceUpdate: false,
        error: e.toString(),
      );
    }
  }

  /// Make API call to fetch version information.
  ///
  /// If [config.versionSource] is non-null, it will be used instead of
  /// performing an HTTP request. This enables fully offline usage.
  Future<VersionCheckResponse> _makeApiCall(VersionCheckRequest request) async {
    // Use custom version source if provided (e.g., offline manifest).
    if (config.versionSource != null) {
      return config.versionSource!(request);
    }

    final uri = Uri.parse(config.apiUrl);
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (config.userAgent != null) 'User-Agent': config.userAgent!,
      ...?config.customHeaders,
    };

    final client = _httpClient ?? http.Client();

    final response = await client
        .post(uri, headers: headers, body: jsonEncode(request.toJson()))
        .timeout(Duration(seconds: config.timeoutSeconds));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      return VersionCheckResponse.fromJson(jsonData);
    } else {
      throw HttpException(
        'API request failed with status ${response.statusCode}: ${response.body}',
      );
    }
  }

  /// Get cached response if available.
  ///
  /// By default this only returns a response if it is still "fresh" according
  /// to [VersionCheckerConfig.cacheDurationMinutes]. When [ignoreAge] is true
  /// the response will be returned regardless of how old it is (this is used
  /// as a best-effort offline fallback).
  Future<VersionCheckResponse?> _getCachedResponse(
    String currentVersion,
    String platform,
    String? buildNumber,
    String? locale, {
    bool ignoreAge = false,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(
        currentVersion,
        platform,
        buildNumber,
        locale,
      );

      final cachedData = prefs.getString(cacheKey);
      final cacheTime = prefs.getInt('${cacheKey}_time');

      if (cachedData != null && cacheTime != null) {
        // When ignoring age (offline fallback), just use whatever is stored.
        if (ignoreAge) {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          return VersionCheckResponse.fromJson(jsonData);
        }

        final now = DateTime.now().millisecondsSinceEpoch;
        final cacheAge = now - cacheTime;
        final maxAge = config.cacheDurationMinutes * 60 * 1000; // minutes -> ms

        if (cacheAge < maxAge) {
          final jsonData = jsonDecode(cachedData) as Map<String, dynamic>;
          return VersionCheckResponse.fromJson(jsonData);
        } else {
          // Remove expired cache when not used as fallback.
          await prefs.remove(cacheKey);
          await prefs.remove('${cacheKey}_time');
        }
      }
    } catch (_) {
      // Ignore cache errors and proceed with API call or error handling.
    }

    return null;
  }

  /// Cache response for future use.
  Future<void> _cacheResponse(
    VersionCheckResponse response,
    String currentVersion,
    String platform,
    String? buildNumber,
    String? locale,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(
        currentVersion,
        platform,
        buildNumber,
        locale,
      );

      await prefs.setString(cacheKey, jsonEncode(response.toJson()));
      await prefs.setInt(
        '${cacheKey}_time',
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // Ignore cache errors.
    }
  }

  /// Build cache key for a given request.
  String _getCacheKey(
    String currentVersion,
    String platform,
    String? buildNumber,
    String? locale,
  ) {
    return 'version_check_${platform}_${currentVersion}_${buildNumber ?? ''}_${locale ?? ''}';
  }

  /// Clear all cached responses.
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (key) => key.startsWith('version_check_'),
      );

      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (_) {
      // Ignore cache errors.
    }
  }

  /// Check if update is available by comparing versions.
  bool isUpdateAvailable(String currentVersion, String? latestVersion) {
    if (latestVersion == null) return false;
    return VersionComparator.isUpdateAvailable(currentVersion, latestVersion);
  }
}
