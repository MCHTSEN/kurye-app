import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({required this.details, super.key});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      return ErrorWidget(details.exception);
    }

    return const Material(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Beklenmeyen bir hata oluştu.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
