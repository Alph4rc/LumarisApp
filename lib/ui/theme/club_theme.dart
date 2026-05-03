import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:macos_ui/macos_ui.dart';

@immutable
class ClubColors extends ThemeExtension<ClubColors> {
  const ClubColors({
    required this.appBackground,
    required this.groupedBackground,
    required this.cardBackground,
    required this.cardOverlay,
    required this.separator,
    required this.label,
    required this.secondaryLabel,
    required this.tertiaryLabel,
    required this.quaternaryLabel,
    required this.primary,
    required this.success,
    required this.warning,
    required this.danger,
    required this.selectionFill,
    required this.shadowColor,
  });

  final Color appBackground;
  final Color groupedBackground;
  final Color cardBackground;
  final Color cardOverlay;
  final Color separator;
  final Color label;
  final Color secondaryLabel;
  final Color tertiaryLabel;
  final Color quaternaryLabel;
  final Color primary;
  final Color success;
  final Color warning;
  final Color danger;
  final Color selectionFill;
  final Color shadowColor;

  static const ClubColors light = ClubColors(
    appBackground: Color(0xFFFFFFFF),
    groupedBackground: Color(0xFFF2F2F7),
    cardBackground: Color(0xFFFFFFFF),
    cardOverlay: Color(0xCCFFFFFF),
    separator: Color(0xFFD1D1D6),
    label: Color(0xFF000000),
    secondaryLabel: Color(0x993C3C43),
    tertiaryLabel: Color(0x4D3C3C43),
    quaternaryLabel: Color(0x2E3C3C43),
    primary: Color(0xFF007AFF),
    success: Color(0xFF34C759),
    warning: Color(0xFFFF9500),
    danger: Color(0xFFFF3B30),
    selectionFill: Color(0x1F007AFF),
    shadowColor: Color(0x0F000000),
  );

  static const ClubColors dark = ClubColors(
    appBackground: Color(0xFF000000),
    groupedBackground: Color(0xFF000000),
    cardBackground: Color(0xFF1C1C1E),
    cardOverlay: Color(0x1FEBEBF5),
    separator: Color(0xFF38383A),
    label: Color(0xFFFFFFFF),
    secondaryLabel: Color(0x99EBEBF5),
    tertiaryLabel: Color(0x4DEBEBF5),
    quaternaryLabel: Color(0x2EEBEBF5),
    primary: Color(0xFF0A84FF),
    success: Color(0xFF30D158),
    warning: Color(0xFFFF9F0A),
    danger: Color(0xFFFF453A),
    selectionFill: Color(0x330A84FF),
    shadowColor: Color(0x00000000),
  );

  @override
  ThemeExtension<ClubColors> copyWith({
    Color? appBackground,
    Color? groupedBackground,
    Color? cardBackground,
    Color? cardOverlay,
    Color? separator,
    Color? label,
    Color? secondaryLabel,
    Color? tertiaryLabel,
    Color? quaternaryLabel,
    Color? primary,
    Color? success,
    Color? warning,
    Color? danger,
    Color? selectionFill,
    Color? shadowColor,
  }) {
    return ClubColors(
      appBackground: appBackground ?? this.appBackground,
      groupedBackground: groupedBackground ?? this.groupedBackground,
      cardBackground: cardBackground ?? this.cardBackground,
      cardOverlay: cardOverlay ?? this.cardOverlay,
      separator: separator ?? this.separator,
      label: label ?? this.label,
      secondaryLabel: secondaryLabel ?? this.secondaryLabel,
      tertiaryLabel: tertiaryLabel ?? this.tertiaryLabel,
      quaternaryLabel: quaternaryLabel ?? this.quaternaryLabel,
      primary: primary ?? this.primary,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      selectionFill: selectionFill ?? this.selectionFill,
      shadowColor: shadowColor ?? this.shadowColor,
    );
  }

