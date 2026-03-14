// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'eipat';

  @override
  String get onboardingTitle => 'Onboarding';

  @override
  String get onboardingBody =>
      'Bu ekran gelecekteki projelerde tekrar kullanılacak onboarding modülü iskeletidir.';

  @override
  String get onboardingContinue => 'Devam et';

  @override
  String get authTitle => 'Kimlik Doğrulama';

  @override
  String authBackendLabel(String provider) {
    return 'Aktif provider: $provider';
  }

  @override
  String get authDescription =>
      'Bu iskelette anonymous login ile auth akışı test edilir. E-posta/şifre ve OAuth da desteklenir.';

  @override
  String get authSignInAnonymous => 'Anonim giriş yap';

  @override
  String get authSignInWithEmail => 'E-posta ile giriş yap';

  @override
  String get authEmail => 'E-posta';

  @override
  String get authPassword => 'Şifre';

  @override
  String get authBackendSelection => 'Backend Seçimi';

  @override
  String get authSignInWithGoogle => 'Google ile giriş yap';

  @override
  String get authOrDivider => 'veya';

  @override
  String get authRegister => 'Kayıt ol';

  @override
  String get authName => 'Ad Soyad';

  @override
  String get homeTitle => 'Ana Sayfa';

  @override
  String get homeSkeletonReady => 'İskelet Hazır';

  @override
  String get homeSkeletonDescription =>
      'Auth, onboarding, profile ve backend adapter yapısı Riverpod 3 ile kuruludur.';

  @override
  String get homeOpenExampleFeed => 'Ornek Feed Ac';

  @override
  String get homeGoToProfile => 'Profile Git';

  @override
  String get homeBuyCredit => 'Buy Credit';

  @override
  String get homeSignOut => 'Çıkış Yap';

  @override
  String get exampleFeedTitle => 'Ornek Feed';

  @override
  String get exampleFeedEmptyTitle => 'Ornek Icerik Yok';

  @override
  String get exampleFeedEmpty =>
      'Ornek feed bos. Son sample veriyi cekmek icin yenileyin.';

  @override
  String get exampleFeedErrorTitle => 'Ornek feed yuklenemedi';

  @override
  String get exampleFeedErrorBody =>
      'Template feed yuklenemedi. Slice\'i tekrar dogrulamak icin yeniden deneyin.';

  @override
  String exampleFeedSelected(String title) {
    return '$title secildi';
  }

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileUser => 'Kullanıcı';

  @override
  String get profileNoSession => 'Aktif oturum yok';

  @override
  String get profileError => 'Profil verisi yüklenemedi';

  @override
  String get buyCreditTitle => 'Buy Credit';

  @override
  String get buyCreditInsufficientTitle => 'Kredi Yetersiz';

  @override
  String get buyCreditDescription =>
      'Bu ekran merkezi credit guard ile açılır. Gerçek ödeme adapterları buraya bağlanır.';

  @override
  String get buyCreditSendIntent => 'Satın alma niyeti gönder (demo)';

  @override
  String get errorUnexpected => 'Beklenmeyen bir hata oluştu.';

  @override
  String get errorLoadFailed => 'Yükleme başarısız oldu.';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get dashboardTitle => 'e-iPAT';

  @override
  String dashboardWelcome(String name) {
    return 'Hoş geldin, $name';
  }

  @override
  String dashboardRemainingTokens(int count) {
    return 'Kalan Token: $count';
  }

  @override
  String get dashboardBuyTokens => 'Token Al';

  @override
  String get dashboardParcelQuery => 'Parsel Sorgula';

  @override
  String get dashboardQueryHistory => 'Sorgu Geçmişi';

  @override
  String get dashboardPromoCode => 'Promosyon Kodu';

  @override
  String get dashboardPromoHint => 'Kodu girin';

  @override
  String get dashboardPromoUse => 'Kullan';

  @override
  String get dashboardSignOut => 'Çıkış Yap';

  @override
  String get parcelQueryTitle => 'Parsel Sorgula';

  @override
  String get parcelQueryInfo => 'Parsel Bilgileri';

  @override
  String get parcelQueryMahalle => 'Mahalle';

  @override
  String get parcelQueryMahalleManual => 'Mahalle (manuel giriş)';

  @override
  String get parcelQueryEskiAdaParsel => 'Eski Ada/Parsel';

  @override
  String get parcelQueryYeniAdaParsel => 'Yeni Ada/Parsel';

  @override
  String get parcelQueryHisseAlani => 'Kullanıcı Hisse Alanı (m²)';

  @override
  String get parcelQueryOptional => 'Opsiyonel';

  @override
  String get parcelQuerySubmit => 'Sorgula (100 Token)';

  @override
  String get parcelQueryResult => 'Sorgu Sonucu';

  @override
  String get queryHistoryTitle => 'Sorgu Geçmişi';

  @override
  String get queryHistoryEmpty => 'Henüz sorgu yapılmadı.';

  @override
  String queryHistoryTokens(int count) {
    return '-$count token';
  }
}
