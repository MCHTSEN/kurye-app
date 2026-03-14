import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../product/widgets/app_section_card.dart';

class OperasyonGecmisPage extends ConsumerWidget {
  const OperasyonGecmisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş Siparişler')),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: const [
          // TODO(sprint4): Filtreleme + düzenleme paneli
          AppSectionCard(
            title: 'Geçmiş Siparişler',
            child: Text("Sprint 4'te implement edilecek."),
          ),
        ],
      ),
    );
  }
}