  @override
  ThemeExtension<ClubColors> lerp(
    covariant ThemeExtension<ClubColors>? other,
    double t,
  ) {
    if (other is! ClubColors) {
      return this;
    }

    return ClubColors(
      appBackground: Color.lerp(appBackground, other.appBackground, t)!,
      groupedBackground:
          Color.lerp(groupedBackground, other.groupedBackground, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      cardOverlay: Color.lerp(cardOverlay, other.cardOverlay, t)!,
      separator: Color.lerp(separator, other.separator, t)!,
      label: Color.lerp(label, other.label, t)!,
      secondaryLabel: Color.lerp(secondaryLabel, other.secondaryLabel, t)!,
      tertiaryLabel: Color.lerp(tertiaryLabel, other.tertiaryLabel, t)!,
      quaternaryLabel: Color.lerp(quaternaryLabel, other.quaternaryLabel, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      selectionFill: Color.lerp(selectionFill, other.selectionFill, t)!,
      shadowColor: Color.lerp(shadowColor, other.shadowColor, t)!,
    );
  }
}

class ClubTheme {
  ClubTheme._();

  static ThemeData lightTheme({String? fontFamily}) {
    return _buildTheme(
      brightness: Brightness.light,
      fontFamily: fontFamily,
      colors: ClubColors.light,
    );
  }

  static ThemeData darkTheme({String? fontFamily}) {
    return _buildTheme(
      brightness: Brightness.dark,
      fontFamily: fontFamily,
      colors: ClubColors.dark,
    );
  }

  static MacosThemeData macosLightTheme() {
    return MacosThemeData.light().copyWith(
      primaryColor: ClubColors.light.primary,
      canvasColor: ClubColors.light.groupedBackground,
      brightness: Brightness.light,
      pushButtonTheme: const PushButtonThemeData(
        color: Color(0xFF007AFF),
        secondaryColor: Color(0xFFD1D1D6),
      ),
      helpButtonTheme: const HelpButtonThemeData(
        color: Color(0xFF007AFF),
      ),
    );
  }

  static MacosThemeData macosDarkTheme() {
    return MacosThemeData.dark().copyWith(
      primaryColor: ClubColors.dark.primary,
      canvasColor: ClubColors.dark.groupedBackground,
      brightness: Brightness.dark,
      pushButtonTheme: const PushButtonThemeData(
        color: Color(0xFF0A84FF),
        secondaryColor: Color(0xFF38383A),
      ),
      helpButtonTheme: const HelpButtonThemeData(
        color: Color(0xFF0A84FF),
      ),
    );
  }

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ClubColors colors,
    String? fontFamily,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: Colors.white,
      secondary: colors.primary,
      onSecondary: Colors.white,
      error: colors.danger,
      onError: Colors.white,
      surface: colors.cardBackground,
      onSurface: colors.label,
    );

    final baseTheme = ThemeData(
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colors.groupedBackground,
      canvasColor: colors.groupedBackground,
      dividerColor: colors.separator,
      disabledColor: colors.tertiaryLabel,
      splashColor: colors.selectionFill,
      highlightColor: colors.selectionFill,
      hoverColor: colors.cardOverlay,
      shadowColor: colors.shadowColor,
      cardColor: colors.cardBackground,
      extensions: <ThemeExtension<dynamic>>[colors],
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.cardBackground,
        contentTextStyle: TextStyle(
          color: colors.label,
          fontSize: 14,
        ),
        actionTextColor: colors.primary,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.groupedBackground,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.label,
        elevation: 0,
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.cardBackground,
        modalBackgroundColor: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.cardBackground,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: TextStyle(
          color: colors.label,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: TextStyle(
          color: colors.secondaryLabel,
          fontSize: 14,
        ),
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        brightness: brightness,
        primaryColor: colors.primary,
        scaffoldBackgroundColor: colors.groupedBackground,
        barBackgroundColor: colors.groupedBackground,
        textTheme: CupertinoTextThemeData(
          primaryColor: colors.primary,
          textStyle: TextStyle(
            color: colors.label,
            fontFamily: fontFamily,
          ),
        ),
      ),
    );

    return baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        bodyColor: colors.label,
        displayColor: colors.label,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
        ),
      ),
      iconTheme: IconThemeData(
        color: colors.label,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colors.secondaryLabel,
        textColor: colors.label,
      ),
    );
  }
}

extension ClubThemeBuildContext on BuildContext {
  ClubColors get clubColors {
    return Theme.of(this).extension<ClubColors>() ??
        (Theme.of(this).brightness == Brightness.dark
            ? ClubColors.dark
            : ClubColors.light);
  }
}

class ClubThemeModeCodec {
  ClubThemeModeCodec._();

  static ThemeMode fromPreference(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String toPreference(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
