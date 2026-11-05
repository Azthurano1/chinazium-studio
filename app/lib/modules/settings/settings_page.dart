import 'package:flutter/material.dart';

import '../../core/updates/app_updater.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _checking = false;
  bool _updateAvailable = false;
  String? _message;

  Future<void> _checkUpdates() async {
    setState(() {
      _checking = true;
      _message = 'Checking GitHub Releases…';
    });

    try {
      final available = await AppUpdater.instance.checkForUpdates();
      if (!mounted) return;
      setState(() {
        _updateAvailable = available;
        _message = available
            ? 'A new version is available. You can download the update now.'
            : 'You are using the latest version.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _message = 'Could not check for updates: $error');
    } finally {
      if (mounted) setState(() => _checking = false);
    }
  }

  Future<void> _installUpdate() async {
    setState(() {
      _checking = true;
      _message = 'Downloading update. The application will restart when ready…';
    });

    try {
      await AppUpdater.instance.downloadAndRestart();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _checking = false;
        _message = 'Update failed: $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final updaterSupported = AppUpdater.instance.isSupported;

    return ListView(
      padding: const EdgeInsets.all(28),
      children: [
        const Text('Settings', style: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Application preferences and update management.',
          style: TextStyle(color: Color(0xFF8F9BAA))),
        const SizedBox(height: 24),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.system_update_alt, color: Color(0xFF9B8FFF)),
                  SizedBox(width: 10),
                  Text('Application updates', style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 14),
                FutureBuilder<String>(
                  future: AppUpdater.instance.installedVersion,
                  builder: (context, snapshot) => Text(
                    'Installed version: ${snapshot.data ?? 'Loading…'}',
                    style: const TextStyle(color: Color(0xFFB6C0CC)),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Updates are distributed through public GitHub Releases. '
                  'When available, Velopack downloads a differential package '
                  'and restarts the application to install it. The first update requires installing the Velopack Setup.exe once.',
                  style: TextStyle(color: Color(0xFF8F9BAA), height: 1.5)),
                const SizedBox(height: 18),
                if (!updaterSupported)
                  const Text(
                    'The updater is enabled in installed Windows releases. '
                    'It is disabled while running in debug mode.',
                    style: TextStyle(color: Color(0xFFE0B566))),
                if (_message != null) ...[
                  const SizedBox(height: 12),
                  Text(_message!, style: const TextStyle(
                    color: Color(0xFFB6C0CC))),
                ],
                const SizedBox(height: 16),
                Wrap(spacing: 10, children: [
                  OutlinedButton.icon(
                    onPressed: _checking || !updaterSupported ? null : _checkUpdates,
                    icon: _checking
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.refresh),
                    label: const Text('Check for updates'),
                  ),
                  if (_updateAvailable)
                    FilledButton.icon(
                      onPressed: _checking ? null : _installUpdate,
                      icon: const Icon(Icons.download),
                      label: const Text('Download and restart'),
                    ),
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
