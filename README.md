# Version Checker

[![pub package](https://img.shields.io/pub/v/version_checker.svg)](https://pub.dev/packages/version_checker)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A comprehensive Flutter plugin for checking app version updates with customizable dialogs and seamless API integration. Perfect for keeping your users informed about new app versions with beautiful, customizable update prompts.

## Features

✨ **Easy Integration** - Simple setup with minimal configuration
🎨 **Customizable Dialogs** - Beautiful, fully customizable update dialogs with icon and shape support
🎭 **Icon Customization** - Custom icons, colors, and sizes for different update scenarios
🔷 **Shape Customization** - Flexible dialog shapes including circles, rounded rectangles, and custom borders
🔄 **Automatic Version Checking** - Smart version comparison and update detection
🌐 **API Integration** - Works with any REST API endpoint
📱 **Cross Platform** - Supports iOS and Android
⚡ **Caching Support** - Built-in response caching for better performance
🎯 **Force Updates** - Support for mandatory app updates
🔗 **URL Launching** - Direct users to app stores with platform-specific handling
🛠️ **Error Handling** - Silent error logging with optional error dialogs for better UX

## Installation

### Option 1: Install from GitHub (Recommended)

Since this package is not yet published on pub.dev, you can install it directly from the GitHub repository.

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  version_checker:
    git:
      url: https://github.com/aymanalareqi/version_checker.git
      ref: main  # Use main branch for latest updates
```

For a specific version/tag, use:

```yaml
dependencies:
  version_checker:
    git:
      url: https://github.com/aymanalareqi/version_checker.git
      ref: v1.0.0  # Replace with desired version tag
```

### Option 2: Install from pub.dev (Future)

Once published on pub.dev, you can install using:

```yaml
dependencies:
  version_checker: ^1.0.0
```

### Complete Installation

After adding the dependency, run:

```bash
flutter pub get
```

### GitHub vs pub.dev Installation Notes

**GitHub Installation:**
- ✅ Access to latest features and bug fixes
- ✅ Can specify exact commits or branches
- ✅ Direct access to unreleased features
- ⚠️ Dependency resolution may be slower
- ⚠️ Requires internet access during `flutter pub get`
- ⚠️ Version constraints work differently

**pub.dev Installation (when available):**
- ✅ Faster dependency resolution
- ✅ Better version constraint support
- ✅ Offline caching support
- ✅ Semantic versioning compatibility

### Advanced GitHub Installation Options

**Using a specific commit:**
```yaml
dependencies:
  version_checker:
    git:
      url: https://github.com/aymanalareqi/version_checker.git
      ref: abc1234  # Replace with actual commit hash
```

**Using a specific branch:**
```yaml
dependencies:
  version_checker:
    git:
      url: https://github.com/aymanalareqi/version_checker.git
      ref: develop  # Use develop branch
```

**Using SSH instead of HTTPS:**
```yaml
dependencies:
  version_checker:
    git:
      url: git@github.com:aymanalareqi/version_checker.git
      ref: main
```

## Quick Start

### Setup

1. **Add the dependency** to your `pubspec.yaml`:
   ```yaml
   dependencies:
     version_checker:
       git:
         url: https://github.com/aymanalareqi/version_checker.git
         ref: main
   ```

2. **Run flutter pub get**:
   ```bash
   flutter pub get
   ```

3. **Import the package** in your Dart files:
   ```dart
   import 'package:version_checker/version_checker.dart';
   ```

### Basic Usage

```dart
import 'package:version_checker/version_checker.dart';

// Create a version checker instance
final versionChecker = VersionChecker(
  config: VersionCheckerConfig(
    apiUrl: 'https://your-api.com/version/check',
  ),
);

// Check for updates with default dialogs
await versionChecker.checkForUpdates(
  context: context,
  showDialogs: true,
);
```

### Advanced Usage with Custom Configuration

```dart
import 'package:version_checker/version_checker.dart';

final versionChecker = VersionChecker(
  config: VersionCheckerConfig(
    apiUrl: 'https://your-api.com/version/check',
    timeout: Duration(seconds: 30),
    enableCaching: true,
    cacheExpiration: Duration(hours: 1),
    locale: 'en',
  ),
);

await versionChecker.checkForUpdates(
  context: context,
  showDialogs: true,
  onUpdatePressed: () {
    // Handle update button press
    print('User wants to update');
  },
  onLaterPressed: () {
    // Handle later button press
    print('User chose to update later');
  },
  onError: () {
    // Handle error scenarios
    print('Error checking for updates');
  },
);
```

## API Integration

The plugin expects your API to return a JSON response in the following format:

```json
{
  "success": true,
  "current_version": "1.0.0",
  "latest_version": "1.2.0",
  "update_available": true,
  "force_update": false,
  "message": "A new version is available with exciting features!",
  "release_notes": {
    "en": "• Bug fixes\n• Performance improvements\n• New features",
    "ar": "• إصلاح الأخطاء\n• تحسينات الأداء\n• ميزات جديدة"
  },
  "download_url": "https://play.google.com/store/apps/details?id=com.yourapp"
}
```

### API Request Format

The plugin sends a POST request with:

```json
{
  "current_version": "1.0.0",
  "platform": "android",
  "locale": "en"
}
```

## Dialog Customization

### Basic Dialog Styling

```dart
final customConfig = DialogConfig(
  title: 'Update Available',
  message: 'A new version of the app is available.',
  positiveButtonText: 'Update Now',
  negativeButtonText: 'Later',
  titleStyle: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
  messageStyle: TextStyle(
    fontSize: 16,
    color: Colors.grey[700],
  ),
  positiveButtonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    foregroundColor: Colors.white,
  ),
  negativeButtonStyle: TextButton.styleFrom(
    foregroundColor: Colors.grey,
  ),
  barrierDismissible: true,
  showNegativeButton: true,
);
```

### Icon Customization

Customize dialog icons with different styles and colors:

```dart
// Download icon with green theme
final downloadConfig = DialogConfig(
  icon: Icons.cloud_download,
  iconColor: Colors.green,
  iconSize: 72,
  title: 'Download Update',
  message: 'New features are ready to download!',
);

// Security update with warning theme
final securityConfig = DialogConfig(
  icon: Icons.security,
  iconColor: Colors.red,
  iconSize: 64,
  title: 'Security Update',
  message: 'Important security fixes available.',
);

// Modern rocket launch theme
final modernConfig = DialogConfig(
  icon: Icons.rocket_launch,
  iconColor: Colors.purple,
  iconSize: 80,
  title: 'New Features',
);
```

### Shape Customization

Create unique dialog shapes for different update scenarios:

```dart
// Rounded rectangle with colored border
final borderedConfig = DialogConfig(
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: BorderSide(color: Colors.blue, width: 2),
  ),
  icon: Icons.system_update,
  iconColor: Colors.blue,
);

