import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';
import 'html_import_webview_page.dart';

class HtmlImportPage extends ConsumerStatefulWidget {
  const HtmlImportPage({super.key});

  @override
  ConsumerState<HtmlImportPage> createState() => _HtmlImportPageState();
}

class _HtmlImportPageState extends ConsumerState<HtmlImportPage> {
  final _urlController = TextEditingController();
  String? _selectedUrl;

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _openWebView() {
    final url = _selectedUrl ?? _urlController.text.trim();
    if (url.isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => HtmlImportWebViewPage(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    final schools = ApiConfig.getAllSchools();

    return Scaffold(
      appBar: ClubAppBar(title: l10n.htmlImport),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.selectSchool,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colors.label,
              ),
            ),
          ),
          ...schools.map(
            (school) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Material(
                color: _selectedUrl == school.scheduleUrl
                    ? colors.selectionFill
                    : colors.groupedBackground,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() => _selectedUrl = school.scheduleUrl);
                    _urlController.clear();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                school.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: colors.label,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                school.scheduleUrl,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.secondaryLabel,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (_selectedUrl == school.scheduleUrl)
                          Icon(Icons.check_circle, color: colors.primary),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Text(
              l10n.enterCustomUrl,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: colors.label,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: l10n.urlHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colors.groupedBackground,
              ),
              onChanged: (_) {
                if (_selectedUrl != null) {
                  setState(() => _selectedUrl = null);
                }
              },
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_selectedUrl != null ||
                        _urlController.text.trim().isNotEmpty)
                    ? _openWebView
                    : null,
                icon: const Icon(Icons.open_in_browser),
                label: Text(l10n.htmlImport),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
