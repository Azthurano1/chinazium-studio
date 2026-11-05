# Product Specification — MVP

## Product vision

One workspace for planning and organizing game development, from concept to release. The application must support multiple games, including Chinazium, without being hard-coded around a single title.

## Target users

Initially a solo game developer. The data model should not prevent future collaboration, but multi-user collaboration is out of MVP scope.

## Primary navigation

- Dashboard
- Projects
- Tasks
- Roadmap
- Documents
- Assets
- Software
- Settings

## Functional requirements

### Dashboard
Show project count, open tasks, milestones, asset totals and recent activity. All figures must come from local data, not hard-coded demo values.

### Projects
Create and manage multiple projects. Each project has a name, short description, status, optional cover, creation/update timestamps and its own tasks, roadmap, documents and assets.

### Tasks
Tasks support title, description, status, priority, category, due date, optional milestone, subtasks and relationships to other tasks. Initial statuses: Backlog, To do, In progress, Review, Done. Initial priorities: Low, Medium, High, Critical.

### Roadmap
Milestones have a title, description, target date, status and associated tasks. Show progress calculated from linked tasks.

### Documents
Store Markdown documents and organize them by project and document type. Initial types: GDD, narrative, character, location, mechanics, technical design and notes.

### Assets
Catalog references to files rather than copying large files by default. Initial types: 3D model, texture, material, animation, audio, music, concept art, UI and VFX. Track status, source application, version and local file path.

### Software
Maintain a per-user catalog of tools and versions, such as Unreal Engine, Blender, Substance 3D Painter, Krita and REAPER. Link tools to projects and tasks.

### GitHub
Optional integration. Link a project to one or more repositories and link tasks to Issues or Pull Requests. Core project management must work if GitHub is disconnected.

## Non-functional requirements

- Local-first and offline-capable.
- Dark theme as the initial visual theme.
- Responsive layout: desktop first, mobile later.
- No credentials or secrets committed to source control.
- Export/backup before destructive database operations.
- Clear empty, loading and error states.
