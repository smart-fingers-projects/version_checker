import 'dialog_config.dart';

/// Configuration class for the version checker plugin.
///
/// The [VersionCheckerConfig] class provides comprehensive configuration
/// options for the version checking functionality, including API settings,
/// caching behavior, dialog configurations, and request customization.
///
/// This class allows you to configure:
/// - API endpoint and request settings
/// - Caching behavior and duration
/// - Dialog appearance and behavior
/// - Localization and internationalization
/// - Custom headers and user agent
///
/// Basic usage:
/// ```dart
/// final config = VersionCheckerConfig(
///   apiUrl: 'https://your-api.com/version/check',
/// );
/// ```
///
/// Advanced usage with custom settings:
/// ```dart
/// final config = VersionCheckerConfig(
///   apiUrl: 'https://your-api.com/version/check',
///   timeoutSeconds: 30,
///   enableCaching: true,
///   cacheDurationMinutes: 60,
///   locale: 'en',
///   showDialogs: true,
///   customHeaders: {
///     'Authorization': 'Bearer your-token',
///     'X-App-Version': '1.0.0',
///   },
///   userAgent: 'YourApp/1.0.0',
///   includeBuildNumber: true,
///   updateDialogConfig: DialogConfig(
///     title: 'Update Available',
///     positiveButtonText: 'Update Now',
///   ),
/// );
/// ```
///
/// Pre-configured instances:
/// - [VersionCheckerConfig.defaultConfig] - Default configuration with sensible defaults
///
/// @since 1.0.0
class VersionCheckerConfig {
  /// API endpoint URL for version checking
  final String apiUrl;

  /// Request timeout in seconds
  final int timeoutSeconds;

  /// Whether to cache responses
  final bool enableCaching;

  /// Cache duration in minutes
  final int cacheDurationMinutes;

  /// Preferred locale for API responses
  final String? locale;

  /// Whether to show dialogs automatically
  final bool showDialogs;

  /// Whether to show error dialogs to users when version checking fails
  /// When false, errors are logged silently without interrupting the user
  final bool showErrorDialogs;

  /// Configuration for update available dialog
  final DialogConfig updateDialogConfig;

  /// Configuration for forced update dialog
  final DialogConfig forceUpdateDialogConfig;

  /// Configuration for error dialog
  final DialogConfig errorDialogConfig;

  /// Custom headers for API requests
  final Map<String, String>? customHeaders;

  /// Whether to include build number in requests
  final bool includeBuildNumber;

  /// Custom user agent for requests
  final String? userAgent;

  const VersionCheckerConfig({
    required this.apiUrl,
    this.timeoutSeconds = 30,
    this.enableCaching = true,
    this.cacheDurationMinutes = 5,
    this.locale,
    this.showDialogs = true,
    this.showErrorDialogs = false,
    this.updateDialogConfig = DialogConfig.updateAvailable,
    this.forceUpdateDialogConfig = DialogConfig.forceUpdate,
    this.errorDialogConfig = DialogConfig.error,
    this.customHeaders,
    this.includeBuildNumber = true,
    this.userAgent,
  });

  /// Create a copy with modified fields
  VersionCheckerConfig copyWith({
    String? apiUrl,
    int? timeoutSeconds,
    bool? enableCaching,
    int? cacheDurationMinutes,
    String? locale,
    bool? showDialogs,
    bool? showErrorDialogs,
    DialogConfig? updateDialogConfig,
    DialogConfig? forceUpdateDialogConfig,
    DialogConfig? errorDialogConfig,
    Map<String, String>? customHeaders,
    bool? includeBuildNumber,
    String? userAgent,
  }) {
    return VersionCheckerConfig(
      apiUrl: apiUrl ?? this.apiUrl,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      enableCaching: enableCaching ?? this.enableCaching,
      cacheDurationMinutes: cacheDurationMinutes ?? this.cacheDurationMinutes,
      locale: locale ?? this.locale,
      showDialogs: showDialogs ?? this.showDialogs,
      showErrorDialogs: showErrorDialogs ?? this.showErrorDialogs,
      updateDialogConfig: updateDialogConfig ?? this.updateDialogConfig,
      forceUpdateDialogConfig:
          forceUpdateDialogConfig ?? this.forceUpdateDialogConfig,
      errorDialogConfig: errorDialogConfig ?? this.errorDialogConfig,
      customHeaders: customHeaders ?? this.customHeaders,
      includeBuildNumber: includeBuildNumber ?? this.includeBuildNumber,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  /// Default configuration with the test API endpoint
  static const defaultConfig = VersionCheckerConfig(
    apiUrl: 'https://salawati.smart-fingers.com/api/version/check',
    timeoutSeconds: 30,
    enableCaching: true,
    cacheDurationMinutes: 5,
    showDialogs: true,
    showErrorDialogs: false,
    includeBuildNumber: true,
  );

  @override
  String toString() {
    return 'VersionCheckerConfig(apiUrl: $apiUrl, timeoutSeconds: $timeoutSeconds, enableCaching: $enableCaching, showDialogs: $showDialogs)';
  }
}
