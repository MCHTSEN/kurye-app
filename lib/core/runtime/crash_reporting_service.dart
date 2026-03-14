abstract class CrashReportingService {
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> context = const <String, Object?>{},
  });
}
