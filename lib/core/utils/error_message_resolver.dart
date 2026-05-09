import 'package:ios_club_app/l10n/app_localizations.dart';

/// Maps error codes from service/notifier layer (no BuildContext) to
/// localized user-facing strings for display in the UI layer.
String resolveErrorMessage(String code, AppLocalizations l10n) {
  switch (code) {
    case 'auth_required':
      return l10n.pleaseLoginEduAccount;
    case 'load_failed':
      return l10n.loadFailedTapRetry;
    case 'exam_auth_required':
      return l10n.examNotLoggedIn;
    case 'auth_failed':
      return l10n.examAuthFailed;
    case 'fetch_failed':
      return l10n.examFetchFailed;
    case 'stale_data':
      return l10n.busRefreshStale;
    default:
      return code;
  }
}
