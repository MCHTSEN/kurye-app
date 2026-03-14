import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/project_padding.dart';
import '../../../product/widgets/app_section_card.dart';

class UgramaYonetimPage extends ConsumerWidget {
  const UgramaYonetimPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Uğrama Yönetimi')),
      body: ListView(
        padding: ProjectPadding.all.normal,
        children: const [
          // TODO(sprint4): Uğrama CRUD + lokasyon (Geography)
          AppSectionCard(
            title: 'Uğrama Yönetimi',
            child: Text("Sprint 4'te implement edilecek."),
          ),
        ],
      ),
    );
  }
}
