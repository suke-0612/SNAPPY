import 'package:flutter/material.dart';
import 'package:snappy/importer.dart'; // ご自身のプロジェクトのパスに合わせてください

// グローバルな関数として定義
Future<void> showEditItemPopup(
  BuildContext context, {
  required ItemData item,
  VoidCallback? onEdit,
}) async {
  // showModalBottomSheetのロジックを完全にここにカプセル化する
  await showModalBottomSheet<void>(
    backgroundColor: Colors.white,
    context: context,
    isScrollControlled: true,
    builder: (modalContext) => Padding(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 24.0,
        bottom: MediaQuery.of(modalContext).viewInsets.bottom + 24.0,
      ),
      child: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: EditItemInfoForm(
            item: item,
            onSubmit: () {
              onEdit?.call();
              Navigator.of(modalContext).pop();
            },
            onRefresh: () async {},
          ),
        ),
      ),
    ),
  );
}
