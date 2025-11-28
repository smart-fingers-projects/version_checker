import 'dialog_config.dart';
import 'version_check_request.dart';
import 'version_check_response.dart';

/// Signature for a custom version source.
///
/// This allows the version checker to work 100% offline by providing
/// version information from a local source (for example a bundled JSON
/// asset, a local database, or any other non-HTTP mechanism).
typedef VersionSource =
    Future<VersionCheckResponse> Function(VersionCheckRequest request);

/// Configuration class for the version checker plugin.
///
/// The [VersionCheckerConfig] class provides configuration options
/// for the version checking functionality, including API settings,
/// caching behavior, dialog configurations, and request customization.
class VersionCheckerConfig {
  /// API endpoint URL for version checking.
  ///
  /// If [versionSource] is provided, this value is ignored and no HTTP
  /// request will be made.
  final String apiUrl;

  /// Request timeout in seconds.
  final int timeoutSeconds;

  /// Whether to cache responses.
  final bool enableCaching;

  /// Cache duration in minutes.
  final int cacheDurationMinutes;

  /// Preferred locale for API responses.
  final String? locale;

  /// Whether to show dialogs automatically.
  final bool showDialogs;

  /// Whether to show error dialogs to users when version checking fails.
  final bool showErrorDialogs;

  /// Dialog configuration for optional update dialog.
  final DialogConfig updateDialogConfig;

  /// Dialog configuration for force update dialog.
  final DialogConfig forceUpdateDialogConfig;

  /// Dialog configuration for error dialog.
  final DialogConfig errorDialogConfig;

  /// Custom headers to include in the HTTP request.
  final Map<String, String>? customHeaders;

  /// Whether to include the build number in the request.
  final bool includeBuildNumber;

  /// Optional User-Agent header to send with the HTTP request.
  final String? userAgent;

  /// Optional custom version source.
  ///
  /// When this is non-null, the service will call this function instead
  /// of performing an HTTP request. This is the recommended way to use
  /// the package in fully offline environments.
  final VersionSource? versionSource;

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
    this.versionSource,
  });

  /// Create a copy with modified fields.
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
    VersionSource? versionSource,
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
      versionSource: versionSource ?? this.versionSource,
    );
  }

  /// Default configuration with the production API endpoint.
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
    return 'VersionCheckerConfig('
        'apiUrl: $apiUrl, '
        'timeoutSeconds: $timeoutSeconds, '
        'enableCaching: $enableCaching, '
        'cacheDurationMinutes: $cacheDurationMinutes, '
        'showDialogs: $showDialogs, '
        'showErrorDialogs: $showErrorDialogs, '
        'hasVersionSource: ${versionSource != null}'
        ')';
  }
}
