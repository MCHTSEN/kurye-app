import 'package:eipat/core/runtime/crash_reporting_service.dart';

class FakeCrashReportingService implements CrashReportingService {
  final List<Object> recordedErrors = <Object>[];

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    Map<String, Object?> context = const <String, Object?>{},
  }) async {
    recordedErrors.add(error);
  }
}
