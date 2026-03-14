import '../../../core/runtime/crash_reporting_service.dart';

class NoopCrashReportingService implements CrashReportingService {
  const NoopCrashReportingService();

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> context = const <String, Object?>{},
  }) async {}
}