// Circular dialog for critical updates
final circularConfig = DialogConfig(
  shape: CircleBorder(),
  padding: EdgeInsets.all(32),
  icon: Icons.priority_high,
  iconColor: Colors.orange,
);

// Stadium shape for modern look
final stadiumConfig = DialogConfig(
  shape: StadiumBorder(),
  icon: Icons.rocket_launch,
  iconColor: Colors.purple,
);
```

### Complete Custom Configuration

```dart
final fullyCustomConfig = DialogConfig(
  // Icon customization
  icon: Icons.cloud_download,
  iconColor: Colors.green,
  iconSize: 72,

  // Shape customization
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16),
    side: BorderSide(color: Colors.green, width: 2),
  ),

  // Content and styling
  title: 'Enhanced Update',
  message: 'Experience new features with improved performance.',
  backgroundColor: Colors.green.shade50,
  titleStyle: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.green.shade800,
  ),
  positiveButtonStyle: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    foregroundColor: Colors.white,
  ),
  elevation: 12,
  padding: EdgeInsets.all(24),
);
```

### Text Customization

Customize all text elements in dialogs with dynamic placeholder substitution:

#### Dynamic Text with Placeholders

```dart
final textCustomConfig = DialogConfig(
  title: 'Update {appName}',
  message: 'Ready to upgrade your experience?',
  positiveButtonText: 'Upgrade Now',
  negativeButtonText: 'Not Now',

  // Custom text with dynamic placeholders
  currentVersionText: 'Current: {currentVersion}',
  latestVersionText: 'Available: {latestVersion}',
  updateAvailableText: 'Update from {currentVersion} to {latestVersion} now!',
  releaseNotesTitle: 'What\'s New in {latestVersion}:',

  // Custom placeholders for additional variables
  customPlaceholders: {
    'appName': 'MyApp',
    'supportEmail': 'support@myapp.com',
    'downloadSize': '45.2 MB',
  },
);
```

#### Localized Text (Spanish Example)

```dart
final spanishConfig = DialogConfig(
  title: '¡Actualización Disponible!',
  message: '¿Listo para mejorar tu experiencia?',
  positiveButtonText: 'Actualizar',
  negativeButtonText: 'Más Tarde',

  // Spanish text with placeholders
  currentVersionText: 'Versión actual: {currentVersion}',
  latestVersionText: 'Nueva versión: {latestVersion}',
  updateAvailableText: '¡Actualiza de {currentVersion} a {latestVersion}!',
  releaseNotesTitle: 'Novedades en {latestVersion}:',
  downloadSizeText: 'Tamaño: {downloadSize}',

  customPlaceholders: {
    'appName': 'MiApp',
    'supportEmail': 'soporte@miapp.com',
  },
);
```

#### Available Text Properties

- `currentVersionText` - Display current app version
- `latestVersionText` - Display latest available version
- `updateAvailableText` - Update available message
- `forceUpdateText` - Force update message
- `forceUpdateRequirementText` - Force update requirement text
- `errorText` - Error message text
- `errorDetailsText` - Error details header
- `connectionErrorText` - Connection error message
- `releaseNotesTitle` - Release notes section title
- `downloadSizeText` - Download size display
- `lastCheckedText` - Last checked timestamp
- `customPlaceholders` - Map of custom placeholder values

#### Supported Placeholders

- `{currentVersion}` - Current app version
- `{latestVersion}` - Latest available version
- `{appName}` - Application name (from custom placeholders)
- `{downloadSize}` - Download size (from custom placeholders)
- `{error}` - Error message
- Custom placeholders from `customPlaceholders` map

### Manual Dialog Display

```dart
// Show update dialog manually
await showDialog(
  context: context,
  builder: (context) => UpdateDialog(
    response: versionCheckResponse,
    config: DialogConfig.update,
    onUpdate: () {
      Navigator.of(context).pop();
      // Handle update action
    },
    onLater: () {
      Navigator.of(context).pop();
      // Handle later action
    },
  ),
);
```

## Configuration Options

### VersionCheckerConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `apiUrl` | `String` | Required | API endpoint for version checking |
| `timeout` | `Duration` | `30 seconds` | Request timeout duration |
| `enableCaching` | `bool` | `true` | Enable response caching |
| `cacheExpiration` | `Duration` | `1 hour` | Cache expiration time |
| `locale` | `String?` | `null` | Locale for localized responses |

### DialogConfig

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `title` | `String` | `'Update Available'` | Dialog title |
| `message` | `String?` | `null` | Dialog message |
| `positiveButtonText` | `String?` | `'Update'` | Positive button text |
| `negativeButtonText` | `String?` | `'Later'` | Negative button text |
| `showNegativeButton` | `bool` | `true` | Show negative button |
| `barrierDismissible` | `bool` | `true` | Allow dismissing by tapping outside |
| `icon` | `IconData?` | `null` | Dialog icon |

## Error Dialog Behavior

By default, the plugin provides a better user experience by suppressing error dialogs when version checks fail. Errors are logged silently without interrupting the user:

```dart
// Default behavior - silent error handling
final versionChecker = VersionChecker(
  config: VersionCheckerConfig(
    apiUrl: 'your-api-url',
    showErrorDialogs: false, // Default: false
  ),
);

