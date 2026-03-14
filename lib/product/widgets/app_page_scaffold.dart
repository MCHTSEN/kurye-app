import 'package:flutter/material.dart';

import '../../core/constants/project_padding.dart';

class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    required this.title,
    required this.child,
    super.key,
    this.actions,
    this.padding,
    this.scrollable = true,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final body = scrollable
        ? ListView(
            padding: padding ?? ProjectPadding.all.normal,
            children: <Widget>[child],
          )
        : Padding(
            padding: padding ?? ProjectPadding.all.normal,
            child: child,
          );

    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: body,
    );
  }
}
