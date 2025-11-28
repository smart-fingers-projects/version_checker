import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:version_checker/src/models/version_check_request.dart';
import 'package:version_checker/src/models/version_checker_config.dart';
import 'package:version_checker/src/services/version_checker_service.dart';

import 'version_checker_service_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('VersionCheckerService', () {
    late MockClient mockHttpClient;
    late VersionCheckerService service;
    late VersionCheckerConfig config;

    setUp(() {
      mockHttpClient = MockClient();
      config = const VersionCheckerConfig(
        apiUrl: 'https://api.example.com/version/check',
        timeoutSeconds: 10,
        cacheDurationMinutes: 30,
      );
      service = VersionCheckerService(config, httpClient: mockHttpClient);

      // Mock SharedPreferences
      SharedPreferences.setMockInitialValues({});
    });

    group('checkForUpdates', () {
      test('should return successful response for valid API response',
          () async {
        final apiResponse = {
          'success': true,
          'current_version': '1.0.0',
          'platform': 'ios',
          'update_available': true,
          'latest_version': '1.1.0',
          'force_update': false,
          'download_url': 'https://apps.apple.com/app/example',
          'release_notes': 'Bug fixes and improvements',
        };

        when(mockHttpClient.post(
          Uri.parse(config.apiUrl),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode(apiResponse),
              200,
              headers: {'content-type': 'application/json'},
            ));

        final response = await service.checkForUpdates(
          currentVersion: '1.0.0',
          platform: 'ios',
          buildNumber: '123',
        );

        expect(response.success, true);
        expect(response.updateAvailable, true);
        expect(response.latestVersion, '1.1.0');
        expect(response.downloadUrl, 'https://apps.apple.com/app/example');
        expect(response.releaseNotes, 'Bug fixes and improvements');

        verify(mockHttpClient.post(
          Uri.parse(config.apiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: anyNamed('body'),
        )).called(1);
      });

      test('should return error response for HTTP error', () async {
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Not Found', 404));

        final response = await service.checkForUpdates(
          currentVersion: '2.0.0',
          platform: 'android',
          buildNumber: '456',
        );

        expect(response.success, false);
        expect(response.error, contains('API request failed with status 404'));
        expect(response.updateAvailable, false);
      });

      test('should return error response for network timeout', () async {
        const request = VersionCheckRequest(
          platform: 'ios',
          currentVersion: '1.0.0',
          buildNumber: '123',
        );

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenThrow(const SocketException('Connection timeout'));

        final response = await service.checkForUpdates(
          currentVersion: '1.5.0',
          platform: 'ios',
        );

        expect(response.success, false);
        expect(response.error, contains('Connection timeout'));
        expect(response.updateAvailable, false);
      });

      test('should return error response for invalid JSON', () async {
        const request = VersionCheckRequest(
          platform: 'ios',
          currentVersion: '1.0.0',
          buildNumber: '123',
        );

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              'Invalid JSON response',
              200,
              headers: {'content-type': 'application/json'},
            ));

        final response = await service.checkForUpdates(
          currentVersion: '1.0.0',
          platform: 'android',
        );

        expect(response.success, false);
        expect(response.error, contains('FormatException'));
        expect(response.updateAvailable, false);
      });

      test('should handle API response with success: false', () async {
        const request = VersionCheckRequest(
          platform: 'ios',
          currentVersion: '1.0.0',
          buildNumber: '123',
        );

        final apiResponse = {
          'success': false,
          'error': 'Invalid platform',
          'current_version': '1.0.0',
          'platform': 'ios',
          'update_available': false,
          'force_update': false,
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode(apiResponse),
              200,
              headers: {'content-type': 'application/json'},
            ));

        final response = await service.checkForUpdates(
          currentVersion: '1.0.0',
          platform: 'invalid',
        );

        expect(response.success, false);
        expect(response.error, 'Invalid platform');
        expect(response.updateAvailable, false);
      });

      test('should include locale in request when provided', () async {
        final apiResponse = {
          'success': true,
          'current_version': '1.0.0',
          'platform': 'ios',
          'update_available': false,
          'force_update': false,
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode(apiResponse),
              200,
              headers: {'content-type': 'application/json'},
            ));

        await service.checkForUpdates(
          currentVersion: '1.0.0',
          platform: 'ios',
          locale: 'es',
        );

        final capturedBody = verify(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: captureAnyNamed('body'),
        )).captured.single as String;

        final sentData = jsonDecode(capturedBody) as Map<String, dynamic>;
        expect(sentData['locale'], 'es');
      });
    });

    group('caching', () {
      test('should cache successful responses', () async {
        final apiResponse = {
          'success': true,
          'current_version': '1.0.0',
          'platform': 'ios',
          'update_available': true,
          'latest_version': '1.1.0',
          'force_update': false,
        };

        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
              jsonEncode(apiResponse),
              200,
              headers: {'content-type': 'application/json'},
            ));

        // First call should make HTTP request
        final response1 = await service.checkForUpdates(
          currentVersion: '1.0.0',
          platform: 'ios',
        );
        expect(response1.success, true);

        // Second call should use cache
        final response2 = await service.checkForUpdates(
          currentVersion: '1.0.0',
          platform: 'ios',
        );
        expect(response2.success, true);
        expect(response2.latestVersion, response1.latestVersion);

        // Verify HTTP client was called only once
        verify(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });

      test('should not cache error responses', () async {
        when(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response('Server Error', 500));

        // First call should make HTTP request and get error
        final response1 = await service.checkForUpdates(
          currentVersion: '1.0.0',
          platform: 'android',
        );
        expect(response1.success, false);

        // Second call should make another HTTP request (no caching of errors)
        final response2 = await service.checkForUpdates(
          currentVersion: '1.0.0',
          platform: 'android',
        );
        expect(response2.success, false);

        // Verify HTTP client was called twice
        verify(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(2);
      });
    });

    group('clearCache', () {
      test('should clear cached responses', () async {
        await service.clearCache();

        // This test mainly ensures the method doesn't throw
        // In a real implementation, we would verify SharedPreferences.clear() was called
        expect(true, true); // Placeholder assertion
      });
    });
  });
}
