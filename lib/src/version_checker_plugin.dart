import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'models/version_check_response.dart';
import 'models/version_checker_config.dart';
import 'models/dialog_config.dart';
import 'services/version_checker_service.dart';
import 'widgets/update_dialog.dart';
import 'widgets/force_update_dialog.dart';
import 'widgets/error_dialog.dart';
import 'utils/url_launcher_helper.dart';

/// Callback function for version check results.
///
/// Called when a version check operation completes, providing the
/// [VersionCheckResponse] with details about the update status.
///
/// Example:
/// ```dart
/// onResult: (response) {
///   if (response.updateAvailable) {
///     print('Update available: ${response.latestVersion}');
///   }
/// }
/// ```
typedef VersionCheckCallback = void Function(VersionCheckResponse response);

/// Callback function for user actions.
///
/// Used for handling user interactions with update dialogs such as
/// pressing update, later, or dismiss buttons.
///
/// Example:
/// ```dart
/// onUpdatePressed: () {
///   // Navigate to app store or handle update
///   print('User wants to update');
/// }
/// ```
typedef UserActionCallback = void Function();

/// Main plugin class for version checking functionality.
///
/// The [VersionChecker] class provides a comprehensive solution for checking
/// app version updates with customizable dialogs and API integration.
///
/// Features:
/// - Automatic version comparison using semantic versioning
/// - Customizable update dialogs with full styling control
/// - Built-in caching for improved performance
/// - Support for force updates and error handling
/// - Cross-platform support (iOS and Android)
/// - Localization support for international apps
///
/// Basic usage:
/// ```dart
/// final versionChecker = VersionChecker(
///   config: VersionCheckerConfig(
///     apiUrl: 'https://your-api.com/version/check',
///   ),
/// );
///
/// await versionChecker.checkForUpdates(
///   context: context,
///   showDialogs: true,
/// );
/// ```
///
/// Advanced usage with custom configuration:
/// ```dart
/// final versionChecker = VersionChecker(
///   config: VersionCheckerConfig(
///     apiUrl: 'https://your-api.com/version/check',
///     timeout: Duration(seconds: 30),
///     enableCaching: true,
///     cacheExpiration: Duration(hours: 1),
///     locale: 'en',
///   ),
/// );
///
/// await versionChecker.checkForUpdates(
///   context: context,
///   showDialogs: true,
///   onUpdatePressed: () => _handleUpdate(),
///   onLaterPressed: () => _handleLater(),
///   onError: () => _handleError(),
/// );
/// ```
///
/// @since 1.0.0
class VersionChecker {
  static const MethodChannel _channel = MethodChannel('version_checker');

  final VersionCheckerConfig config;
  late final VersionCheckerService _service;

  VersionChecker({
    VersionCheckerConfig? config,
  }) : config = config ?? VersionCheckerConfig.defaultConfig {
    _service = VersionCheckerService(this.config);
  }

