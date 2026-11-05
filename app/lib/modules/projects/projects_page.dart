import 'package:flutter/material.dart';

import 'project.dart';
import 'project_repository.dart';

class ProjectsPage extends StatefulWidget {
  const ProjectsPage({super.key, required this.repository, required this.onChanged});

  final ProjectRepository repository;
  final VoidCallback onChanged;

  @override
  State<ProjectsPage> createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<List<Project>> _projects;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _projects = widget.repository.getAll();
  }

  Future<void> _openEditor([Project? project]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _ProjectEditor(repository: widget.repository, project: project),
    );
    if (result == true && mounted) {
      setState(_reload);
      widget.onChanged();
    }
  }

  Future<void> _delete(Project project) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete project?'),
        content: Text('“${project.name}” will be permanently removed from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB94B58)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.repository.delete(project.id);
      if (mounted) {
        setState(_reload);
        widget.onChanged();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Projects', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text('Your games, prototypes and interactive projects.',
                      style: TextStyle(color: Color(0xFF8F9BAA))),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openEditor(),
                icon: const Icon(Icons.add),
                label: const Text('New project'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: FutureBuilder<List<Project>>(
              future: _projects,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Could not load projects: ${snapshot.error}'));
                }
                final projects = snapshot.data ?? [];
                if (projects.isEmpty) {
                  return Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(34),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.folder_open_outlined, size: 44, color: Color(0xFF9B8FFF)),
                            const SizedBox(height: 14),
                            const Text('No projects yet', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 7),
                            const Text('Create a project to start organizing its development.',
                              style: TextStyle(color: Color(0xFF8F9BAA))),
                            const SizedBox(height: 18),
                            FilledButton.icon(
                              onPressed: () => _openEditor(),
                              icon: const Icon(Icons.add),
                              label: const Text('Create project'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: projects.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFF302B50),
                          child: Icon(Icons.sports_esports_outlined, color: Color(0xFFB5AAFF)),
                        ),
                        title: Text(project.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text([
                            if (project.genre.isNotEmpty) project.genre,
                            if (project.engine.isNotEmpty) project.engine,
                            project.status,
                          ].join('  •  ')),
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _openEditor(project),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => _delete(project),
                              icon: const Icon(Icons.delete_outline, color: Color(0xFFE07A84)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectEditor extends StatefulWidget {
  const _ProjectEditor({required this.repository, this.project});

  final ProjectRepository repository;
  final Project? project;

  @override
  State<_ProjectEditor> createState() => _ProjectEditorState();
}

class _ProjectEditorState extends State<_ProjectEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _genre;
  late final TextEditingController _engine;
  late String _status;
  bool _saving = false;

  static const _statuses = ['Planning', 'In development', 'On hold', 'Released'];

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _name = TextEditingController(text: project?.name ?? '');
    _description = TextEditingController(text: project?.description ?? '');
    _genre = TextEditingController(text: project?.genre ?? '');
    _engine = TextEditingController(text: project?.engine ?? '');
    _status = project?.status ?? _statuses.first;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _genre.dispose();
    _engine.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (widget.project == null) {
        await widget.repository.create(
          name: _name.text,
          description: _description.text,
          genre: _genre.text,
          engine: _engine.text,
          status: _status,
        );
      } else {
        final old = widget.project!;
        await widget.repository.update(Project(
          id: old.id,
          name: _name.text,
          description: _description.text,
          genre: _genre.text,
          engine: _engine.text,
          status: _status,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        ));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save project: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.project == null ? 'New project' : 'Edit project'),
      content: SizedBox(
        width: 460,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Project name *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a project name'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _description,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _genre, decoration: const InputDecoration(labelText: 'Genre')),
                const SizedBox(height: 12),
                TextFormField(controller: _engine, decoration: const InputDecoration(labelText: 'Game engine')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: _statuses.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                  onChanged: (value) => setState(() => _status = value ?? _statuses.first),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save project'),
        ),
      ],
    );
  }
}
