import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../product/widgets/app_section_card.dart';

class OperasyonEkranPage extends ConsumerWidget {
  const OperasyonEkranPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operasyon Ekranı')),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: const [
          // TODO(sprint3): 3-panel operasyon ekranı
          AppSectionCard(
            title: 'Sipariş Oluşturma Paneli',
            child: Text("Sprint 3'te implement edilecek."),
          ),
          SizedBox(height: 16),
          AppSectionCard(
            title: 'Kurye Bekleyenler',
            child: Text("Sprint 3'te implement edilecek."),
          ),
          SizedBox(height: 16),
          AppSectionCard(
            title: 'Devam Edenler',
            child: Text("Sprint 3'te implement edilecek."),
          ),
        ],
      ),
    );
  }
}
