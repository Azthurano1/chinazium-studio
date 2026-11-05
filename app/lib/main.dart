import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ChinaziumStudioApp());
}

class ChinaziumStudioApp extends StatelessWidget {
  const ChinaziumStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF0D1117);
    const surface = Color(0xFF151B23);
    const accent = Color(0xFF8B7CFF);

    return MaterialApp(
      title: 'Chinazium Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: const ColorScheme.dark(
          primary: accent,
          secondary: Color(0xFF56C8B5),
          surface: surface,
          onSurface: Color(0xFFE6EDF3),
        ),
        cardTheme: CardThemeData(
          color: surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: Color(0xFF27313D)),
          ),
        ),
        dividerColor: const Color(0xFF27313D),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      home: const StudioShell(),
    );
  }
}

enum StudioSection {
  dashboard('Dashboard', Icons.dashboard_outlined),
  projects('Projects', Icons.folder_outlined),
  tasks('Tasks', Icons.checklist_rounded),
  roadmap('Roadmap', Icons.timeline_rounded),
  documents('Documents', Icons.description_outlined),
  assets('Assets', Icons.view_in_ar_outlined),
  software('Software', Icons.apps_outlined),
  settings('Settings', Icons.settings_outlined);

  const StudioSection(this.label, this.icon);
  final String label;
  final IconData icon;
}

class StudioShell extends StatefulWidget {
  const StudioShell({super.key});

  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  StudioSection _section = StudioSection.dashboard;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 850;

