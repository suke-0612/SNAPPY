import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:snappy/components/custom_button.dart';

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                alignment: Alignment.centerLeft,
                child: const Row(
                  children: [
                    Icon(Icons.photo, color: Colors.black),
                    SizedBox(width: 8),
                    Text(
                      '写真アクセスの設定',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 30),
                        const SizedBox(width: 16),
                        Text(
                          statusText,
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: statusColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (_permissionState == PermissionState.limited)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20.0),
                  width: double.infinity,
                  child: CustomButton(
                    onPressed: _addAccess,
                    label: '他の写真へのアクセスを追加',
                    backgroundColor: Colors.orange[800]!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