// Network errors won't show dialogs to users
await versionChecker.checkForUpdates(context: context);
```

To enable error dialogs for debugging or specific use cases:

```dart
// Enable error dialogs
final versionChecker = VersionChecker(
  config: VersionCheckerConfig(
    apiUrl: 'your-api-url',
    showErrorDialogs: true, // Show error dialogs
    errorDialogConfig: DialogConfig(
      title: 'Update Check Failed',
      message: 'Unable to check for updates at this time.',
      positiveButtonText: 'Retry',
      negativeButtonText: 'Cancel',
    ),
  ),
);
```

**Benefits of Silent Error Handling:**
- 🎯 Better user experience - no interruptions from network failures
- 🔄 Background operation - version checks happen silently
- 🐛 Debugging support - errors are still logged for developers
- ⚙️ Optional control - can be enabled when needed

## Platform Support

- ✅ **Android** - Full support with Google Play Store integration
- ✅ **iOS** - Full support with App Store integration
- ⏳ **Web** - Coming soon
- ⏳ **macOS** - Coming soon
- ⏳ **Windows** - Coming soon
- ⏳ **Linux** - Coming soon

## Example App

Check out the [example app](./example) for a complete implementation showing all features:

```bash
cd example
flutter run
```

The example demonstrates:
- Basic version checking
- Custom dialog styling
- Force update scenarios
- Error handling
- API integration

## API Reference

### VersionChecker

Main class for version checking functionality.

#### Methods

##### `checkForUpdates()`

Checks for app updates and optionally displays dialogs.

```dart
Future<VersionCheckResponse> checkForUpdates({
  BuildContext? context,
  bool showDialogs = true,
  VersionCheckCallback? onResult,
  UserActionCallback? onUpdatePressed,
  UserActionCallback? onLaterPressed,
  UserActionCallback? onDismissed,
  UserActionCallback? onError,
})
```

**Parameters:**
- `context` - Build context for showing dialogs
- `showDialogs` - Whether to show update dialogs automatically
- `onResult` - Callback for version check results
- `onUpdatePressed` - Callback when update button is pressed
- `onLaterPressed` - Callback when later button is pressed
- `onDismissed` - Callback when dialog is dismissed
- `onError` - Callback for error scenarios

**Returns:** `Future<VersionCheckResponse>` - Version check result

##### `clearCache()`

Clears the cached version check responses.

```dart
Future<void> clearCache()
```

### VersionCheckResponse

Response model for version check results.

#### Properties

- `bool success` - Whether the request was successful
- `String? currentVersion` - Current app version
- `String? latestVersion` - Latest available version
- `bool updateAvailable` - Whether an update is available
- `bool forceUpdate` - Whether the update is mandatory
- `String? message` - Update message
- `Map<String, String>? releaseNotes` - Localized release notes
- `String? downloadUrl` - Download URL for the update
- `String? error` - Error message if request failed

## Troubleshooting

### GitHub Installation Issues

**Problem: `flutter pub get` fails with git dependency**
```
Git error: Failed to resolve git dependency
```

**Solutions:**
1. **Check internet connection** - Git dependencies require internet access
2. **Verify repository URL** - Ensure the GitHub URL is correct
3. **Check Git installation** - Make sure Git is installed and accessible
4. **Try HTTPS instead of SSH** (or vice versa):
   ```yaml
   # HTTPS (default)
   version_checker:
     git:
       url: https://github.com/aymanalareqi/version_checker.git

   # SSH (if you have SSH keys set up)
   version_checker:
     git:
       url: git@github.com:aymanalareqi/version_checker.git
   ```

**Problem: Slow dependency resolution**
```
Running "flutter pub get" in project...
```

**Solutions:**
1. **Use specific tags instead of branches** for better caching:
   ```yaml
   version_checker:
     git:
       url: https://github.com/aymanalareqi/version_checker.git
       ref: v1.0.0  # Use specific version tag
   ```

2. **Clear Flutter cache** if needed:
   ```bash
   flutter clean
   flutter pub cache clean
   flutter pub get
   ```

**Problem: Version conflicts with other dependencies**

**Solutions:**
1. **Use dependency overrides** in `pubspec.yaml`:
   ```yaml
   dependency_overrides:
     version_checker:
       git:
         url: https://github.com/aymanalareqi/version_checker.git
         ref: main
   ```

### Runtime Issues

**Problem: Network timeouts**

**Solution:** Increase timeout in configuration:
```dart
VersionCheckerConfig(
  apiUrl: 'your-api-url',
  timeoutSeconds: 60, // Increase timeout
)
```

**Problem: Dialogs not showing**

**Solutions:**
1. **Ensure context is valid**:
   ```dart
   if (mounted && context.mounted) {
     await versionChecker.checkForUpdates(context: context);
   }
   ```

2. **Check showDialogs parameter**:
   ```dart
   await versionChecker.checkForUpdates(
     context: context,
     showDialogs: true, // Make sure this is true
   );
   ```

### API Integration Issues

**Problem: API returns unexpected format**

**Solution:** Verify your API response matches the expected format:
```json
{
  "success": true,
  "current_version": "1.0.0",
  "latest_version": "1.1.0",
  "update_available": true,
  "force_update": false,
  "message": "Update available",
  "download_url": "https://your-download-url"
}
```

For more help, please [create an issue](https://github.com/aymanalareqi/version_checker/issues) on GitHub.

## Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

- 📧 Email: support@smartfingers.com
- 🐛 Issues: [GitHub Issues](https://github.com/aymanalareqi/version_checker/issues)
- 📖 Documentation: [API Docs](https://pub.dev/documentation/version_checker/latest/)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for a detailed list of changes and updates.
