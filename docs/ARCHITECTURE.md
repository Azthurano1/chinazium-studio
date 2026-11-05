# Architecture

## Decision

Chinazium Studio is a **local-first** application. The MVP must run without a VPS, hosted database, account system or permanent internet connection.

## Current foundation

- Flutter UI, initially targeting Windows.
- Dart application code.
- Local persistence will use SQLite through Drift.
- User documents and imported assets will be stored in user-selected local folders.
- GitHub integration is optional and must not block core workflows.

## Planned layers

```text
Presentation (Flutter widgets)
        |
Feature modules
(Dashboard / Projects / Tasks / Roadmap / Documents / Assets)
        |
Application services
        |
Repositories (interfaces)
        |
Local data sources (SQLite / filesystem)
```

Feature screens must not issue SQL queries directly. They call application services or repositories. This keeps persistence replaceable and makes future sync possible.

## Future integrations

### GitHub

GitHub is an optional integration, not the primary identity provider for the local MVP. Never embed a GitHub client secret or personal access token in the application binary or repository. Choose a secure OAuth/device flow or a small trusted broker when implementing the integration.

### Synchronization

A future sync service may synchronize selected projects between devices. Local IDs, conflict metadata, timestamps and deletion markers should be designed before sync is implemented. Do not add a server dependency to MVP features.

### iOS

The Flutter codebase should remain platform-neutral where practical. Windows-specific filesystem operations must be isolated behind services. iOS build and device testing will be a later milestone and requires macOS/Xcode.

## Data ownership

- The user controls the local project database and asset folders.
- Provide backup/export before implementing destructive bulk operations.
- Do not silently upload project content.
