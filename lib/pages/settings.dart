import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snappy/components/base_screen.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  PermissionState _permissionState = PermissionState.denied;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final ps = await PhotoManager.requestPermissionExtend();
    setState(() {
      _permissionState = ps;
    });
  }

  Future<void> _addAccess() async {
    if (_permissionState == PermissionState.limited) {
      await PhotoManager.presentLimited();
      await _checkPermission();
    }
  }

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (_permissionState == PermissionState.authorized) {
      statusText = 'フルアクセス許可済み';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (_permissionState == PermissionState.limited) {
      statusText = '限定アクセス許可済み';
      statusColor = Colors.orange;
      statusIcon = Icons.photo_library_outlined;
    } else {
      statusText = 'アクセス拒否中';
      statusColor = Colors.red;
      statusIcon = Icons.block;
    }

    return Scaffold(
      body: BaseScreen(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 40),
                        const SizedBox(width: 16),
                        Text(
                          statusText,
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                if (_permissionState == PermissionState.limited)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _addAccess,
                      icon: const Icon(Icons.add_photo_alternate),
                      label: const Text('他の写真へのアクセスを追加'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
