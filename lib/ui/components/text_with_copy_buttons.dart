import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';

import 'show_club_snack_bar.dart';

class TextWithCopyButtons extends StatelessWidget {
  final String topText;
  final String bottomText;
  final TextStyle? topTextStyle;
  final TextStyle? bottomTextStyle;

  const TextWithCopyButtons({
    super.key,
    required this.topText,
    required this.bottomText,
    this.topTextStyle,
    this.bottomTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextWithCopyButton(
          context: context,
          text: topText,
          style: topTextStyle ?? Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8), // 上下文本之间的间距
        _buildTextWithCopyButton(
          context: context,
          text: bottomText,
          style: bottomTextStyle ?? Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildTextWithCopyButton({
    required BuildContext context,
    required String text,
    TextStyle? style,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: style,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.copy, size: 20),
          onPressed: () {
            Clipboard.setData(ClipboardData(text: text));
            showClubSnackBar(
              context,
              Text(context.l10n.copiedToClipboard),
            );
          },
          tooltip: context.l10n.copyTooltip,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          padding: const EdgeInsets.all(8),
          splashRadius: 20,
        ),
      ],
    );
  }
}
