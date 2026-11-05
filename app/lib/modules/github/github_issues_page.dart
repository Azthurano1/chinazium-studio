import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'github_issue.dart';
import 'github_issues_repository.dart';

class GitHubIssuesPage extends StatefulWidget {
  const GitHubIssuesPage({super.key});

  @override
  State<GitHubIssuesPage> createState() => _GitHubIssuesPageState();
}

class _GitHubIssuesPageState extends State<GitHubIssuesPage> {
  final _repositoryController = TextEditingController(text: 'Azthurano1/chinazium-studio');
  final _api = GitHubIssuesRepository();
  List<GitHubIssue> _issues = [];
  String _state = 'open';
  bool _loading = false;
  String? _error;
  String? _loadedRepository;

  @override
  void dispose() {
    _repositoryController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final issues = await _api.fetchIssues(
        repository: _repositoryController.text,
        state: _state,
      );
      if (!mounted) return;
      setState(() {
        _issues = issues;
        _loadedRepository = _repositoryController.text.trim();
      });
    } catch (error) {
      if (mounted) setState(() => _error = error.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _copyIssue(GitHubIssue issue) async {
    await Clipboard.setData(ClipboardData(text: issue.url));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Issue #${issue.number} link copied')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('GitHub Issues', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Use repository Issues as a live task list. Public repositories work without a token.',
            style: TextStyle(color: Color(0xFF8F9BAA))),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _repositoryController,
                  decoration: const InputDecoration(
                    labelText: 'GitHub repository',
                    hintText: 'owner/repository',
                    prefixIcon: Icon(Icons.link),
                  ),
                  onSubmitted: (_) => _load(),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<String>(
                value: _state,
                items: const [
                  DropdownMenuItem(value: 'open', child: Text('Open')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  DropdownMenuItem(value: 'all', child: Text('All')),
                ],
                onChanged: _loading ? null : (value) {
                  if (value != null) setState(() => _state = value);
                },
              ),
              const SizedBox(width: 10),
              FilledButton.icon(
                onPressed: _loading ? null : _load,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.sync),
                label: const Text('Load issues'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (_loadedRepository != null)
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                avatar: const Icon(Icons.check_circle, size: 16, color: Color(0xFF56C8B5)),
                label: Text('${_issues.length} issues · $_loadedRepository'),
              ),
            ),
          if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  const Icon(Icons.error_outline, color: Color(0xFFE07A84)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(_error!)),
                ]),
              ),
            ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _issues.isEmpty
                    ? Center(
                        child: Text(
                          _error == null
                              ? 'Enter a repository and load its Issues.'
                              : 'Could not load issues.',
                          style: const TextStyle(color: Color(0xFF8F9BAA)),
                        ),
                      )
                    : ListView.separated(
                        itemCount: _issues.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final issue = _issues[index];
                          final closed = issue.state == 'closed';
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                closed ? Icons.check_circle_outline : Icons.radio_button_unchecked,
                                color: closed ? const Color(0xFF56C8B5) : const Color(0xFF8B7CFF),
                              ),
                              title: Text('#${issue.number} · ${issue.title}',
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 7),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('by @${issue.author} · ${issue.state} · updated ${issue.updatedAt?.toLocal().toString().split(' ').first ?? 'unknown'}'),
                                    if (issue.labels.isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Wrap(spacing: 5, runSpacing: 4, children: issue.labels.map((label) => Chip(
                                        label: Text(label, style: const TextStyle(fontSize: 11)),
                                        visualDensity: VisualDensity.compact,
                                        padding: EdgeInsets.zero,
                                      )).toList()),
                                    ],
                                    if (issue.body.trim().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      Text(issue.body.trim(), maxLines: 3, overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Color(0xFF8F9BAA))),
                                    ],
                                  ],
                                ),
                              ),
                              trailing: IconButton(
                                tooltip: 'Copy Issue link',
                                onPressed: () => _copyIssue(issue),
                                icon: const Icon(Icons.copy_outlined),
                              ),
                              isThreeLine: issue.body.trim().isNotEmpty,
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
