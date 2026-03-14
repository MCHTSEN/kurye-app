import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In tr, this message translates to:
  /// **'eipat'**
  String get appTitle;

  /// No description provided for @onboardingTitle.
  ///
  /// In tr, this message translates to:
  /// **'Onboarding'**
  String get onboardingTitle;

  /// No description provided for @onboardingBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu ekran gelecekteki projelerde tekrar kullanılacak onboarding modülü iskeletidir.'**
  String get onboardingBody;

  /// No description provided for @onboardingContinue.
  ///
  /// In tr, this message translates to:
  /// **'Devam et'**
  String get onboardingContinue;

  /// No description provided for @authTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kimlik Doğrulama'**
  String get authTitle;

  /// No description provided for @authBackendLabel.
  ///
  /// In tr, this message translates to:
  /// **'Aktif provider: {provider}'**
  String authBackendLabel(String provider);

  /// No description provided for @authDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu iskelette anonymous login ile auth akışı test edilir. E-posta/şifre ve OAuth da desteklenir.'**
  String get authDescription;

  /// No description provided for @authSignInAnonymous.
  ///
  /// In tr, this message translates to:
  /// **'Anonim giriş yap'**
  String get authSignInAnonymous;

  /// No description provided for @authSignInWithEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta ile giriş yap'**
  String get authSignInWithEmail;

  /// No description provided for @authEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get authEmail;

  /// No description provided for @authPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get authPassword;

  /// No description provided for @authBackendSelection.
  ///
  /// In tr, this message translates to:
  /// **'Backend Seçimi'**
  String get authBackendSelection;

  /// No description provided for @authSignInWithGoogle.
  ///
  /// In tr, this message translates to:
  /// **'Google ile giriş yap'**
  String get authSignInWithGoogle;

  /// No description provided for @authOrDivider.
  ///
  /// In tr, this message translates to:
  /// **'veya'**
  String get authOrDivider;

  /// No description provided for @authRegister.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get authRegister;

  /// No description provided for @authName.
  ///
  /// In tr, this message translates to:
  /// **'Ad Soyad'**
  String get authName;

  /// No description provided for @homeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ana Sayfa'**
  String get homeTitle;

  /// No description provided for @homeSkeletonReady.
  ///
  /// In tr, this message translates to:
  /// **'İskelet Hazır'**
  String get homeSkeletonReady;

  /// No description provided for @homeSkeletonDescription.
  ///
  /// In tr, this message translates to:
  /// **'Auth, onboarding, profile ve backend adapter yapısı Riverpod 3 ile kuruludur.'**
  String get homeSkeletonDescription;

  /// No description provided for @homeOpenExampleFeed.
  ///
  /// In tr, this message translates to:
  /// **'Ornek Feed Ac'**
  String get homeOpenExampleFeed;

  /// No description provided for @homeGoToProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profile Git'**
  String get homeGoToProfile;

  /// No description provided for @homeBuyCredit.
  ///
  /// In tr, this message translates to:
  /// **'Buy Credit'**
  String get homeBuyCredit;

  /// No description provided for @homeSignOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get homeSignOut;

  /// No description provided for @exampleFeedTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ornek Feed'**
  String get exampleFeedTitle;

  /// No description provided for @exampleFeedEmptyTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ornek Icerik Yok'**
  String get exampleFeedEmptyTitle;

  /// No description provided for @exampleFeedEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Ornek feed bos. Son sample veriyi cekmek icin yenileyin.'**
  String get exampleFeedEmpty;

  /// No description provided for @exampleFeedErrorTitle.
  ///
  /// In tr, this message translates to:
  /// **'Ornek feed yuklenemedi'**
  String get exampleFeedErrorTitle;

  /// No description provided for @exampleFeedErrorBody.
  ///
  /// In tr, this message translates to:
  /// **'Template feed yuklenemedi. Slice\'i tekrar dogrulamak icin yeniden deneyin.'**
  String get exampleFeedErrorBody;

  /// No description provided for @exampleFeedSelected.
  ///
  /// In tr, this message translates to:
  /// **'{title} secildi'**
  String exampleFeedSelected(String title);

  /// No description provided for @profileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get profileTitle;

  /// No description provided for @profileUser.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı'**
  String get profileUser;

  /// No description provided for @profileNoSession.
  ///
  /// In tr, this message translates to:
  /// **'Aktif oturum yok'**
  String get profileNoSession;

  /// No description provided for @profileError.
  ///
  /// In tr, this message translates to:
  /// **'Profil verisi yüklenemedi'**
  String get profileError;

  /// No description provided for @buyCreditTitle.
  ///
  /// In tr, this message translates to:
  /// **'Buy Credit'**
  String get buyCreditTitle;

  /// No description provided for @buyCreditInsufficientTitle.
  ///
  /// In tr, this message translates to:
  /// **'Kredi Yetersiz'**
  String get buyCreditInsufficientTitle;

  /// No description provided for @buyCreditDescription.
  ///
  /// In tr, this message translates to:
  /// **'Bu ekran merkezi credit guard ile açılır. Gerçek ödeme adapterları buraya bağlanır.'**
  String get buyCreditDescription;

  /// No description provided for @buyCreditSendIntent.
  ///
  /// In tr, this message translates to:
  /// **'Satın alma niyeti gönder (demo)'**
  String get buyCreditSendIntent;

  /// No description provided for @errorUnexpected.
  ///
  /// In tr, this message translates to:
  /// **'Beklenmeyen bir hata oluştu.'**
  String get errorUnexpected;

  /// No description provided for @errorLoadFailed.
  ///
  /// In tr, this message translates to:
  /// **'Yükleme başarısız oldu.'**
  String get errorLoadFailed;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @dashboardTitle.
  ///
  /// In tr, this message translates to:
  /// **'e-iPAT'**
  String get dashboardTitle;

  /// No description provided for @dashboardWelcome.
  ///
  /// In tr, this message translates to:
  /// **'Hoş geldin, {name}'**
  String dashboardWelcome(String name);

  /// No description provided for @dashboardRemainingTokens.
  ///
  /// In tr, this message translates to:
  /// **'Kalan Token: {count}'**
  String dashboardRemainingTokens(int count);

  /// No description provided for @dashboardBuyTokens.
  ///
  /// In tr, this message translates to:
  /// **'Token Al'**
  String get dashboardBuyTokens;

  /// No description provided for @dashboardParcelQuery.
  ///
  /// In tr, this message translates to:
  /// **'Parsel Sorgula'**
  String get dashboardParcelQuery;

  /// No description provided for @dashboardQueryHistory.
  ///
  /// In tr, this message translates to:
  /// **'Sorgu Geçmişi'**
  String get dashboardQueryHistory;

  /// No description provided for @dashboardPromoCode.
  ///
  /// In tr, this message translates to:
  /// **'Promosyon Kodu'**
  String get dashboardPromoCode;

  /// No description provided for @dashboardPromoHint.
  ///
  /// In tr, this message translates to:
  /// **'Kodu girin'**
  String get dashboardPromoHint;

  /// No description provided for @dashboardPromoUse.
  ///
  /// In tr, this message translates to:
  /// **'Kullan'**
  String get dashboardPromoUse;

  /// No description provided for @dashboardSignOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış Yap'**
  String get dashboardSignOut;

  /// No description provided for @parcelQueryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Parsel Sorgula'**
  String get parcelQueryTitle;

  /// No description provided for @parcelQueryInfo.
  ///
  /// In tr, this message translates to:
  /// **'Parsel Bilgileri'**
  String get parcelQueryInfo;

  /// No description provided for @parcelQueryMahalle.
  ///
  /// In tr, this message translates to:
  /// **'Mahalle'**
  String get parcelQueryMahalle;

  /// No description provided for @parcelQueryMahalleManual.
  ///
  /// In tr, this message translates to:
  /// **'Mahalle (manuel giriş)'**
  String get parcelQueryMahalleManual;

  /// No description provided for @parcelQueryEskiAdaParsel.
  ///
  /// In tr, this message translates to:
  /// **'Eski Ada/Parsel'**
  String get parcelQueryEskiAdaParsel;

  /// No description provided for @parcelQueryYeniAdaParsel.
  ///
  /// In tr, this message translates to:
  /// **'Yeni Ada/Parsel'**
  String get parcelQueryYeniAdaParsel;

  /// No description provided for @parcelQueryHisseAlani.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı Hisse Alanı (m²)'**
  String get parcelQueryHisseAlani;

  /// No description provided for @parcelQueryOptional.
  ///
  /// In tr, this message translates to:
  /// **'Opsiyonel'**
  String get parcelQueryOptional;

  /// No description provided for @parcelQuerySubmit.
  ///
  /// In tr, this message translates to:
  /// **'Sorgula (100 Token)'**
  String get parcelQuerySubmit;

  /// No description provided for @parcelQueryResult.
  ///
  /// In tr, this message translates to:
  /// **'Sorgu Sonucu'**
  String get parcelQueryResult;

  /// No description provided for @queryHistoryTitle.
  ///
  /// In tr, this message translates to:
  /// **'Sorgu Geçmişi'**
  String get queryHistoryTitle;

  /// No description provided for @queryHistoryEmpty.
  ///
  /// In tr, this message translates to:
  /// **'Henüz sorgu yapılmadı.'**
  String get queryHistoryEmpty;

  /// No description provided for @queryHistoryTokens.
  ///
  /// In tr, this message translates to:
  /// **'-{count} token'**
  String queryHistoryTokens(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
