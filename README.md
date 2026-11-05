# Chinazium Studio

Chinazium Studio is a local-first workspace for planning and managing game development. It is designed to keep game design documents, production tasks, milestones, assets and development tools organized in one place.

## Product principles

- Local-first: the core application works without a hosted service or account.
- User-owned data: project data is stored on the user's computer.
- Modular: features are separated so the application can grow without becoming one large screen.
- Optional integrations: GitHub and future sync features must never block local workflows.
- Safe by default: never commit credentials, tokens or private keys.

## Current implementation

- Flutter desktop application shell with a dark theme.
- Local SQLite database.
- Projects list with create, edit and delete operations.
- Project fields: name, description, genre, engine and status.
- Dashboard project count backed by SQLite.
- Tasks module with create, edit and delete operations.
- GitHub Issues browser for public repositories, including open/closed filters, labels, authors and issue links. No token is required for public repositories.
- Task status, priority, optional project association and due date.
- SQLite schema migration from the initial projects database.

The app is under active development. The Tasks module supports local task management. GitHub Issues can be viewed as a live task list for public repositories. Roadmap, document editing, asset catalog, software registry, backup/restore and hosted multi-device synchronization are still in development.

## Repository layout

```text
app/       Flutter application
docs/      Product, architecture and development documentation
```

## Requirements

- Flutter SDK (stable channel)
- Windows desktop development support enabled
- Git

## Run on Windows

From PowerShell:

```powershell
cd app
flutter doctor
flutter config --enable-windows-desktop
flutter pub get
flutter create --platforms=windows .
flutter run -d windows
```

Run `flutter analyze` before submitting changes.

## Local data

The SQLite database is created in the operating system's application support directory, inside the `ChinaziumStudio` folder. The database file is named `chinazium_studio.db`.

## Documentation

- [Product specification](docs/PRODUCT_SPEC.md)
- [Architecture](docs/ARCHITECTURE.md)
- [Roadmap](docs/ROADMAP.md)
- [Development guide](docs/DEVELOPMENT.md)


## Windows releases and automatic updates

Windows builds are compiled in GitHub Actions after each commit to `main`. The workflow runs static analysis and tests, builds the Flutter Windows application, packages it with Velopack, generates differential update packages when a previous Velopack release is available, and publishes the installer and update metadata to GitHub Releases.

- First installation: download and run `ChinaziumStudio-Setup.exe` from [GitHub Releases](https://github.com/Azthurano1/chinazium-studio/releases).
- Later updates: open **Settings → Check for updates**. Velopack downloads a delta package when it is smaller and suitable, then restarts the application to apply it.
- The first Velopack release is a full package. Subsequent releases can include delta packages. Velopack may fall back to a full package when a delta is unavailable or larger.

The updater requires the repository and its Releases to be public. The application must be installed using the Velopack Setup installer; running an older extracted ZIP or launching from Flutter debug mode does not enable in-app updates.

The updater is implemented with the `velopack_flutter` package. Rust is required by its native bridge and is installed in the Windows release workflow.
