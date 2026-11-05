import 'package:flutter/material.dart';

import '../projects/project.dart';
import '../projects/project_repository.dart';
import 'milestone.dart';
import 'milestone_repository.dart';

class RoadmapPage extends StatefulWidget {
  const RoadmapPage({
    super.key,
    required this.repository,
    required this.projects,
  });

  final MilestoneRepository repository;
  final ProjectRepository projects;

  @override
  State<RoadmapPage> createState() => _RoadmapPageState();
}

class _RoadmapPageState extends State<RoadmapPage> {
  late Future<List<Milestone>> _milestones;
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    _milestones = widget.repository.getAll();
  }

  Future<void> _edit([Milestone? milestone]) async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => _MilestoneEditor(
        repository: widget.repository,
        projects: widget.projects,
        milestone: milestone,
      ),
    );
    if (changed == true && mounted) setState(_reload);
  }

  Future<void> _delete(Milestone milestone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete milestone?'),
        content: Text('“${milestone.title}” will be deleted. Linked tasks will be kept, but detached from this milestone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.repository.delete(milestone.id);
      if (mounted) setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Roadmap', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('Plan milestones and track progress from completed tasks.',
                style: TextStyle(color: Color(0xFF8F9BAA))),
          ])),
          FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('New milestone')),
        ]),
        const SizedBox(height: 20),
        Wrap(spacing: 8, children: ['All', 'Planning', 'In progress', 'On hold', 'Completed'].map((value) =>
          ChoiceChip(label: Text(value), selected: _filter == value,
            onSelected: (_) => setState(() => _filter = value)).toList()),
        const SizedBox(height: 16),
        Expanded(child: FutureBuilder<List<Milestone>>(
          future: _milestones,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Center(child: Text('Could not load roadmap: ${snapshot.error}'));
            final all = snapshot.data ?? [];
            final items = _filter == 'All' ? all : all.where((m) => m.status == _filter).toList();
            if (items.isEmpty) {
              return Center(child: Card(child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.timeline_rounded, size: 44, color: Color(0xFF9B8FFF)),
                  const SizedBox(height: 12),
                  const Text('No milestones yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  const Text('Create milestones to organize your game development roadmap.',
                      style: TextStyle(color: Color(0xFF8F9BAA))),
                  const SizedBox(height: 16),
                  FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Create milestone')),
                ]),
              )));
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final m = items[index];
                final percent = (m.progress * 100).round();
                return Card(child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(m.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                      _StatusChip(status: m.status),
                      IconButton(tooltip: 'Edit', onPressed: () => _edit(m), icon: const Icon(Icons.edit_outlined)),
                      IconButton(tooltip: 'Delete', onPressed: () => _delete(m), icon: const Icon(Icons.delete_outline, color: Color(0xFFE07A84))),
                    ]),
                    if (m.description.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(m.description, style: const TextStyle(color: Color(0xFF9AA7B5))),
                    ],
                    const SizedBox(height: 14),
                    Row(children: [
                      Expanded(child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(value: m.progress, minHeight: 8),
                      )),
                      const SizedBox(width: 12),
                      Text('$percent%', style: const TextStyle(fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text('${m.completedTasks} / ${m.totalTasks} tasks completed',
                          style: const TextStyle(color: Color(0xFF8F9BAA), fontSize: 12)),
                      const Spacer(),
                      if (m.targetDate != null)
                        Text('Target: ${m.targetDate!.toLocal().toString().split(' ').first}',
                            style: const TextStyle(color: Color(0xFF8F9BAA), fontSize: 12)),
                    ]),
                  ]),
                ));
              },
            );
          },
        )),
      ]),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) => Chip(
    label: Text(status, style: const TextStyle(fontSize: 11)),
    visualDensity: VisualDensity.compact,
    side: BorderSide.none,
    backgroundColor: status == 'Completed'
        ? const Color(0xFF173D35)
        : status == 'On hold' ? const Color(0xFF3D3424) : const Color(0xFF292442),
  );
}

class _MilestoneEditor extends StatefulWidget {
  const _MilestoneEditor({required this.repository, required this.projects, this.milestone});
  final MilestoneRepository repository;
  final ProjectRepository projects;
  final Milestone? milestone;

  @override
  State<_MilestoneEditor> createState() => _MilestoneEditorState();
}

class _MilestoneEditorState extends State<_MilestoneEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _description;
  late String _status;
  String? _projectId;
  DateTime? _targetDate;
  bool _saving = false;

  static const _statuses = ['Planning', 'In progress', 'On hold', 'Completed'];

  @override
  void initState() {
    super.initState();
    final m = widget.milestone;
    _title = TextEditingController(text: m?.title ?? '');
    _description = TextEditingController(text: m?.description ?? '');
    _status = m?.status ?? 'Planning';
    _projectId = m?.projectId;
    _targetDate = m?.targetDate;
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
      final old = widget.milestone;
      if (old == null) {
        await widget.repository.create(projectId: _projectId, title: _title.text,
          description: _description.text, status: _status, targetDate: _targetDate);
      } else {
        await widget.repository.update(Milestone(
          id: old.id, projectId: _projectId, title: _title.text,
          description: _description.text, status: _status, targetDate: _targetDate,
          createdAt: old.createdAt, updatedAt: old.updatedAt,
        ));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save milestone: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.milestone == null ? 'New milestone' : 'Edit milestone'),
    content: SizedBox(width: 480, child: Form(
      key: _formKey,
      child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: _title, autofocus: true,
          decoration: const InputDecoration(labelText: 'Milestone title *'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null),
        const SizedBox(height: 12),
        TextFormField(controller: _description, minLines: 2, maxLines: 4,
          decoration: const InputDecoration(labelText: 'Description')),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _status, decoration: const InputDecoration(labelText: 'Status'),
          items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: (v) => setState(() => _status = v ?? 'Planning')),
        const SizedBox(height: 12),
        FutureBuilder<List<Project>>(
          future: widget.projects.getAll(),
          builder: (context, snapshot) {
            final projects = snapshot.data ?? [];
            final selected = projects.any((p) => p.id == _projectId) ? _projectId : null;
            return DropdownButtonFormField<String?>(
              initialValue: selected, decoration: const InputDecoration(labelText: 'Project (optional)'),
              items: [const DropdownMenuItem<String?>(value: null, child: Text('All projects')),
                ...projects.map((p) => DropdownMenuItem<String?>(value: p.id, child: Text(p.name)))],
              onChanged: (v) => setState(() => _projectId = v));
          }),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: Text(_targetDate == null ? 'No target date' :
            'Target: ${_targetDate!.toLocal().toString().split(' ').first}')),
          TextButton.icon(onPressed: () async {
            final date = await showDatePicker(context: context,
              initialDate: _targetDate ?? DateTime.now(),
              firstDate: DateTime(2020), lastDate: DateTime(2100));
            if (date != null) setState(() => _targetDate = date);
          }, icon: const Icon(Icons.calendar_today_outlined), label: const Text('Choose date')),
          if (_targetDate != null) IconButton(onPressed: () => setState(() => _targetDate = null),
            icon: const Icon(Icons.close)),
        ]),
      ])),
    )),
    actions: [
      TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: const Text('Cancel')),
      FilledButton(onPressed: _saving ? null : _save, child: _saving
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : const Text('Save milestone')),
    ],
  );
}
