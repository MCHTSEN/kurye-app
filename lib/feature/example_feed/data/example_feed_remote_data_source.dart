import 'package:backend_core/backend_core.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../product/network/api_client_provider.dart';
import '../domain/example_feed_item.dart';

part 'example_feed_remote_data_source.g.dart';

class ExampleFeedRemoteDataSource {
  const ExampleFeedRemoteDataSource({required ApiClient apiClient})
    : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<ExampleFeedItem>> fetchItems() async {
    final response = await _apiClient.get('/example-feed');
    final rawItems = response['items'];

    if (rawItems is! List) {
      return const <ExampleFeedItem>[];
    }

    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(ExampleFeedItem.fromJson)
        .toList(growable: false);
  }
}

@Riverpod(keepAlive: true)
ExampleFeedRemoteDataSource exampleFeedRemoteDataSource(Ref ref) {
  return ExampleFeedRemoteDataSource(
    apiClient: ref.watch(apiClientProvider),
  );
}
