import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../projects/project.dart';
import '../projects/project_repository.dart';
import 'document_repository.dart';
import 'studio_document.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key, required this.repository, required this.projects});

  final DocumentRepository repository;
  final ProjectRepository projects;

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final _search = TextEditingController();
  String? _projectFilter;
  String _categoryFilter = 'All';
  late Future<List<StudioDocument>> _documents;

  static const _categories = ['All', 'GDD', 'Narrative', 'Character', 'World', 'Mechanics', 'Level', 'Technical', 'General'];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _reload() {
    _documents = widget.repository.getAll(projectId: _projectFilter, query: _search.text);
  }

  Future<void> _edit([StudioDocument? document]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => _DocumentEditor(repository: widget.repository, projects: widget.projects, document: document),
    );
    if (result == true && mounted) setState(_reload);
  }

  Future<void> _delete(StudioDocument document) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('“${document.title}” will be permanently deleted.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.repository.delete(document.id);
      if (mounted) setState(_reload);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(26),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Documents', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            SizedBox(height: 5),
            Text('Game design documents, narrative and production notes.', style: TextStyle(color: Color(0xFF8F9BAA))),
          ])),
          FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('New document')),
        ]),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: TextField(
            controller: _search,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search title and content', isDense: true),
            onChanged: (_) => setState(_reload),
          )),
          const SizedBox(width: 12),
          SizedBox(width: 220, child: FutureBuilder<List<Project>>(
            future: widget.projects.getAll(),
            builder: (context, snapshot) {
              final projects = snapshot.data ?? [];
              return DropdownButtonFormField<String?>(
                initialValue: _projectFilter,
                decoration: const InputDecoration(labelText: 'Project', isDense: true),
                items: [
                  const DropdownMenuItem<String?>(value: null, child: Text('All projects')),
                  ...projects.map((p) => DropdownMenuItem<String?>(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis))),
                ],
                onChanged: (value) => setState(() { _projectFilter = value; _reload(); }),
              );
            },
          )),
        ]),
        const SizedBox(height: 12),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(
          children: _categories.map((category) => Padding(
            padding: const EdgeInsets.only(right: 7),
            child: ChoiceChip(label: Text(category), selected: _categoryFilter == category,
              onSelected: (_) => setState(() => _categoryFilter = category)),
          )).toList(),
        )),
        const SizedBox(height: 12),
        Expanded(child: FutureBuilder<List<StudioDocument>>(
          future: _documents,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text('Could not load documents: ${snapshot.error}'));
            final all = snapshot.data ?? [];
            final docs = _categoryFilter == 'All' ? all : all.where((d) => d.category == _categoryFilter).toList();
            if (docs.isEmpty) {
              return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.description_outlined, size: 48, color: Color(0xFF8B7CFF)),
                const SizedBox(height: 12),
                const Text('No documents yet', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('Create a GDD, character sheet, level brief or technical note.', style: TextStyle(color: Color(0xFF8F9BAA))),
                const SizedBox(height: 16),
                FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add), label: const Text('Create document')),
              ]));
            }
            return LayoutBuilder(builder: (context, constraints) {
              final columns = constraints.maxWidth > 1050 ? 3 : constraints.maxWidth > 680 ? 2 : 1;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns, crossAxisSpacing: 12, mainAxisSpacing: 12,
                  childAspectRatio: columns == 1 ? 3.1 : 1.65,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  return Card(child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => _edit(doc),
                    child: Padding(padding: const EdgeInsets.all(17), child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.article_outlined, color: Color(0xFF9B8FFF), size: 19),
                          const SizedBox(width: 8),
                          Expanded(child: Text(doc.category.toUpperCase(), style: const TextStyle(color: Color(0xFF9B8FFF), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1))),
                          IconButton(tooltip: 'Delete', visualDensity: VisualDensity.compact, onPressed: () => _delete(doc), icon: const Icon(Icons.delete_outline, size: 18)),
                        ]),
                        const SizedBox(height: 5),
                        Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 7),
                        Expanded(child: Text(doc.content.replaceAll(RegExp(r'[#*_>`-]'), '').replaceAll('\n', ' '),
                          maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF9AA7B5), height: 1.4))),
                        Text('Updated ${doc.updatedAt.toLocal().toString().split(' ').first}',
                          style: const TextStyle(color: Color(0xFF748091), fontSize: 11)),
                      ],
                    )),
                  ));
                },
              );
            });
          },
        )),
      ]),
    );
  }
}

class _DocumentEditor extends StatefulWidget {
  const _DocumentEditor({required this.repository, required this.projects, this.document});
  final DocumentRepository repository;
  final ProjectRepository projects;
  final StudioDocument? document;

  @override
  State<_DocumentEditor> createState() => _DocumentEditorState();
}

