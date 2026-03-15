// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Fetches 90-day order history + all couriers, then computes dashboard
/// analytics via the pure [DashboardStats.compute] factory.

@ProviderFor(dashboardStats)
const dashboardStatsProvider = DashboardStatsProvider._();

/// Fetches 90-day order history + all couriers, then computes dashboard
/// analytics via the pure [DashboardStats.compute] factory.

final class DashboardStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DashboardStats>,
          DashboardStats,
          FutureOr<DashboardStats>
        >
    with $FutureModifier<DashboardStats>, $FutureProvider<DashboardStats> {
  /// Fetches 90-day order history + all couriers, then computes dashboard
  /// analytics via the pure [DashboardStats.compute] factory.
  const DashboardStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardStatsHash();

  @$internal
  @override
  $FutureProviderElement<DashboardStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DashboardStats> create(Ref ref) {
    return dashboardStats(ref);
  }
}

String _$dashboardStatsHash() => r'3f0c233b247002b08116b19cc58cba9a7cef8d2a';
