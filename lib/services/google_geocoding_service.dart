import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GoogleGeocodingService {
  static String get _apiKey => dotenv.env['googleServiceAPI'] ?? '';
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/geocode/json';

  /// 住所から座標を取得
  static Future<GeocodingResult?> getCoordinatesFromAddress(
      String address) async {
    try {
      // APIキーの確認
      if (!isApiKeyConfigured()) {
        debugPrint('Google Geocoding API: APIキーが設定されていません');
        return null;
      }

      debugPrint('Google Geocoding API: APIキー確認済み');

      final encodedAddress = Uri.encodeComponent(address);
      final url = '$_baseUrl?address=$encodedAddress&key=$_apiKey';

      debugPrint('Google Geocoding API呼び出し: $address');
      // セキュリティのため、実際のAPIキーはログに出力しない
      debugPrint(
          'API URL (キー部分マスク): $_baseUrl?address=$encodedAddress&key=***');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final location = result['geometry']['location'];

          debugPrint('Geocoding成功: ${location['lat']}, ${location['lng']}');

          return GeocodingResult(
            latitude: location['lat'].toDouble(),
            longitude: location['lng'].toDouble(),
            formattedAddress: result['formatted_address'],
          );
        } else {
          debugPrint('Geocoding結果なし: ${data['status']}');
          if (data['error_message'] != null) {
            debugPrint('エラーメッセージ: ${data['error_message']}');
          }
        }
      } else {
        debugPrint('HTTP エラー: ${response.statusCode}');
        debugPrint('レスポンス: ${response.body}');
      }
    } catch (e) {
      debugPrint('Geocoding API エラー: $e');
    }

    return null;
  }

  /// 座標から住所を取得（逆ジオコーディング）
  static Future<GeocodingResult?> getAddressFromCoordinates(
      double latitude, double longitude) async {
    try {
      final url = '$_baseUrl?latlng=$latitude,$longitude&key=$_apiKey';

      debugPrint('逆Geocoding API呼び出し: $latitude, $longitude');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];

          debugPrint('逆Geocoding成功: ${result['formatted_address']}');

          return GeocodingResult(
            latitude: latitude,
            longitude: longitude,
            formattedAddress: result['formatted_address'],
          );
        } else {
          debugPrint('逆Geocoding結果なし: ${data['status']}');
        }
      } else {
        debugPrint('HTTP エラー: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('逆Geocoding API エラー: $e');
    }

    return null;
  }

  /// APIキーが設定されているかチェック
  static bool isApiKeyConfigured() {
    final apiKey = dotenv.env['googleServiceAPI'] ?? '';
    return apiKey.isNotEmpty && apiKey != 'YOUR_GOOGLE_GEOCODING_API_KEY';
  }
}

/// Geocoding結果クラス
class GeocodingResult {
  final double latitude;
  final double longitude;
  final String formattedAddress;

  GeocodingResult({
    required this.latitude,
    required this.longitude,
    required this.formattedAddress,
  });

  @override
  String toString() {
    return 'GeocodingResult(lat: $latitude, lng: $longitude, address: $formattedAddress)';
  }
}
