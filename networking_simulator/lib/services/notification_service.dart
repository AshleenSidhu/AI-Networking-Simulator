import 'dart:js_interop';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web/web.dart' as web;

import 'env.dart';

/// Browser notification surface. Real impl uses the `Notification` JS API
/// via `dart:js_interop`. Mock logs to console — frontend dev can build
/// the permission-prompt UI without a deployed origin.
abstract class NotificationService {
  /// True if the user has previously granted notification permission.
  /// Implementations should return false on platforms without support.
  Future<bool> hasPermission();

  /// Triggers the browser permission prompt. Returns true if granted.
  Future<bool> requestPermission();

  /// Show a system notification. If the tab is focused, callers should
  /// prefer an in-app SnackBar instead (the scheduler handles that).
  Future<void> show({
    required String title,
    required String body,
    String? tag,
  });
}

class MockNotificationService implements NotificationService {
  bool _granted = true;

  @override
  Future<bool> hasPermission() async => _granted;

  @override
  Future<bool> requestPermission() async {
    _granted = true;
    debugPrint('[MockNotification] permission granted');
    return true;
  }

  @override
  Future<void> show({
    required String title,
    required String body,
    String? tag,
  }) async {
    debugPrint('[MockNotification] $title — $body${tag == null ? '' : ' ($tag)'}');
  }
}

/// Browser `Notification` API wrapper. Permission must be requested in
/// response to a user gesture or the browser silently denies — the home
/// shell triggers this via the first interaction.
class BrowserNotificationService implements NotificationService {
  @override
  Future<bool> hasPermission() async {
    try {
      return web.Notification.permission == 'granted';
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      final result = await web.Notification.requestPermission().toDart;
      return result.toDart == 'granted';
    } catch (e) {
      debugPrint('[BrowserNotification] requestPermission failed: $e');
      return false;
    }
  }

  @override
  Future<void> show({
    required String title,
    required String body,
    String? tag,
  }) async {
    try {
      final opts = web.NotificationOptions(body: body, tag: tag ?? '');
      web.Notification(title, opts);
    } catch (e) {
      debugPrint('[BrowserNotification] show failed: $e');
    }
  }
}

final notificationServiceProvider = Provider<NotificationService>((ref) {
  if (useMocks || !kIsWeb) return MockNotificationService();
  return BrowserNotificationService();
});
