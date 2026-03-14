import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../product/analytics/analytics_provider.dart';
import '../data/example_feed_repository_impl.dart';
import '../domain/example_feed_item.dart';

part 'example_feed_controller.g.dart';

@Riverpod(keepAlive: true)
class ExampleFeedController extends _$ExampleFeedController {
  @override
  Future<List<ExampleFeedItem>> build() {
    return ref.watch(exampleFeedRepositoryProvider).load();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    final nextState = await AsyncValue.guard(
      () => ref.read(exampleFeedRepositoryProvider).load(forceRefresh: true),
    );
    if (!ref.mounted) {
      return;
    }

    state = nextState;

    if (!nextState.hasError) {
      await ref
          .read(analyticsServiceProvider)
          .track(
            const AnalyticsEvent(name: 'example_feed_refreshed'),
          );
    }
  }

  Future<void> trackSelection(ExampleFeedItem item) {
    return ref
        .read(analyticsServiceProvider)
        .track(
          AnalyticsEvent(
            name: 'example_feed_item_selected',
            properties: <String, Object?>{
              'item_id': item.id,
              'category': item.category,
            },
          ),
        );
  }
}
