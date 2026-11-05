import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:velopack_flutter/velopack_flutter.dart';

class AppUpdater {
  AppUpdater._();

  static final AppUpdater instance = AppUpdater._();
  bool _initialized = false;

  bool get isSupported => Platform.isWindows && !kDebugMode && _initialized;

  String get installedVersion {
    if (!isSupported) return 'Development build';
    try {
      return currentVersion();
    } catch (_) {
      return 'Not installed with the Chinazium Studio installer';
    }
  }

  Future<void> initialize(List<String> args) async {
    if (!Platform.isWindows || kDebugMode) return;

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/Azthurano1/chinazium-studio/releases/latest'),
        headers: const {'Accept': 'application/vnd.github+json'},
      );
      if (response.statusCode == 200) {
        final release = jsonDecode(response.body) as Map<String, dynamic>;
        final tag = release['tag_name'] as String?;
        if (tag != null && tag.isNotEmpty) {
          await initializeVelopack(
            url: 'https://github.com/Azthurano1/chinazium-studio/releases/download/$tag/',
          );
          _initialized = true;
        }
      }
    } catch (_) {
      // Do not prevent startup when GitHub is temporarily unavailable.
    }

    const veloCommands = [
      '--veloapp-install',
      '--veloapp-updated',
      '--veloapp-obsolete',
      '--veloapp-uninstall',
    ];
    if (veloCommands.any(args.contains)) exit(0);
  }

  Future<bool> checkForUpdates() async {
    if (!isSupported) return false;
    return isUpdateAvailable();
  }

  Future<void> downloadAndRestart() async {
    if (!isSupported) {
      throw UnsupportedError(
        'Updates require an installed Windows release from the Velopack installer.',
      );
    }

    await for (final _ in checkAndDownloadUpdatesWithProgress()) {
      // Consume progress events while Velopack downloads the delta package.
    }
    await updateAndRestart();
  }
}
