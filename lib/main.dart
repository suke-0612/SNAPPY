import 'package:flutter/services.dart';
import 'package:snappy/app.dart';
import 'package:flutter/material.dart';

//TODO:envファイルの読み込み

void main() {
  //画面の向きを縦に固定
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}