        return Scaffold(
          body: Row(
            children: [
              if (!compact) _Sidebar(
                selected: _section,
                onSelected: (section) => setState(() => _section = section),
              ),
              Expanded(
                child: Column(
                  children: [
                    _TopBar(compact: compact),
                    Expanded(child: _pageFor(_section)),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: compact
              ? NavigationBar(
                  selectedIndex: _section.index.clamp(0, 3),
                  onDestinationSelected: (index) => setState(
                    () => _section = StudioSection.values[index],
                  ),
                  destinations: StudioSection.values
                      .take(4)
                      .map((section) => NavigationDestination(
                            icon: Icon(section.icon),
                            label: section.label,
                          ))
                      .toList(),
                )
              : null,
        );
      },
    );
  }

  Widget _pageFor(StudioSection section) {
    return switch (section) {
      StudioSection.dashboard => const DashboardPage(),
      StudioSection.projects => const PlaceholderPage(
          title: 'Projects',
          description: 'Create and organize your game development projects.',
          icon: Icons.folder_outlined,
        ),
      StudioSection.tasks => const PlaceholderPage(
          title: 'Tasks',
          description: 'Plan work, track priorities and manage dependencies.',
          icon: Icons.checklist_rounded,
        ),
      StudioSection.roadmap => const PlaceholderPage(
          title: 'Roadmap',
          description: 'Turn your production plan into milestones and stages.',
          icon: Icons.timeline_rounded,
        ),
      StudioSection.documents => const PlaceholderPage(
          title: 'Documents',
          description: 'Keep GDDs, narrative notes and technical documentation together.',
          icon: Icons.description_outlined,
        ),
      StudioSection.assets => const PlaceholderPage(
          title: 'Assets',
          description: 'Catalog models, textures, animation, audio and other assets.',
          icon: Icons.view_in_ar_outlined,
        ),
      StudioSection.software => const PlaceholderPage(
          title: 'Software',
          description: 'Track the tools and versions used by each project.',
          icon: Icons.apps_outlined,
        ),
      StudioSection.settings => const PlaceholderPage(
          title: 'Settings',
          description: 'Application preferences and local data management.',
          icon: Icons.settings_outlined,
        ),
    };
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelected});

  final StudioSection selected;
  final ValueChanged<StudioSection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 238,
      decoration: const BoxDecoration(
        color: Color(0xFF111720),
        border: Border(right: BorderSide(color: Color(0xFF27313D))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 26, 18, 28),
            child: Row(
              children: [
                Icon(Icons.hexagon_rounded, color: Color(0xFF8B7CFF), size: 30),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('CHINAZIUM', style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                      )),
                      Text('STUDIO', style: TextStyle(
                        color: Color(0xFF8B7CFF),
                        fontSize: 11,
                        letterSpacing: 3.2,
                        fontWeight: FontWeight.w700,
                      )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 12, 10),
            child: Text('WORKSPACE', style: TextStyle(
              color: Color(0xFF7D8998),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            )),
          ),
          for (final section in StudioSection.values)
            _SidebarItem(
              section: section,
              selected: selected == section,
              onTap: () => onSelected(section),
            ),
          const Spacer(),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text('LOCAL WORKSPACE  •  v0.1.0',
              style: TextStyle(color: Color(0xFF7D8998), fontSize: 10)),
          ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final StudioSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: ListTile(
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        selected: selected,
        selectedTileColor: const Color(0xFF282442),
        leading: Icon(section.icon, size: 19,
          color: selected ? const Color(0xFFB5AAFF) : const Color(0xFF8B98A8)),
        title: Text(section.label, style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? Colors.white : const Color(0xFFB6C0CC),
        )),
        onTap: onTap,
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.compact});
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF27313D))),
      ),
      child: Row(
        children: [
          const Text('Game Development Workspace',
            style: TextStyle(color: Color(0xFFB6C0CC), fontSize: 13)),
          const Spacer(),
          const Icon(Icons.cloud_off_outlined,
            size: 17, color: Color(0xFF56C8B5)),
          const SizedBox(width: 8),
          const Text('Local mode',
            style: TextStyle(color: Color(0xFF8F9BAA), fontSize: 12)),
          const SizedBox(width: 18),
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF302B50),
            child: const Icon(Icons.person_outline,
              size: 18, color: Color(0xFFB5AAFF)),
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1250),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dashboard', style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.6)),
              const SizedBox(height: 7),
              const Text('Your game development workspace at a glance.',
                style: TextStyle(color: Color(0xFF8F9BAA), fontSize: 14)),
              const SizedBox(height: 28),
              const Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  _StatCard(label: 'Projects', value: '0',
                    caption: 'No projects yet', icon: Icons.folder_outlined),
                  _StatCard(label: 'Open tasks', value: '0',
                    caption: 'Nothing pending', icon: Icons.checklist_rounded),
                  _StatCard(label: 'Milestones', value: '0',
                    caption: 'No milestones planned', icon: Icons.flag_outlined),
                  _StatCard(label: 'Assets', value: '0',
                    caption: 'Asset library is empty', icon: Icons.view_in_ar_outlined),
                ],
              ),
              const SizedBox(height: 26),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Get started', style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w650)),
                      const SizedBox(height: 8),
                      const Text(
                        'Create your first game project to start organizing ideas, tasks, milestones and assets.',
                        style: TextStyle(color: Color(0xFF9AA7B5), height: 1.5)),
                      const SizedBox(height: 18),
                      FilledButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Create your first project'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              const Text('Recent activity', style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w650)),
              const SizedBox(height: 12),
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(22),
                  child: Row(
                    children: [
                      Icon(Icons.history, color: Color(0xFF8F9BAA)),
                      SizedBox(width: 12),
                      Expanded(child: Text('Your recent activity will appear here.',
                        style: TextStyle(color: Color(0xFF8F9BAA)))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.caption,
    required this.icon,
  });

  final String label;
  final String value;
  final String caption;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 245,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(19),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF9B8FFF), size: 19),
                  const SizedBox(width: 9),
                  Text(label, style: const TextStyle(
                    color: Color(0xFFB6C0CC), fontSize: 13)),
                ],
              ),
              const SizedBox(height: 17),
              Text(value, style: const TextStyle(
                fontSize: 30, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(caption, style: const TextStyle(
                color: Color(0xFF7D8998), fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage({
    required this.title,
    required this.description,
    required this.icon,
    super.key,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 46, color: const Color(0xFF8B7CFF)),
            const SizedBox(height: 18),
            Text(title, style: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(description, textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF8F9BAA))),
            const SizedBox(height: 16),
            const Chip(label: Text('Planned for MVP')),
          ],
        ),
      ),
    );
  }
}
