import 'analytics_event.dart';

/// Central analytics event catalog.
///
/// All analytics events should be defined here to ensure
/// consistent naming and required properties across the app.
abstract final class AppEvents {
  // ── Auth ──────────────────────────────────────────────
  static AnalyticsEvent authSignInSuccess(String authType) => AnalyticsEvent(
    name: 'auth_sign_in_success',
    properties: {'auth_type': authType},
  );

  static const authSignOut = AnalyticsEvent(name: 'auth_sign_out');

  static AnalyticsEvent authSignInFailed(String authType, String error) =>
      AnalyticsEvent(
        name: 'auth_sign_in_failed',
        properties: {'auth_type': authType, 'error': error},
      );

  // ── Screen Views ──────────────────────────────────────
  static AnalyticsEvent screenViewed(String screenName) =>
      AnalyticsEvent.screenViewed(screenName);

  // ── Credit / Payment ──────────────────────────────────
  static const creditPurchaseIntent = AnalyticsEvent(
    name: 'credit_purchase_intent',
  );

  static AnalyticsEvent creditPurchaseSuccess({
    required String productId,
    String? transactionId,
  }) => AnalyticsEvent(
    name: 'credit_purchase_success',
    properties: <String, Object?>{
      'product_id': productId,
      'transaction_id': transactionId,
    },
  );

  static AnalyticsEvent creditPurchaseFailed({
    required String productId,
    required String error,
  }) => AnalyticsEvent(
    name: 'credit_purchase_failed',
    properties: {'product_id': productId, 'error': error},
  );

  static const creditInsufficient = AnalyticsEvent(name: 'credit_insufficient');

  // ── Onboarding ────────────────────────────────────────
  static const onboardingStarted = AnalyticsEvent(name: 'onboarding_started');

  static const onboardingCompleted = AnalyticsEvent(
    name: 'onboarding_completed',
  );

  static AnalyticsEvent onboardingStepViewed(int step) => AnalyticsEvent(
    name: 'onboarding_step_viewed',
    properties: {'step': step},
  );

  // ── Parcel Query (e-iPAT specific) ────────────────────
  static AnalyticsEvent parcelQueried({
    required String mahalle,
    required String adaParsel,
  }) => AnalyticsEvent(
    name: 'parcel_queried',
    properties: {'mahalle': mahalle, 'ada_parsel': adaParsel},
  );

  static const parcelQueryFailed = AnalyticsEvent(name: 'parcel_query_failed');

  // ── PDF / Report ──────────────────────────────────────
  static AnalyticsEvent reportGenerated(String queryId) => AnalyticsEvent(
    name: 'report_generated',
    properties: {'query_id': queryId},
  );

  static AnalyticsEvent reportShared(String queryId) => AnalyticsEvent(
    name: 'report_shared',
    properties: {'query_id': queryId},
  );

  // ── Navigation ────────────────────────────────────────
  static AnalyticsEvent deepLinkOpened(String path) => AnalyticsEvent(
    name: 'deep_link_opened',
    properties: {'path': path},
  );

  static AnalyticsEvent operasyonTabSelected(String tabName) => AnalyticsEvent(
    name: 'operasyon_tab_selected',
    properties: {'tab_name': tabName},
  );

  static AnalyticsEvent operasyonSettingsItemSelected(String itemName) =>
      AnalyticsEvent(
        name: 'operasyon_settings_item_selected',
        properties: {'item_name': itemName},
      );

  static const operasyonReportsUnlocked = AnalyticsEvent(
    name: 'operasyon_reports_unlocked',
  );

  // ── Promo ─────────────────────────────────────────────
  static AnalyticsEvent promoRedeemed(String code) => AnalyticsEvent(
    name: 'promo_redeemed',
    properties: {'code': code},
  );

  static AnalyticsEvent promoFailed(String code, String error) =>
      AnalyticsEvent(
        name: 'promo_failed',
        properties: {'code': code, 'error': error},
      );
}
