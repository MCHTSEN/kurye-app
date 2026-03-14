import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/app_localizations.dart';
import '../../../product/widgets/app_async_view.dart';
import '../../../product/widgets/app_empty_state.dart';
import '../../../product/widgets/app_error_state.dart';
import '../../../product/widgets/app_page_scaffold.dart';
import '../application/example_feed_controller.dart';
import '../domain/example_feed_item.dart';

class ExampleFeedPage extends ConsumerWidget {
  const ExampleFeedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(exampleFeedControllerProvider.notifier);
    final state = ref.watch(exampleFeedControllerProvider);

    return AppPageScaffold(
      title: l10n.exampleFeedTitle,
      scrollable: false,
      actions: <Widget>[
        IconButton(
          onPressed: controller.refresh,
          icon: const Icon(Icons.refresh),
          tooltip: l10n.retry,
        ),
      ],
      child: AppAsyncView<List<ExampleFeedItem>>(
        value: state,
        isEmpty: (items) => items.isEmpty,
        empty: (context) => AppEmptyState(
          title: l10n.exampleFeedEmptyTitle,
          message: l10n.exampleFeedEmpty,
          actionLabel: l10n.retry,
          onAction: controller.refresh,
        ),
        error: (context, error, stackTrace) => AppErrorState(
          title: l10n.exampleFeedErrorTitle,
          message: l10n.exampleFeedErrorBody,
          retryLabel: l10n.retry,
          onRetry: controller.refresh,
        ),
        data: (context, items) => RefreshIndicator(
          onRefresh: controller.refresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ExampleFeedTile(
                item: item,
                onTap: () async {
                  await controller.trackSelection(item);
                  if (!context.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.exampleFeedSelected(item.title)),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ExampleFeedTile extends StatelessWidget {
  const _ExampleFeedTile({required this.item, required this.onTap});

  final ExampleFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(item.title),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(item.subtitle),
        ),
        trailing: Chip(label: Text(item.category)),
        onTap: onTap,
      ),
    );
  }
}
