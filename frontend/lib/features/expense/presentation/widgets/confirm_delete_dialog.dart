import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

Future<bool> showConfirmDeleteDialog(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('ลบรายการนี้?'),
      content: const Text('เมื่อลบแล้วจะไม่สามารถกู้คืนได้'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ยกเลิก')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: AppColors.clay),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('ลบ'),
        ),
      ],
    ),
  );
  return confirmed ?? false;
}
