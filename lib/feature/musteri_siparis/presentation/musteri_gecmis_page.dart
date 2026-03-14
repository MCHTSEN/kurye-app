import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../product/widgets/app_section_card.dart';

class MusteriGecmisPage extends ConsumerWidget {
  const MusteriGecmisPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Geçmiş Siparişler')),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: const [
          // TODO(sprint2): Tarih filtresi + geçmiş sipariş listesi
          AppSectionCard(
            title: 'Geçmiş Siparişler',
            child: Text("Sprint 2'de implement edilecek."),
          ),
        ],
      ),
    );
  }
}
