import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:version_checker/version_checker.dart';

void main() {
  group('Error Dialog Suppression', () {
    testWidgets('should not show error dialog when showErrorDialogs is false',
        (WidgetTester tester) async {
      // Create a version checker with error dialogs disabled (default)
      final versionChecker = VersionChecker(
        config: const VersionCheckerConfig(
          apiUrl: 'https://invalid-url-that-will-fail.com/api/version/check',
          showErrorDialogs: false, // Explicitly disable error dialogs
          timeoutSeconds: 1, // Short timeout to fail quickly
        ),
      );

      // Build a test app
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await versionChecker.checkForUpdates(
                  context: context,
                  showDialogs: true,
                );
              },
              child: const Text('Check Version'),
            ),
          ),
        ),
      ));

      // Tap the button to trigger version check
      await tester.tap(find.text('Check Version'));
      await tester.pump();

      // Wait for the network request to fail
      await tester.pump(const Duration(seconds: 2));

      // Verify no error dialog is shown
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Error'), findsNothing);
      expect(find.text('Update Check Failed'), findsNothing);
    });

    testWidgets('should show error dialog when showErrorDialogs is true',
        (WidgetTester tester) async {
      // Create a version checker with error dialogs enabled
      final versionChecker = VersionChecker(
        config: const VersionCheckerConfig(
          apiUrl: 'https://invalid-url-that-will-fail.com/api/version/check',
          showErrorDialogs: true, // Enable error dialogs
          timeoutSeconds: 1, // Short timeout to fail quickly
          errorDialogConfig: DialogConfig(
            title: 'Update Check Failed',
            message: 'Unable to check for updates.',
            positiveButtonText: 'Retry',
            negativeButtonText: 'Cancel',
          ),
        ),
      );

      // Build a test app
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await versionChecker.checkForUpdates(
                  context: context,
                  showDialogs: true,
                );
              },
              child: const Text('Check Version'),
            ),
          ),
        ),
      ));

      // Tap the button to trigger version check
      await tester.tap(find.text('Check Version'));
      await tester.pump();

      // Wait for the network request to fail and dialog to appear
      await tester.pump(const Duration(seconds: 2));

      // Verify error dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Update Check Failed'), findsOneWidget);
    });

    test('should return error response when showErrorDialogs is false',
        () async {
      // Create a version checker with error dialogs disabled
      final versionChecker = VersionChecker(
        config: const VersionCheckerConfig(
          apiUrl: 'https://invalid-url-that-will-fail.com/api/version/check',
          showErrorDialogs: false,
          timeoutSeconds: 1,
        ),
      );

      // Trigger version check without context (no dialogs)
      final response = await versionChecker.checkForUpdates(
        showDialogs: false,
      );

      // Verify the response indicates failure
      expect(response.success, false);
      expect(response.error, isNotNull);
      expect(response.updateAvailable, false);
    });

    test('should have correct default configuration', () {
      // Test default configuration
      const defaultConfig = VersionCheckerConfig.defaultConfig;
      expect(defaultConfig.showErrorDialogs, false);

      // Test custom configuration
      const customConfig = VersionCheckerConfig(
        apiUrl: 'test-url',
        showErrorDialogs: true,
      );
      expect(customConfig.showErrorDialogs, true);
    });

    test('should copy configuration with showErrorDialogs parameter', () {
      const originalConfig = VersionCheckerConfig(
        apiUrl: 'test-url',
        showErrorDialogs: false,
      );

      final copiedConfig = originalConfig.copyWith(showErrorDialogs: true);
      expect(copiedConfig.showErrorDialogs, true);
      expect(copiedConfig.apiUrl, 'test-url'); // Other properties preserved
    });
  });
}