  /// Checks for app updates and optionally displays update dialogs.
  ///
  /// This method performs a version check against the configured API endpoint
  /// and can automatically display appropriate dialogs based on the response.
  ///
  /// The method will:
  /// 1. Get the current app version using package_info_plus
  /// 2. Send a request to the configured API endpoint
  /// 3. Compare versions using semantic versioning
  /// 4. Display appropriate dialogs if [showDialogs] is true
  /// 5. Handle caching if enabled in configuration
  ///
  /// Parameters:
  /// - [context]: Build context required for showing dialogs. If null and
  ///   [showDialogs] is true, dialogs won't be shown.
  /// - [showDialogs]: Whether to automatically show update dialogs. Defaults to true.
  /// - [onResult]: Callback invoked with the version check response.
  /// - [onUpdatePressed]: Callback invoked when user presses the update button.
  /// - [onLaterPressed]: Callback invoked when user presses the later button.
  /// - [onDismissed]: Callback invoked when dialog is dismissed without action.
  /// - [onError]: Callback invoked when an error occurs during version check.
  ///
  /// Returns a [Future<VersionCheckResponse>] containing the version check results.
  ///
  /// Throws:
  /// - [TimeoutException] if the API request times out
  /// - [SocketException] if there's a network connectivity issue
  /// - [FormatException] if the API response format is invalid
  ///
  /// Example usage:
  /// ```dart
  /// // Basic usage with default dialogs
  /// final response = await versionChecker.checkForUpdates(
  ///   context: context,
  /// );
  ///
  /// // Advanced usage with callbacks
  /// final response = await versionChecker.checkForUpdates(
  ///   context: context,
  ///   showDialogs: true,
  ///   onResult: (response) {
  ///     print('Update available: ${response.updateAvailable}');
  ///   },
  ///   onUpdatePressed: () {
  ///     // Handle update button press
  ///     _navigateToAppStore();
  ///   },
  ///   onLaterPressed: () {
  ///     // Handle later button press
  ///     _scheduleReminderLater();
  ///   },
  ///   onError: () {
  ///     // Handle error scenarios
  ///     _showCustomErrorMessage();
  ///   },
  /// );
  ///
  /// // Check without showing dialogs
  /// final response = await versionChecker.checkForUpdates(
  ///   showDialogs: false,
  /// );
  /// if (response.updateAvailable) {
  ///   // Handle update available manually
  /// }
  /// ```
  ///
  /// @since 1.0.0
  Future<VersionCheckResponse> checkForUpdates({
    BuildContext? context,
    bool showDialogs = true,
    VersionCheckCallback? onResult,
    UserActionCallback? onUpdatePressed,
    UserActionCallback? onLaterPressed,
    UserActionCallback? onDismissed,
    UserActionCallback? onError,
  }) async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final platform = Platform.isIOS ? 'ios' : 'android';

      // Perform version check
      final response = await _service.checkForUpdates(
        currentVersion: packageInfo.version,
        platform: platform,
        buildNumber: packageInfo.buildNumber,
        locale: config.locale,
      );

      // Call result callback
      onResult?.call(response);

      // Show dialogs if enabled and context is provided
      if (showDialogs && context != null && config.showDialogs) {
        await _handleDialogDisplay(
          context,
          response,
          onUpdatePressed: onUpdatePressed,
          onLaterPressed: onLaterPressed,
          onDismissed: onDismissed,
          onError: onError,
        );
      }

