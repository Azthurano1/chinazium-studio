import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:velopack_flutter/velopack_flutter.dart';

class AppUpdater {
  AppUpdater._();

  static final AppUpdater instance = AppUpdater._();

  static const _repository = 'Azthurano1/chinazium-studio';
  static const _releaseApi =
      'https://api.github.com/repos/$_repository/releases/latest';
  static const _releaseDownloadBase =
      'https://github.com/$_repository/releases/download/';

  bool _initialized = false;
  String? _initializationError;

  bool get isSupported => Platform.isWindows && !kDebugMode && _initialized;

  String get initializationError =>
      _initializationError ?? 'The updater is not initialized.';

  Future<String> get installedVersion async {
    if (!isSupported) return 'Development build';
    try {
      return await currentVersion();
    } catch (_) {
      return 'Velopack installation required';
    }
  }

  Future<void> initialize(List<String> args) async {
    if (!Platform.isWindows || kDebugMode) return;

    try {
      final response = await http.get(
        Uri.parse(_releaseApi),
        headers: const {
          'Accept': 'application/vnd.github+json',
          'X-GitHub-Api-Version': '2022-11-28',
          'User-Agent': 'Chinazium-Studio-Updater',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw HttpException(
          'GitHub Releases returned HTTP ${response.statusCode}.',
        );
      }

      final release = jsonDecode(response.body) as Map<String, dynamic>;
      final tag = release['tag_name'] as String?;
      if (tag == null || tag.isEmpty) {
        throw const FormatException('Latest GitHub Release has no tag_name.');
      }

      await initializeVelopack(url: '$_releaseDownloadBase$tag/');
      _initialized = true;
      _initializationError = null;
    } catch (error) {
      _initializationError = error.toString();
      // Updates must never prevent the workspace from starting.
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
    if (!isSupported) {
      throw StateError(
        'The updater is unavailable. Install Chinazium Studio using the '
        'Velopack Setup.exe from GitHub Releases. '
        'Details: $initializationError',
      );
    }
    return isUpdateAvailable();
  }

  Future<void> downloadAndRestart() async {
    if (!isSupported) {
      throw UnsupportedError(
        'Updates require an installed Windows release from the Velopack installer.',
      );
    }

    await for (final _ in checkAndDownloadUpdatesWithProgress()) {
      // Consume Velopack progress events until the delta/full package is ready.
    }
    await updateAndRestart();
  }
}
