import 'package:flutter/material.dart';
import 'package:ios_club_app/core/config/api_config.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class SchoolSelector extends StatelessWidget {
  const SchoolSelector({
    super.key,
    required this.selectedSchool,
    required this.onChanged,
  });

  final SchoolConfig? selectedSchool;
  final ValueChanged<SchoolConfig> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    final schools = ApiConfig.getAllSchools();

    return Autocomplete<SchoolConfig>(
      initialValue: TextEditingValue(text: selectedSchool?.name ?? ''),
      displayStringForOption: (school) => '${school.name} (${school.shortName})',
      optionsBuilder: (textEditingValue) {
        if (textEditingValue.text.isEmpty) return schools;
        return ApiConfig.searchSchools(textEditingValue.text);
      },
      fieldViewBuilder: (context, controller, focusNode, onSubmit) {
        return TextField(
          controller: controller,
          focusNode: focusNode,
          style: const TextStyle(fontSize: 17),
          decoration: InputDecoration(
            hintText: l10n.selectSchool,
            hintStyle: TextStyle(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.4),
            ),
            prefixIcon: Icon(
              Icons.school_outlined,
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withValues(alpha: 0.5),
              size: 22,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            isDense: true,
          ),
          onSubmitted: (value) {
            // Find exact match on submit
            final match = ApiConfig.searchSchools(value);
            if (match.isNotEmpty) {
              onChanged(match.first);
              controller.text = match.first.name;
            }
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final school = options.elementAt(index);
                  final isSelected = school.id == selectedSchool?.id;
                  return ListTile(
                    selected: isSelected,
                    selectedTileColor:
                        colors.primary.withValues(alpha: 0.1),
                    leading: Icon(
                      Icons.school_outlined,
                      color: isSelected ? colors.primary : null,
                      size: 22,
                    ),
                    title: Text(
                      school.name,
                      style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected ? colors.primary : null,
                      ),
                    ),
                    subtitle: Text(
                      school.shortName,
                      style: TextStyle(fontSize: 13),
                    ),
                    trailing: _SupportLevelBadge(school: school),
                    onTap: () => onSelected(school),
                  );
                },
              ),
            ),
          ),
        );
      },
      onSelected: onChanged,
    );
  }
}

class _SupportLevelBadge extends StatelessWidget {
  const _SupportLevelBadge({required this.school});

  final SchoolConfig school;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isAdvanced = school.supportLevel == SupportLevel.advanced;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isAdvanced
            ? Colors.green.withValues(alpha: 0.12)
            : Colors.grey.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isAdvanced ? l10n.advancedSupport : l10n.basicSupport,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isAdvanced ? Colors.green[700] : Colors.grey[600],
        ),
      ),
    );
  }
}