      return response;
    } catch (e) {
      final errorResponse = VersionCheckResponse(
        success: false,
        currentVersion: '',
        platform: Platform.isIOS ? 'ios' : 'android',
        updateAvailable: false,
        forceUpdate: false,
        error: e.toString(),
      );

      onResult?.call(errorResponse);
      onError?.call();

      // Log error silently for debugging
      print('VersionChecker: Version check failed - ${e.toString()}');

      // Show error dialog only if explicitly enabled
      if (showDialogs &&
          context != null &&
          config.showDialogs &&
          config.showErrorDialogs) {
        await ErrorDialog.show(
          context,
          error: e.toString(),
          config: config.errorDialogConfig,
          onDismiss: onDismissed,
        );
      }

      return errorResponse;
    }
  }

  /// Handle dialog display based on response
  Future<void> _handleDialogDisplay(
    BuildContext context,
    VersionCheckResponse response, {
    UserActionCallback? onUpdatePressed,
    UserActionCallback? onLaterPressed,
    UserActionCallback? onDismissed,
    UserActionCallback? onError,
  }) async {
    if (!response.success) {
      // Log error silently for debugging
      print(
          'VersionChecker: API response error - ${response.error ?? 'Unknown error occurred'}');

      // Show error dialog only if explicitly enabled
      if (config.showErrorDialogs) {
        await ErrorDialog.show(
          context,
          error: response.error ?? 'Unknown error occurred',
          config: config.errorDialogConfig,
          onDismiss: onDismissed,
        );
      }
      return;
    }

    if (!response.updateAvailable) {
      // No update available - optionally show a message
      return;
    }

    if (response.forceUpdate) {
      await ForceUpdateDialog.show(
        context,
        response: response,
        config: config.forceUpdateDialogConfig,
        onUpdate: () {
          onUpdatePressed?.call();
          _launchStore(
            response.downloadUrl,
            context: context,
            showFeedback: true,
          );
        },
      );
    } else {
      await UpdateDialog.show(
        context,
        response: response,
        config: config.updateDialogConfig,
        onUpdate: () {
          onUpdatePressed?.call();
          _launchStore(
            response.downloadUrl,
            context: context,
            showFeedback: true,
          );
        },
        onLater: onLaterPressed,
        onDismiss: onDismissed,
      );
    }
  }

  /// Launch app store or download URL with comprehensive error handling
  ///
  /// This method uses the UrlLauncherHelper to:
  /// - Validate the download URL
  /// - Show user feedback during launch
  /// - Handle platform-specific app store URLs
  /// - Provide error handling with user-friendly messages
  ///
  /// Parameters:
  /// - [downloadUrl]: The URL to launch (app store or web URL)
  /// - [context]: Build context for showing user feedback (optional)
  /// - [showFeedback]: Whether to show loading/success/error feedback
  Future<void> _launchStore(
    String? downloadUrl, {
    BuildContext? context,
    bool showFeedback = true,
  }) async {
    if (downloadUrl == null || downloadUrl.isEmpty) {
      return;
    }

    if (context != null && showFeedback) {
      // Launch with full UI feedback
      await UrlLauncherHelper.launchUpdateUrl(
        context: context,
        downloadUrl: downloadUrl,
        onSuccess: () {
          // Optional: Add analytics or logging here
        },
        onError: (error) {
          // Optional: Add error analytics or logging here
        },
      );
    } else {
      // Launch silently without UI feedback
      await UrlLauncherHelper.launchUrlSilently(downloadUrl);
    }
  }

  /// Get current app version information
  static Future<Map<String, String>> getAppVersion() async {
    try {
      final result =
          await _channel.invokeMethod<Map<Object?, Object?>>('getAppVersion');
      return Map<String, String>.from(result ?? {});
    } on PlatformException {
      // Fallback to package_info_plus
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'version': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
    }
  }

  /// Clear cached responses
  Future<void> clearCache() async {
    await _service.clearCache();
  }

  /// Check for updates without showing dialogs
  Future<VersionCheckResponse> checkForUpdatesQuietly({
    String? customVersion,
    String? customPlatform,
    String? buildNumber,
    String? locale,
  }) async {
    try {
      String version = customVersion ?? '';
      String platform = customPlatform ?? '';
      String? build = buildNumber;

      if (customVersion == null || customPlatform == null) {
        final packageInfo = await PackageInfo.fromPlatform();
        version = customVersion ?? packageInfo.version;
        platform = customPlatform ?? (Platform.isIOS ? 'ios' : 'android');
        build = buildNumber ?? packageInfo.buildNumber;
      }

      return await _service.checkForUpdates(
        currentVersion: version,
        platform: platform,
        buildNumber: build,
        locale: locale ?? config.locale,
      );
    } catch (e) {
      return VersionCheckResponse(
        success: false,
        currentVersion: customVersion ?? '',
        platform: customPlatform ?? '',
        updateAvailable: false,
        forceUpdate: false,
        error: e.toString(),
      );
    }
  }

  /// Show update dialog manually
  static Future<void> showUpdateDialog(
    BuildContext context, {
    required VersionCheckResponse response,
    DialogConfig? config,
    UserActionCallback? onUpdate,
    UserActionCallback? onLater,
    UserActionCallback? onDismiss,
  }) async {
    await UpdateDialog.show(
      context,
      response: response,
      config: config ?? DialogConfig.updateAvailable,
      onUpdate: onUpdate,
      onLater: onLater,
      onDismiss: onDismiss,
    );
  }

  /// Show force update dialog manually
  static Future<void> showForceUpdateDialog(
    BuildContext context, {
    required VersionCheckResponse response,
    DialogConfig? config,
    UserActionCallback? onUpdate,
  }) async {
    await ForceUpdateDialog.show(
      context,
      response: response,
      config: config ?? DialogConfig.forceUpdate,
      onUpdate: onUpdate,
    );
  }

  /// Show error dialog manually
  static Future<void> showErrorDialog(
    BuildContext context, {
    required String error,
    DialogConfig? config,
    UserActionCallback? onRetry,
    UserActionCallback? onDismiss,
  }) async {
    await ErrorDialog.show(
      context,
      error: error,
      config: config ?? DialogConfig.error,
      onRetry: onRetry,
      onDismiss: onDismiss,
    );
  }
}
