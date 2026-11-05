# Chinazium Studio

**Chinazium Studio** is a local-first desktop application for planning and managing game development projects — from the first idea to release.

The first target is **Windows**. The application is being built with Flutter and Dart, with a shared codebase intended to support iOS later.

## Current status

**Version:** 0.1.0 (foundation)  
**Stage:** Project setup and MVP foundation  
**Backend:** None — local development only  
**Database:** SQLite is planned for the next implementation step

## MVP scope

- Dashboard with project and task overview
- Multiple game projects
- Tasks, priorities, statuses, due dates and subtasks
- Roadmap with milestones
- Categories and software/tool catalog
- Markdown design documents
- Asset catalog for models, textures, animation, audio and other game assets
- Optional GitHub repository integration

## Technology

| Area | Choice |
|---|---|
| UI | Flutter / Dart |
| Desktop target | Windows |
| Future mobile target | iOS |
| Local database | SQLite via Drift (planned) |
| Local files | User-selected folders |
| Source control | Git / GitHub |
| Backend | Not required for the local MVP |

## Repository layout

```text
app/                 Flutter application
docs/                Product and technical documentation
assets/              Application assets
```

## Development

1. Install Git.
2. Install Flutter SDK.
3. Install Visual Studio 2022 with **Desktop development with C++**.
4. Install VS Code and the Flutter and Dart extensions.
5. Run:

```powershell
cd app
flutter pub get
flutter run -d windows
```

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for the Windows setup checklist.

## Product principles

- Local-first: core features must work without an account or internet connection.
- User-owned data: projects and documents remain on the user's device.
- Modular architecture: future sync and integrations must not be coupled to UI code.
- No secrets in the client: GitHub credentials must never be hard-coded or committed.
- Cross-platform by design, desktop-first in implementation.
