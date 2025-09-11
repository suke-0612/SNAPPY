import 'package:flutter/material.dart';
import 'package:snappy/importer.dart';

/// スクリーンショットに対するアクション（編集・削除）を共通化するサービス
class ScreenshotActionsService {
  /// スクリーンショットから ItemData を作成
  static ItemData createItemDataFromScreenshot({
    required Screenshot screenshot,
    required AssetEntity assetEntity,
  }) {
    return ItemData(
      id: screenshot.assetId,
      text: screenshot.title ?? '',
      category: screenshot.tag ?? 'location',
      location: screenshot.location ?? '',
      description: screenshot.description ?? '',
      assetEntity: assetEntity,
    );
  }

  /// 編集アクションを実行（Screenshot版）
  static void executeEditAction({
    required BuildContext context,
    required Screenshot screenshot,
    required AssetEntity assetEntity,
    required Future<void> Function() onRefresh,
  }) {
    final ItemData item = createItemDataFromScreenshot(
      screenshot: screenshot,
      assetEntity: assetEntity,
    );

    Navigator.of(context).pop(); // 現在のダイアログを閉じる
    showEditItemPopup(context, item: item, onRefresh: onRefresh);
  }

  /// 編集アクションを実行（ItemData版）
  static void executeEditActionFromItem({
    required BuildContext context,
    required ItemData item,
    required Future<void> Function() onRefresh,
  }) {
    Navigator.of(context).pop(); // 現在のダイアログを閉じる
    showEditItemPopup(context, item: item, onRefresh: onRefresh);
  }

  /// 削除アクションを実行（Screenshot版）
  static void executeDeleteAction({
    required BuildContext context,
    required Screenshot screenshot,
    required AssetEntity assetEntity,
    VoidCallback? onRefresh,
    Function(String)? onError,
  }) {
    Navigator.of(context).pop(); // 現在のダイアログを閉じる

    DeleteItemService.deleteScreenshotWithAuth(
      context: context,
      assetEntity: assetEntity,
      assetId: screenshot.assetId,
      onSuccess: () {
        onRefresh?.call();
      },
      onError: onError,
    );
  }

  /// 削除アクションを実行（ItemData版）
  static void executeDeleteActionFromItem({
    required BuildContext context,
    required ItemData item,
    VoidCallback? onRefresh,
    Function(String)? onError,
  }) {
    Navigator.of(context).pop(); // 現在のダイアログを閉じる

    DeleteItemService.deleteScreenshotWithAuth(
      context: context,
      assetEntity: item.assetEntity!,
      assetId: item.id,
      onSuccess: () {
        onRefresh?.call();
      },
      onError: onError,
    );
  }

  /// PopupContainer の編集・削除コールバックを生成（Screenshot版）
  static Map<String, VoidCallback> generatePopupCallbacks({
    required BuildContext context,
    required Screenshot screenshot,
    required AssetEntity assetEntity,
    required Future<void> Function() onRefresh,
    Function(String)? onError,
  }) {
    return {
      'onEdit': () => executeEditAction(
            context: context,
            screenshot: screenshot,
            assetEntity: assetEntity,
            onRefresh: onRefresh,
          ),
      'onDelete': () => executeDeleteAction(
            context: context,
            screenshot: screenshot,
            assetEntity: assetEntity,
            onRefresh: onRefresh,
            onError: onError,
          ),
    };
  }

  /// PopupContainer の編集・削除コールバックを生成（ItemData版）
  static Map<String, VoidCallback> generatePopupCallbacksFromItem({
    required BuildContext context,
    required ItemData item,
    required Future<void> Function() onRefresh,
    Function(String)? onError,
  }) {
    return {
      'onEdit': () => executeEditActionFromItem(
            context: context,
            item: item,
            onRefresh: onRefresh,
          ),
      'onDelete': () => executeDeleteActionFromItem(
            context: context,
            item: item,
            onRefresh: onRefresh,
            onError: onError,
          ),
    };
  }

  /// 統一されたPopupContainerを表示（Screenshot版）
  static void showScreenshotPopup({
    required BuildContext context,
    required Screenshot screenshot,
    required AssetEntity assetEntity,
    required Future<void> Function() onRefresh,
    Function(String)? onError,
  }) {
    final callbacks = generatePopupCallbacks(
      context: context,
      screenshot: screenshot,
      assetEntity: assetEntity,
      onRefresh: onRefresh,
      onError: onError,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) {
        return PopupContainer(
          item: createItemDataFromScreenshot(
            screenshot: screenshot,
            assetEntity: assetEntity,
          ),
          onPressedEdit: callbacks['onEdit']!,
          onPressedDelete: callbacks['onDelete']!,
        );
      },
    );
  }

  /// 統一されたPopupContainerを表示（ItemData版）
  static void showItemPopup({
    required BuildContext context,
    required ItemData item,
    String? title,
    String? location,
    required Future<void> Function() onRefresh,
    Function(String)? onError,
  }) {
    final callbacks = generatePopupCallbacksFromItem(
      context: context,
      item: item,
      onRefresh: onRefresh,
      onError: onError,
    );

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: PopupContainer(
            item: item,
            onPressedEdit: callbacks['onEdit']!,
            onPressedDelete: callbacks['onDelete']!,
          ),
        ),
      ),
    );
  }
}
