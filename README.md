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
- Task status, priority, optional project association and due date.
- SQLite schema migration from the initial projects database.

The app is an actively developed MVP. Tasks, roadmap, documents, assets, GitHub integration, backup/restore and release packaging are not implemented yet.

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


## Windows releases

Windows release builds are published in the GitHub [Releases](https://github.com/Azthurano1/chinazium-studio/releases) page.

The workflow `.github/workflows/release-windows.yml`:
- builds the Windows x64 app in GitHub Actions;
- runs `flutter analyze` and `flutter test` before packaging;
- attaches a ZIP containing the complete Windows app bundle;
- also attaches the application executable as a convenience.

To publish a version, create and push a version tag, for example:

```powershell
git tag v0.2.0
git push origin v0.2.0
```

A release can also be started manually from the repository's **Actions → Build Windows Release → Run workflow** page. Enter a new version tag such as `v0.2.1`.

**Important:** download and extract `ChinaziumStudio-Windows-x64.zip`, then run the `.exe` from the extracted folder. The standalone executable is not sufficient by itself because Flutter also needs the bundled runtime DLLs and data directory.
