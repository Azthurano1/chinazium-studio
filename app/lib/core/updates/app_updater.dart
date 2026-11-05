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
  String? _releaseTag;

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

  /// Resolve the current stable GitHub release and point Velopack at its
  /// immutable asset directory. This must also run when the user presses
  /// "Check for updates": a release may have been published after app startup.
  Future<void> _refreshReleaseSource() async {
    final response = await http.get(
      Uri.parse(_releaseApi),
      headers: const {
        'Accept': 'application/vnd.github+json',
        'X-GitHub-Api-Version': '2022-11-28',
        'User-Agent': 'Chinazium-Studio-Updater',
        'Cache-Control': 'no-cache',
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

    // Do not keep checking the release URL captured at the previous launch.
    // GitHub Releases are immutable per tag, so a changed tag means a new feed.
    if (!_initialized || tag != _releaseTag) {
      await initializeVelopack(url: '$_releaseDownloadBase$tag/');
      _releaseTag = tag;
      _initialized = true;
    }

    _initializationError = null;
  }

  Future<void> initialize(List<String> args) async {
    if (!Platform.isWindows || kDebugMode) return;

    try {
      await _refreshReleaseSource();
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
    if (!Platform.isWindows || kDebugMode) {
      throw StateError(
        'The updater is available only in an installed Windows release.',
      );
    }

    // Refresh on every manual check. If a new release appeared while the app
    // was running, Velopack now checks that release instead of the old tag.
    await _refreshReleaseSource();
    return isUpdateAvailable();
  }

  Future<void> downloadAndRestart() async {
    if (!Platform.isWindows || kDebugMode) {
      throw UnsupportedError(
        'Updates require an installed Windows release from the Velopack installer.',
      );
    }

    await _refreshReleaseSource();
    await for (final _ in checkAndDownloadUpdatesWithProgress()) {
      // Consume Velopack progress events until the delta/full package is ready.
    }
    await updateAndRestart();
  }
}
