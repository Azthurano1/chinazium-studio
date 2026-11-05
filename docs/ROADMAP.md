# Roadmap

## Phase 0 — Foundation

- [x] Create the repository and product documentation.
- [x] Establish the Flutter desktop application shell and dark theme.
- [x] Add local SQLite database initialization.
- [x] Add the first Projects CRUD workflow.
- [x] Persist project records between application launches.
- [x] Show the real project count on the Dashboard.
- [ ] Run Flutter analysis and Windows smoke tests on a developer machine.

## Phase 1 — Core project management

- [ ] Project detail page and project overview.
- [x] Tasks CRUD with priorities, statuses, due dates and descriptions.
- [ ] Subtasks and task-to-project relationships.
- [ ] Subtasks and task-to-project relationships.
- [ ] Roadmap milestones and milestone status.
- [ ] Dashboard statistics backed by stored data.
- [ ] Search, sorting and filtering.

## Phase 2 — Knowledge and production tracking

- [ ] GDD and document editor with Markdown support.
- [ ] Asset catalog with local file references and tags.
- [ ] Software/tool registry per project.
- [ ] Activity history.
- [ ] Backup and restore for the local database and project metadata.

## Phase 3 — Integrations

- [x] Public GitHub Issues browser with open/closed filters and issue metadata.
- [ ] Persist repository links per project and map Issues to local tasks.
- [ ] GitHub Pull Request references.
- [ ] Safe authentication flow; no embedded secrets or committed tokens.
- [ ] Optional export/import format.

## Phase 4 — Quality and portability

- [ ] Automated unit and widget tests.
- [ ] Accessibility and responsive layout review.
- [ ] Windows installer and release packaging.
- [ ] iOS support and device testing (requires macOS/Xcode).
- [ ] Evaluate optional sync without making a server mandatory.
