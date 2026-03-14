import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class ExampleFeedRobot {
  const ExampleFeedRobot(this.tester);

  final WidgetTester tester;

  Finder get title => find.text('Example Feed');
  Finder get firstItem => find.text('Alpha item');
  Finder get refreshButton => find.byIcon(Icons.refresh);

  Future<void> tapRefresh() async {
    await tester.tap(refreshButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
  }
}
