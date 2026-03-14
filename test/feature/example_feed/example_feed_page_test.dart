import 'package:bursamotokurye/feature/example_feed/presentation/example_feed_page.dart';
import 'package:bursamotokurye/product/network/api_client_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes/fake_analytics_service.dart';
import '../../helpers/fakes/fake_api_client.dart';
import '../../helpers/robots/example_feed_robot.dart';
import '../../helpers/widgets/test_app.dart';

void main() {
  testWidgets('renders remote items and tracks selection', (tester) async {
    final analytics = FakeAnalyticsService();

    await tester.pumpApp(
      const ExampleFeedPage(),
      analyticsService: analytics,
      overrides: [
        apiClientProvider.overrideWithValue(
          FakeApiClient(
            getResponses: <String, dynamic>{
              '/example-feed': <String, dynamic>{
                'items': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 'alpha',
                    'title': 'Alpha item',
                    'subtitle': 'Loaded from fake api',
                    'category': 'template',
                  },
                ],
              },
            },
          ),
        ),
      ],
    );

    await tester.pumpAndSettle();

    final robot = ExampleFeedRobot(tester);
    expect(robot.title, findsOneWidget);
    expect(robot.firstItem, findsOneWidget);

    await tester.tap(robot.firstItem);
    await tester.pumpAndSettle();

    expect(
      analytics.trackedEvents.map((event) => event.name),
      contains('example_feed_item_selected'),
    );
  });

  testWidgets('refresh button tracks refreshed event', (tester) async {
    final analytics = FakeAnalyticsService();

    await tester.pumpApp(
      const ExampleFeedPage(),
      analyticsService: analytics,
      overrides: [
        apiClientProvider.overrideWithValue(
          FakeApiClient(
            getResponses: <String, dynamic>{
              '/example-feed': <String, dynamic>{
                'items': <Map<String, dynamic>>[
                  <String, dynamic>{
                    'id': 'alpha',
                    'title': 'Alpha item',
                    'subtitle': 'Loaded from fake api',
                    'category': 'template',
                  },
                ],
              },
            },
          ),
        ),
      ],
    );

    await tester.pumpAndSettle();

    final robot = ExampleFeedRobot(tester);
    await robot.tapRefresh();
    await tester.pumpAndSettle();

    expect(
      analytics.trackedEvents.map((event) => event.name),
      contains('example_feed_refreshed'),
    );
  });
}
