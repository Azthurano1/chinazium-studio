import 'dart:convert';

import 'package:http/http.dart' as http;

import 'github_issue.dart';

class GitHubIssuesRepository {
  Future<List<GitHubIssue>> fetchIssues({
    required String repository,
    String state = 'open',
  }) async {
    final normalized = repository
        .trim()
        .replaceAll(RegExp(r'^https?://github\.com/'), '')
        .replaceAll(RegExp(r'\.git$'), '');
    final parts = normalized.split('/');
    if (parts.length != 2 ||
        parts.any((part) => part.isEmpty || part.contains(' '))) {
      throw const FormatException('Enter a repository as owner/name.');
    }

    final uri = Uri.https(
      'api.github.com',
      '/repos/$normalized/issues',
      {'state': state, 'per_page': '100', 'sort': 'updated', 'direction': 'desc'},
    );
    final response = await http.get(uri, headers: const {
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
      'User-Agent': 'Chinazium-Studio',
    }).timeout(const Duration(seconds: 20));

    if (response.statusCode == 404) {
      throw Exception(
        'Repository not found or private. Public repositories are supported without a token.',
      );
    }
    if (response.statusCode == 403 || response.statusCode == 429) {
      throw Exception('GitHub API rate limit reached. Try again later.');
    }
    if (response.statusCode != 200) {
      throw Exception('GitHub API returned HTTP ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body) as List<dynamic>;
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(GitHubIssue.fromJson)
        .where((issue) => !issue.isPullRequest)
        .toList();
  }
}
