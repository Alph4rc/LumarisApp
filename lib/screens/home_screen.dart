import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/school.dart';
import '../models/timetable.dart';
import '../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().loadTimetable();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthProvider>();
    final school = auth.selectedSchool;
    final isAdvanced = school?.supportLevel == SupportLevel.advanced;

    final dayLabels = [
      l10n.mon, l10n.tue, l10n.wed, l10n.thu,
      l10n.fri, l10n.sat, l10n.sun,
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(school?.name ?? l10n.timetable),
        actions: [
          if (school != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Chip(
                avatar: Icon(
                  isAdvanced ? Icons.star : Icons.school,
                  size: 18,
                ),
                label: Text(
                  isAdvanced ? l10n.supportLevelAdvancedDesc : l10n.supportLevelBasicDesc,
                ),
                backgroundColor: isAdvanced
                    ? Colors.amber.shade100
                    : Colors.grey.shade200,
              ),
            ),
          if (auth.supports(Feature.exportTimetable))
            IconButton(
              icon: const Icon(Icons.file_download_outlined),
              tooltip: l10n.exportTimetable,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.featureInDevelopment)),
                );
              },
            ),
          if (auth.supports(Feature.notifications))
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              tooltip: l10n.notificationSettings,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.featureInDevelopment)),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.switchSchoolOrLogout,
            onPressed: () {
              auth.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: auth.timetableLoading
          ? const Center(child: CircularProgressIndicator())
          : auth.timetable.isEmpty
              ? _buildEmptyState(l10n, isAdvanced)
              : _buildTimetable(l10n, auth, dayLabels),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isAdvanced) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            l10n.noTimetableData,
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          if (!isAdvanced) ...[
            const SizedBox(height: 8),
            Text(
              l10n.advancedCanEditHint,
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimetable(
    AppLocalizations l10n,
    AuthProvider auth,
    List<String> dayLabels,
  ) {
    final Map<int, List<TimetableEntry>> grouped = {};
    for (final entry in auth.timetable) {
      grouped.putIfAbsent(entry.dayOfWeek, () => []).add(entry);
    }

    final isAdvanced = auth.supportLevel == SupportLevel.advanced;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 7,
      itemBuilder: (context, dayIndex) {
        final day = dayIndex + 1;
        final entries = grouped[day] ?? [];

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dayLabels[dayIndex],
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Divider(),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      l10n.noCourse,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                else
                  ...entries.map((entry) => _buildEntryTile(l10n, entry, isAdvanced)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEntryTile(AppLocalizations l10n, TimetableEntry entry, bool canEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${entry.startPeriod}-${entry.endPeriod}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.courseName,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const SizedBox(height: 2),
                Text(
                  '${entry.teacher} · ${entry.classroom}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (canEdit)
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 18),
              tooltip: l10n.edit,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.featureInDevelopment)),
                );
              },
            ),
        ],
      ),
    );
  }
}
