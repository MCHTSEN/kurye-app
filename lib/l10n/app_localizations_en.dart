// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'eipat';

  @override
  String get onboardingTitle => 'Onboarding';

  @override
  String get onboardingBody =>
      'This screen is the onboarding module skeleton to be reused in future projects.';

  @override
  String get onboardingContinue => 'Continue';

  @override
  String get authTitle => 'Authentication';

  @override
  String authBackendLabel(String provider) {
    return 'Active provider: $provider';
  }

  @override
  String get authDescription =>
      'This skeleton tests the auth flow with anonymous login. Email/password and OAuth are also supported.';

  @override
  String get authSignInAnonymous => 'Sign in anonymously';

  @override
  String get authSignInWithEmail => 'Sign in with email';

  @override
  String get authEmail => 'Email';

  @override
  String get authPassword => 'Password';

  @override
  String get authBackendSelection => 'Backend Selection';

  @override
  String get authSignInWithGoogle => 'Sign in with Google';

  @override
  String get authOrDivider => 'or';

  @override
  String get authRegister => 'Register';

  @override
  String get authName => 'Full Name';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeSkeletonReady => 'Skeleton Ready';

  @override
  String get homeSkeletonDescription =>
      'Auth, onboarding, profile, and backend adapter structure is set up with Riverpod 3.';

  @override
  String get homeOpenExampleFeed => 'Open Example Feed';

  @override
  String get homeGoToProfile => 'Go to Profile';

  @override
  String get homeBuyCredit => 'Buy Credit';

  @override
  String get homeSignOut => 'Sign Out';

  @override
  String get exampleFeedTitle => 'Example Feed';

  @override
  String get exampleFeedEmptyTitle => 'No Example Items';

  @override
  String get exampleFeedEmpty =>
      'The example feed is empty. Refresh to pull the latest sample payload.';

  @override
  String get exampleFeedErrorTitle => 'Could not load example feed';

  @override
  String get exampleFeedErrorBody =>
      'The template feed could not be loaded. Retry to validate the slice again.';

  @override
  String exampleFeedSelected(String title) {
    return 'Selected $title';
  }

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileUser => 'User';

  @override
  String get profileNoSession => 'No active session';

  @override
  String get profileError => 'Could not load profile data';

  @override
  String get buyCreditTitle => 'Buy Credit';

  @override
  String get buyCreditInsufficientTitle => 'Insufficient Credit';

  @override
  String get buyCreditDescription =>
      'This screen opens via the central credit guard. Real payment adapters connect here.';

  @override
  String get buyCreditSendIntent => 'Send purchase intent (demo)';

  @override
  String get errorUnexpected => 'An unexpected error occurred.';

  @override
  String get errorLoadFailed => 'Failed to load.';

  @override
  String get retry => 'Retry';

  @override
  String get dashboardTitle => 'e-iPAT';

  @override
  String dashboardWelcome(String name) {
    return 'Welcome, $name';
  }

  @override
  String dashboardRemainingTokens(int count) {
    return 'Remaining Tokens: $count';
  }

  @override
  String get dashboardBuyTokens => 'Buy Tokens';

  @override
  String get dashboardParcelQuery => 'Query Parcel';

  @override
  String get dashboardQueryHistory => 'Query History';

  @override
  String get dashboardPromoCode => 'Promo Code';

  @override
  String get dashboardPromoHint => 'Enter code';

  @override
  String get dashboardPromoUse => 'Apply';

  @override
  String get dashboardSignOut => 'Sign Out';

  @override
  String get parcelQueryTitle => 'Query Parcel';

  @override
  String get parcelQueryInfo => 'Parcel Information';

  @override
  String get parcelQueryMahalle => 'Neighborhood';

  @override
  String get parcelQueryMahalleManual => 'Neighborhood (manual entry)';

  @override
  String get parcelQueryEskiAdaParsel => 'Old Block/Parcel';

  @override
  String get parcelQueryYeniAdaParsel => 'New Block/Parcel';

  @override
  String get parcelQueryHisseAlani => 'User Share Area (m²)';

  @override
  String get parcelQueryOptional => 'Optional';

  @override
  String get parcelQuerySubmit => 'Query (100 Tokens)';

  @override
  String get parcelQueryResult => 'Query Result';

  @override
  String get queryHistoryTitle => 'Query History';

  @override
  String get queryHistoryEmpty => 'No queries yet.';

  @override
  String queryHistoryTokens(int count) {
    return '-$count tokens';
  }
}
