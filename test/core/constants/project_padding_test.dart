import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/core/constants/project_padding.dart';

void main() {
  group('ProjectPadding', () {
    test('all.normal returns expected inset', () {
      expect(ProjectPadding.all.normal, const EdgeInsets.all(16));
    });

    test('horizontal and vertical presets are consistent', () {
      expect(
        ProjectPadding.horizontal.normal,
        const EdgeInsets.symmetric(horizontal: 16),
      );
      expect(
        ProjectPadding.vertical.normal,
        const EdgeInsets.symmetric(vertical: 16),
      );
    });
  });
}
