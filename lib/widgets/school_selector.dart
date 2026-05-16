import 'package:flutter/material.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/school.dart';
import '../services/api_service.dart';

/// 可搜索的学校下拉选择器
class SchoolSelector extends StatefulWidget {
  final School? selectedSchool;
  final ValueChanged<School> onSchoolSelected;

  const SchoolSelector({
    super.key,
    required this.selectedSchool,
    required this.onSchoolSelected,
  });

  @override
  State<SchoolSelector> createState() => _SchoolSelectorState();
}

class _SchoolSelectorState extends State<SchoolSelector> {
  final ApiService _api = ApiService();

  List<School> _filteredSchools = [];
  bool _loading = false;
  bool _initialized = false;

  Future<void> _loadSchools() async {
    if (_initialized) return;
    setState(() => _loading = true);
    _filteredSchools = await _api.fetchSchools();
    setState(() {
      _loading = false;
      _initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: _loadSchools,
      child: Autocomplete<School>(
        optionsBuilder: (textEditingValue) async {
          if (textEditingValue.text.isEmpty) {
            await _loadSchools();
            return _filteredSchools;
          }
          return _api.searchSchools(textEditingValue.text);
        },
        displayStringForOption: (school) =>
            '${school.name}（${school.shortName}）',
        fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: l10n.selectSchool,
              hintText: l10n.searchSchoolHint,
              prefixIcon: const Icon(Icons.school),
              suffixIcon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => onSubmitted(),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(8),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 240),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final school = options.elementAt(index);
                    final isSelected =
                        widget.selectedSchool?.id == school.id;
                    final isAdvanced =
                        school.supportLevel == SupportLevel.advanced;
                    final levelLabel = isAdvanced
                        ? l10n.supportLevelAdvancedDesc
                        : l10n.supportLevelBasicDesc;

                    return ListTile(
                      selected: isSelected,
                      selectedTileColor:
                          Theme.of(context).colorScheme.primary.withAlpha(30),
                      leading: CircleAvatar(
                        backgroundColor: isAdvanced
                            ? Colors.amber.shade100
                            : Colors.grey.shade200,
                        child: Icon(
                          isAdvanced ? Icons.star : Icons.school,
                          size: 20,
                          color: isAdvanced
                              ? Colors.amber.shade700
                              : Colors.grey.shade600,
                        ),
                      ),
                      title: Text(school.name),
                      subtitle: Text(
                        '${school.shortName} · $levelLabel',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      trailing: _supportLevelBadge(l10n, school.supportLevel),
                      onTap: () {
                        onSelected(school);
                        widget.onSchoolSelected(school);
                      },
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _supportLevelBadge(AppLocalizations l10n, SupportLevel level) {
    final isAdvanced = level == SupportLevel.advanced;
    final text = isAdvanced ? l10n.supportLevelAdvanced : l10n.supportLevelBasic;
    final color = isAdvanced ? Colors.amber : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color.shade700),
      ),
    );
  }
}
