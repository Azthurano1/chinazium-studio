class GitHubIssue {
  const GitHubIssue({
    required this.number,
    required this.title,
    required this.body,
    required this.state,
    required this.url,
    required this.author,
    required this.labels,
    required this.updatedAt,
    required this.isPullRequest,
  });

  final int number;
  final String title;
  final String body;
  final String state;
  final String url;
  final String author;
  final List<String> labels;
  final DateTime? updatedAt;
  final bool isPullRequest;

  factory GitHubIssue.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? const {};
    final labels = (json['labels'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map((label) => label['name'] as String? ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
    return GitHubIssue(
      number: json['number'] as int,
      title: json['title'] as String? ?? 'Untitled issue',
      body: json['body'] as String? ?? '',
      state: json['state'] as String? ?? 'open',
      url: json['html_url'] as String? ?? '',
      author: user['login'] as String? ?? 'unknown',
      labels: labels,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? ''),
      isPullRequest: json.containsKey('pull_request'),
    );
  }
}
