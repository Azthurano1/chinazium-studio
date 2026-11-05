import 'package:flutter/material.dart';

import '../projects/project.dart';
import '../projects/project_repository.dart';
import 'studio_task.dart';
import 'task_repository.dart';
import '../roadmap/milestone.dart';
import '../roadmap/milestone_repository.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({
    super.key,
    required this.repository,
    required this.projects,
  });

  final TaskRepository repository;
  final ProjectRepository projects;
  final MilestoneRepository milestones = MilestoneRepository();

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  late Future<List<StudioTask>> _tasks;
  String _filter = 'All';

  static const _filters = ['All', 'Todo', 'In progress', 'Done'];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _tasks = widget.repository.getAll(
      status: _filter == 'All' ? null : _filter,
    );
  }

  Future<void> _edit([StudioTask? task]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _TaskEditor(
        repository: widget.repository,
        projectsRepository: widget.projects,
        milestonesRepository: widget.milestones,
        task: task,
      ),
    );
    if (changed == true && mounted) setState(_reload);
  }

  Future<void> _delete(StudioTask task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be permanently deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.repository.delete(task.id);
      if (mounted) setState(_reload);
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
                    Text('Tasks', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                    SizedBox(height: 6),
                    Text('Plan, prioritize and track your development work.',
                      style: TextStyle(color: Color(0xFF8F9BAA))),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => _edit(),
                icon: const Icon(Icons.add),
                label: const Text('New task'),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Wrap(
            spacing: 8,
            children: _filters.map((filter) => ChoiceChip(
              label: Text(filter),
              selected: _filter == filter,
              onSelected: (_) => setState(() {
                _filter = filter;
                _reload();
              }),
            )).toList(),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: FutureBuilder<List<StudioTask>>(
              future: _tasks,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Could not load tasks: ${snapshot.error}'));
                }
                final tasks = snapshot.data ?? [];
                if (tasks.isEmpty) {
                  return Center(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.task_alt, size: 42, color: Color(0xFF9B8FFF)),
                            const SizedBox(height: 12),
                            Text(_filter == 'All' ? 'No tasks yet' : 'No tasks in this status',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            const Text('Create a task to plan your next development step.',
                              style: TextStyle(color: Color(0xFF8F9BAA))),
                            const SizedBox(height: 16),
                            FilledButton.icon(
                              onPressed: () => _edit(),
                              icon: const Icon(Icons.add),
                              label: const Text('Create task'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    final done = task.status == 'Done';
                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: done,
                          onChanged: (value) async {
                            await widget.repository.update(StudioTask(
                              id: task.id,
                              title: task.title,
                              description: task.description,
                              status: value == true ? 'Done' : 'Todo',
                              priority: task.priority,
                              projectId: task.projectId,
                              milestoneId: task.milestoneId,
                              dueDate: task.dueDate,
                              createdAt: task.createdAt,
                              updatedAt: task.updatedAt,
                            ));
                            if (mounted) setState(_reload);
                          },
                        ),
                        title: Text(task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: done ? TextDecoration.lineThrough : null,
                            color: done ? Colors.white54 : null,
                          )),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text([
                            task.status,
                            '${task.priority} priority',
                            if (task.dueDate != null) 'Due ${task.dueDate!.toLocal().toString().split(' ').first}',
                          ].join('  •  ')),
                        ),
                        trailing: Wrap(
                          spacing: 0,
                          children: [
                            IconButton(
                              tooltip: 'Edit',
                              onPressed: () => _edit(task),
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              tooltip: 'Delete',
                              onPressed: () => _delete(task),
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

class _TaskEditor extends StatefulWidget {
  const _TaskEditor({
    required this.repository,
    required this.projectsRepository,
    required this.milestonesRepository,
    this.task,
  });

  final TaskRepository repository;
  final ProjectRepository projectsRepository;
  final MilestoneRepository milestonesRepository;
  final StudioTask? task;

  @override
  State<_TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends State<_TaskEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _status;
  late String _priority;
  String? _projectId;
  String? _milestoneId;
  DateTime? _dueDate;
  bool _saving = false;

  static const _statuses = ['Todo', 'In progress', 'Done'];
  static const _priorities = ['Low', 'Medium', 'High'];

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _title = TextEditingController(text: task?.title ?? '');
    _description = TextEditingController(text: task?.description ?? '');
    _status = task?.status ?? 'Todo';
    _priority = task?.priority ?? 'Medium';
    _projectId = task?.projectId;
    _milestoneId = task?.milestoneId;
    _dueDate = task?.dueDate;
  }

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      if (widget.task == null) {
        await widget.repository.create(
          title: _title.text,
          description: _description.text,
          status: _status,
          priority: _priority,
          projectId: _projectId,
          milestoneId: _milestoneId,
          dueDate: _dueDate,
        );
      } else {
        final old = widget.task!;
        await widget.repository.update(StudioTask(
          id: old.id,
          title: _title.text,
          description: _description.text,
          status: _status,
          priority: _priority,
          projectId: _projectId,
          milestoneId: _milestoneId,
          dueDate: _dueDate,
          createdAt: old.createdAt,
          updatedAt: old.updatedAt,
        ));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save task: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'New task' : 'Edit task'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _title,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Task title *'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? 'Enter a task title'
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
                DropdownButtonFormField<String>(
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: _statuses.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => _status = v ?? 'Todo'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: _priorities.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                  onChanged: (v) => setState(() => _priority = v ?? 'Medium'),
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Project>>(
                  future: widget.projectsRepository.getAll(),
                  builder: (context, snapshot) {
                    final projects = snapshot.data ?? [];
                    final selected = projects.any((p) => p.id == _projectId) ? _projectId : null;
                    return DropdownButtonFormField<String?>(
                      initialValue: selected,
                      decoration: const InputDecoration(labelText: 'Project (optional)'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('No project')),
                        ...projects.map((p) => DropdownMenuItem<String?>(value: p.id, child: Text(p.name))),
                      ],
                      onChanged: (v) => setState(() => _projectId = v),
                    );
                  },
                ),
                const SizedBox(height: 12),
                FutureBuilder<List<Milestone>>(
                  future: widget.milestonesRepository.getAll(
                    projectId: _projectId,
                  ),
                  builder: (context, snapshot) {
                    final items = snapshot.data ?? [];
                    final selected = items.any((m) => m.id == _milestoneId)
                        ? _milestoneId
                        : null;
                    return DropdownButtonFormField<String?>(
                      initialValue: selected,
                      decoration: const InputDecoration(labelText: 'Milestone (optional)'),
                      items: [
                        const DropdownMenuItem<String?>(value: null, child: Text('No milestone')),
                        ...items.map((m) => DropdownMenuItem<String?>(
                          value: m.id, child: Text(m.title))),
                      ],
                      onChanged: (value) => setState(() => _milestoneId = value),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(_dueDate == null
                          ? 'No due date'
                          : 'Due: ${_dueDate!.toLocal().toString().split(' ').first}'),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final selected = await showDatePicker(
                          context: context,
                          initialDate: _dueDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (selected != null) setState(() => _dueDate = selected);
                      },
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: const Text('Choose date'),
                    ),
                    if (_dueDate != null)
                      IconButton(
                        tooltip: 'Clear date',
                        onPressed: () => setState(() => _dueDate = null),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save task'),
        ),
      ],
    );
  }
}