class _DocumentEditorState extends State<_DocumentEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _content;
  late String _category;
  String? _projectId;
  bool _preview = false;
  bool _saving = false;

  static const _templates = <String, String>{
    'Blank': '',
    'GDD': '# Game Design Document\n\n## High concept\nDescribe the game in one paragraph.\n\n## Core pillars\n- \n\n## Gameplay loop\n1. \n\n## Controls\n- \n\n## Progression\n\n## Art direction\n\n## Audio direction\n',
    'Character': '# Character: Name\n\n## Role\n\n## Backstory\n\n## Personality\n\n## Abilities\n- \n\n## Visual design\n\n## Voice and dialogue\n',
    'World': '# World / Location\n\n## Overview\n\n## Environment\n\n## History\n\n## Points of interest\n- \n\n## Gameplay purpose\n',
    'Mechanics': '# Mechanic\n\n## Player intent\n\n## Rules\n1. \n\n## Inputs\n\n## Feedback\n\n## Edge cases\n\n## Balance notes\n',
    'Level': '# Level brief\n\n## Goal\n\n## Layout\n\n## Encounters\n\n## Secrets\n\n## Rewards\n\n## Dependencies\n',
    'Technical': '# Technical design\n\n## Context\n\n## Requirements\n- \n\n## Proposed solution\n\n## Risks\n\n## Testing\n',
  };

  @override
  void initState() {
    super.initState();
    final doc = widget.document;
    _title = TextEditingController(text: doc?.title ?? '');
    _content = TextEditingController(text: doc?.content ?? '');
    _category = doc?.category ?? 'General';
    _projectId = doc?.projectId;
  }

  @override
  void dispose() {
    _title.dispose();
    _content.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final old = widget.document;
      if (old == null) {
        await widget.repository.create(title: _title.text, content: _content.text, category: _category, projectId: _projectId);
      } else {
        await widget.repository.update(StudioDocument(
          id: old.id, title: _title.text, content: _content.text, category: _category,
          projectId: _projectId, createdAt: old.createdAt, updatedAt: old.updatedAt,
        ));
      }
      if (mounted) Navigator.pop(context, true);
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save document: $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.document == null ? 'New document' : 'Edit document'),
    content: SizedBox(width: 760, height: 620, child: Form(
      key: _formKey,
      child: Column(children: [
        TextFormField(controller: _title, decoration: const InputDecoration(labelText: 'Title *'),
          validator: (v) => v == null || v.trim().isEmpty ? 'Enter a title' : null),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: DropdownButtonFormField<String>(
            initialValue: _category, decoration: const InputDecoration(labelText: 'Category'),
            items: ['GDD', 'Narrative', 'Character', 'World', 'Mechanics', 'Level', 'Technical', 'General']
              .map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: (v) => setState(() => _category = v ?? 'General'))),
          const SizedBox(width: 10),
          Expanded(child: FutureBuilder<List<Project>>(
            future: widget.projects.getAll(),
            builder: (context, snapshot) {
              final projects = snapshot.data ?? [];
              final selected = projects.any((p) => p.id == _projectId) ? _projectId : null;
              return DropdownButtonFormField<String?>(
                initialValue: selected, decoration: const InputDecoration(labelText: 'Project'),
                items: [const DropdownMenuItem<String?>(value: null, child: Text('All projects')),
                  ...projects.map((p) => DropdownMenuItem<String?>(value: p.id, child: Text(p.name, overflow: TextOverflow.ellipsis)))],
                onChanged: (v) => setState(() => _projectId = v));
            })),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Text('Content (Markdown)', style: TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          if (widget.document == null)
            PopupMenuButton<String>(
              tooltip: 'Insert template',
              onSelected: (key) {
                setState(() {
                  _content.text = _templates[key]!;
                  _category = switch (key) {
                    'GDD' => 'GDD', 'Character' => 'Character', 'World' => 'World',
                    'Mechanics' => 'Mechanics', 'Level' => 'Level', 'Technical' => 'Technical', _ => 'General',
                  };
                });
              },
              itemBuilder: (_) => _templates.keys.map((key) => PopupMenuItem(value: key, child: Text(key))).toList(),
              child: const Padding(padding: EdgeInsets.all(8), child: Row(children: [Icon(Icons.auto_awesome, size: 16), SizedBox(width: 5), Text('Template')])),
            ),
          SegmentedButton<bool>(
            segments: const [ButtonSegment(value: false, label: Text('Edit'), icon: Icon(Icons.edit_outlined)),
              ButtonSegment(value: true, label: Text('Preview'), icon: Icon(Icons.visibility_outlined))],
            selected: {_preview}, onSelectionChanged: (v) => setState(() => _preview = v.first),
          ),
        ]),
        const SizedBox(height: 8),
        Expanded(child: _preview
          ? Container(width: double.infinity, padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF10161E), borderRadius: BorderRadius.circular(10)),
              child: SingleChildScrollView(child: MarkdownBody(data: _content.text.isEmpty ? '*Nothing to preview yet.*' : _content.text)))
          : TextFormField(controller: _content, expands: true, minLines: null, maxLines: null,
              textAlignVertical: TextAlignVertical.top, style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: const InputDecoration(hintText: '# Start writing in Markdown...'))),
      ]),
    )),
    actions: [
      TextButton(onPressed: _saving ? null : () => Navigator.pop(context, false), child: const Text('Cancel')),
      FilledButton(onPressed: _saving ? null : _save, child: _saving
        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
        : const Text('Save document')),
    ],
  );
}
