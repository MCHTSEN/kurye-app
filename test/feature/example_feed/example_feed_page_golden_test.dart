import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:kuryem/feature/example_feed/presentation/example_feed_page.dart';
import 'package:kuryem/product/network/api_client_provider.dart';

import '../../helpers/fakes/fake_api_client.dart';
import '../../helpers/widgets/test_app.dart';

void main() {
  testGoldens('ExampleFeedPage matches golden', (tester) async {
    await tester.pumpApp(
      const ExampleFeedPage(),
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
                  <String, dynamic>{
                    'id': 'beta',
                    'title': 'Beta item',
                    'subtitle': 'Second row',
                    'category': 'runtime',
                  },
                ],
              },
            },
          ),
        ),
      ],
    );

    await tester.pumpAndSettle();

    await screenMatchesGolden(tester, 'example_feed_page');
  });
}
