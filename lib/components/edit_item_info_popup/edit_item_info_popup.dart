import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

Future<bool?> showEditItemPopup(
  BuildContext context, {
  required ItemData item,
  required Future<void> Function() onRefresh,
}) {
  return showModalBottomSheet<bool>(
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
        child: EditItemInfoForm(
          item: item,
          onRefresh: onRefresh,
        ),
      ),
    ),
  );
}
