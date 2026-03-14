import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../product/widgets/app_section_card.dart';

class MusteriKayitPage extends ConsumerWidget {
  const MusteriKayitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Müşteri Kayıt')),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: const [
          // TODO(sprint4): Müşteri CRUD formu + alt tablo
          AppSectionCard(
            title: 'Müşteri Kayıt',
            child: Text("Sprint 4'te implement edilecek."),
          ),
        ],
      ),
    );
  }
}
