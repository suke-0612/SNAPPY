import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snappy/importer.dart';

/// スクリーンショットとDBレコードを削除する関数
class DeleteItemService {
  static Future<void> deleteScreenshotWithAuth({
    required BuildContext context,
    required AssetEntity assetEntity,
    required String assetId,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // 写真削除の権限を確認
      final PermissionState permissionState =
          await PhotoManager.requestPermissionExtend();

      if (!permissionState.hasAccess) {
        if (onError != null) {
          onError('写真へのアクセス権限がありません。設定から権限を有効にしてください。');
        }
        return;
      }

      // スマートフォンからスクリーンショットを削除
      final List<String> result =
          await PhotoManager.editor.deleteWithIds([assetEntity.id]);

      // DBからレコードを削除
      await _deleteFromDatabase(assetId);

      // 成功時の処理
      if (onSuccess != null) {
        onSuccess();
      }
    } catch (e) {
      null;
    }
  }

  /// データベースからスクリーンショットレコードを削除
  static Future<void> _deleteFromDatabase(String assetId) async {
    try {
      final isar = await openIsarInstance();

      // アセットIDに一致するスクリーンショットを検索
      final screenshot =
          await isar.screenshots.filter().assetIdEqualTo(assetId).findFirst();

      if (screenshot != null) {
        // トランザクション内で削除
        await isar.writeTxn(() async {
          await isar.screenshots.delete(screenshot.id);
        });
      }
    } catch (e) {
      null;
    }
  }

  /// 複数のスクリーンショットを一括削除する（認証付き）
  static Future<void> deleteBulkScreenshotsWithAuth({
    required BuildContext context,
    required Map<AssetEntity, String> items,
    VoidCallback? onSuccess,
    Function(String)? onError,
  }) async {
    try {
      // 2. 権限確認
      final PermissionState permissionState =
          await PhotoManager.requestPermissionExtend();

      if (!permissionState.hasAccess) {
        if (onError != null) {
          onError('写真へのアクセス権限がありません。');
        }
        return;
      }

      // 3. 一括削除実行
      final List<String> assetIds =
          items.keys.map((asset) => asset.id).toList();
      final List<String> result =
          await PhotoManager.editor.deleteWithIds(assetIds);

      // 4. DBから一括削除
      for (String assetId in items.values) {
        await _deleteFromDatabase(assetId);
      }

      // 5. 成功処理
      if (onSuccess != null) {
        onSuccess();
      }
    } catch (e) {
      if (onError != null) {
        onError('一括削除に失敗しました: ${e.toString()}');
      }
    }
  }
}
