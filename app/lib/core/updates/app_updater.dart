import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:velopack_flutter/velopack_flutter.dart';

class AppUpdater {
  AppUpdater._();

  static final AppUpdater instance = AppUpdater._();

  bool get isSupported => Platform.isWindows && !kDebugMode;

  Future<bool> checkForUpdates() async {
    if (!isSupported) return false;
    return isUpdateAvailable();
  }

  Future<void> downloadAndRestart() async {
    if (!isSupported) {
      throw UnsupportedError('Updates are available only in the installed Windows release.');
    }

    await for (final _ in checkAndDownloadUpdatesWithProgress()) {
      // Consume progress events while Velopack downloads the delta package.
    }
    await updateAndRestart();
  }

  String get installedVersion => currentVersion();
}
