# Architecture

## Decision

Chinazium Studio is a **local-first** application. The MVP runs without a VPS, hosted database, account system or permanent internet connection.

## Current foundation

- Flutter UI, initially targeting Windows.
- Dart application code.
- SQLite persistence through `sqflite_common_ffi` for desktop.
- Database file stored in the operating system's application support directory under `ChinaziumStudio/chinazium_studio.db`.
- Project domain model and repository layer.
- GitHub integration is optional and does not block core workflows.

## Layers

```text
Presentation (Flutter widgets)
        |
Feature modules
(Dashboard / Projects / Tasks / Roadmap / Documents / Assets)
        |
Repositories
        |
Local data sources (SQLite / filesystem)
```

Feature screens must not issue SQL queries directly. They call repositories. This keeps persistence isolated and makes future synchronization possible without coupling widgets to the database.

## Database

The initial schema contains a `projects` table. Project records use UUID identifiers and ISO-8601 timestamps. Schema changes must increment the database version and provide an explicit migration path; never discard an existing user's database to apply an update.

## Local files and backups

- The user controls the local project database and asset folders.
- Imported assets should be referenced by local paths rather than copied without consent.
- Add backup/export before implementing destructive bulk operations.
- Do not silently upload project content.

## Future integrations

### GitHub

GitHub is an optional integration, not the primary identity provider for the local MVP. Never embed a GitHub client secret or personal access token in the application binary or repository. Choose a secure OAuth/device flow or a small trusted broker when implementing the integration.

### Synchronization

A future sync service may synchronize selected projects between devices. Local IDs, conflict metadata, timestamps and deletion markers should be designed before sync is implemented. Do not add a server dependency to MVP features.

### iOS

The Flutter codebase should remain platform-neutral where practical. Desktop-specific database initialization must be isolated behind the database service. iOS build and device testing will be a later milestone and requires macOS/Xcode.
