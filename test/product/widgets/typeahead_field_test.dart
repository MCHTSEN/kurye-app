import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuryem/product/widgets/typeahead_field.dart';

import '../../helpers/widgets/test_app.dart';

class _TypeaheadHarness extends StatefulWidget {
  const _TypeaheadHarness();

  @override
  State<_TypeaheadHarness> createState() => _TypeaheadHarnessState();
}

class _TypeaheadHarnessState extends State<_TypeaheadHarness> {
  String? selected;
  final nextFocus = FocusNode();

  @override
  void dispose() {
    nextFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TypeaheadField<String>(
              key: const Key('typeahead'),
              label: 'Müşteri',
              placeholder: 'Ara...',
              value: selected,
              items: const [
                (value: 'm1', label: 'Firma A'),
                (value: 'm2', label: 'Firma B'),
              ],
              onChanged: (v) => setState(() => selected = v),
              nextFocus: nextFocus,
            ),
            const SizedBox(height: 20),
            TextField(
              key: const Key('next-field'),
              focusNode: nextFocus,
            ),
            Text('selected: ${selected ?? 'none'}'),
          ],
        ),
      ),
    );
  }
}

class _DynamicItemsHarness extends StatefulWidget {
  const _DynamicItemsHarness();

  @override
  State<_DynamicItemsHarness> createState() => _DynamicItemsHarnessState();
}

class _DynamicItemsHarnessState extends State<_DynamicItemsHarness> {
  List<({String value, String label})> items = const [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TypeaheadField<String>(
            key: const Key('dynamic-typeahead'),
            label: 'Personel',
            items: items,
            onChanged: (_) {},
          ),
          TextButton(
            key: const Key('load-items'),
            onPressed: () {
              setState(() {
                items = const [
                  (value: 'p1', label: 'Ahmet'),
                  (value: 'p2', label: 'Mehmet'),
                ];
              });
            },
            child: const Text('Load'),
          ),
        ],
      ),
    );
  }
}

void main() {
  testWidgets('shows all suggestions on tap when query is empty', (
    tester,
  ) async {
    await tester.pumpApp(const _TypeaheadHarness());

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    expect(find.text('Firma A'), findsOneWidget);
    expect(find.text('Firma B'), findsOneWidget);
  });

  testWidgets('selects suggestion by pointer tap without pressing Enter', (
    tester,
  ) async {
    await tester.pumpApp(const _TypeaheadHarness());

    await tester.tap(find.byType(TextField).first);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Firma B');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Firma B').last);
    await tester.pumpAndSettle();

    expect(find.text('selected: m2'), findsOneWidget);
    expect(find.text('Firma B'), findsOneWidget);
  });

  testWidgets(
    'does not throw when items update while field is focused',
    (tester) async {
      await tester.pumpApp(const _DynamicItemsHarness());

      await tester.tap(find.byType(TextField).first);
      await tester.pump();

      await tester.tap(find.byKey(const Key('load-items')));
      await tester.pump();

      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();

      expect(find.text('Ahmet'), findsOneWidget);
      expect(find.text('Mehmet'), findsOneWidget);
    },
  );
}
