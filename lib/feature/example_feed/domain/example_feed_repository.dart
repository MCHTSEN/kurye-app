import 'example_feed_item.dart';

abstract class ExampleFeedRepository {
  Future<List<ExampleFeedItem>> load({bool forceRefresh = false});
}
