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
