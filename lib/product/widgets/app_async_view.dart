import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import 'app_empty_state.dart';
import 'app_error_state.dart';

class AppAsyncView<T> extends StatelessWidget {
  const AppAsyncView({
    required this.value,
    required this.data,
    super.key,
    this.loading,
    this.empty,
    this.error,
    this.isEmpty,
  });

  final AsyncValue<T> value;
  final Widget Function(BuildContext context, T data) data;
  final WidgetBuilder? loading;
  final WidgetBuilder? empty;
  final Widget Function(
    BuildContext context,
    Object error,
    StackTrace stackTrace,
  )?
  error;
  final bool Function(T data)? isEmpty;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return value.when(
      data: (resolved) {
        final emptyState = isEmpty?.call(resolved) ?? false;
        if (emptyState) {
          return empty?.call(context) ??
              AppEmptyState(
                title: l10n.homeSkeletonReady,
                message: l10n.exampleFeedEmpty,
              );
        }

        return data(context, resolved);
      },
      loading: () =>
          loading?.call(context) ??
          const Center(child: CircularProgressIndicator()),
      error: (errorValue, stackTrace) =>
          error?.call(context, errorValue, stackTrace) ??
          AppErrorState(
            title: l10n.errorUnexpected,
            message: l10n.errorLoadFailed,
            retryLabel: l10n.retry,
          ),
    );
  }
}
