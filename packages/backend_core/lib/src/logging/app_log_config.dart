enum LogTag {
  auth,
  data,
  network,
  router,
  onboarding,
  credit,
  analytics,
  ui,
  general,
  notification,
}

class AppLogConfig {
  AppLogConfig({
    this.auth = true,
    this.data = true,
    this.network = true,
    this.router = true,
    this.onboarding = true,
    this.credit = true,
    this.analytics = true,
    this.ui = true,
    this.general = true,
    this.notification = true,
    this.enabled = true,
  });

  final bool auth;
  final bool data;
  final bool network;
  final bool router;
  final bool onboarding;
  final bool credit;
  final bool analytics;
  final bool ui;
  final bool general;
  final bool notification;
  final bool enabled;

  bool isEnabled(LogTag tag) {
    if (!enabled) return false;

    switch (tag) {
      case LogTag.auth:
        return auth;
      case LogTag.data:
        return data;
      case LogTag.network:
        return network;
      case LogTag.router:
        return router;
      case LogTag.onboarding:
        return onboarding;
      case LogTag.credit:
        return credit;
      case LogTag.analytics:
        return analytics;
      case LogTag.ui:
        return ui;
      case LogTag.general:
        return general;
      case LogTag.notification:
        return notification;
    }
  }
}

AppLogConfig logConfig = AppLogConfig();
