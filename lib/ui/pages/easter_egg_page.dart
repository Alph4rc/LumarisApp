import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:ios_club_app/core/extensions/localization_extensions.dart';
import 'package:ios_club_app/ui/components/club_app_bar.dart';
import 'package:ios_club_app/ui/theme/club_theme.dart';

class EasterEggPage extends StatelessWidget {
  const EasterEggPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.clubColors;
    return Scaffold(
      appBar: ClubAppBar(
        title: l10n.easterEggTitle,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.egg,
                size: 100,
                color: colors.warning,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.easterEggFound,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.easterEggContent,
                style: const TextStyle(
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              CupertinoButton.filled(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
