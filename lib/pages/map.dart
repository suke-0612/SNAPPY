import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:snappy/importer.dart' hide LatLng;
import '../services/screenshot_actions_service.dart';
import '../services/google_geocoding_service.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  List<Screenshot> _locationScreenshots = [];
  bool _loading = true;
  String _errorMessage = '';
  double _currentZoom = 10.0;

  // 現在地取得
  Future<LatLng?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // サービス有効化確認
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    // 権限確認
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _setInitialPosition();
    if (mounted) {
      await _loadLocationData();
    }
  }

  CameraPosition? _initialPosition;

  Future<void> _setInitialPosition() async {
    final currentLocation = await _getCurrentLocation();
    if (currentLocation != null) {
      setState(() {
        _initialPosition = CameraPosition(
          target: currentLocation,
          zoom: 15,
        );
      });
    } else {
      // 現在地取得できない場合は東京をデフォルトに
      setState(() {
        _initialPosition = const CameraPosition(
          target: LatLng(35.6762, 139.6503),
          zoom: 10,
        );
      });
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  /// locationタグのデータを読み込む
  Future<void> _loadLocationData() async {
    if (!mounted) return;

    try {
      setState(() {
        _loading = true;
        _errorMessage = '';
      });

      final isar = await openIsarInstance();

      // locationタグのスクリーンショットを取得
      final screenshots =
          await isar.screenshots.filter().tagEqualTo('場所').findAll();

      if (!mounted) return;

      // location フィールドが null でないものだけフィルタ
      final validScreenshots = screenshots
          .where((s) => s.location != null && s.location!.isNotEmpty)
          .toList();

      _locationScreenshots = validScreenshots;
      await _createMarkers();
    } catch (e) {
      debugPrint('位置データ読み込みエラー: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '位置データの読み込みに失敗しました: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  /// マーカーを作成
  Future<void> _createMarkers() async {
    if (!mounted) return;

    Set<Marker> markers = {};
    final isar = await openIsarInstance();

    for (int i = 0; i < _locationScreenshots.length; i++) {
      final screenshot = _locationScreenshots[i];

      if (screenshot.location == null || screenshot.location!.isEmpty) {
        continue;
      }

      LatLng? coordinates;

      // 1. まずIsarから緯度・経度を取得
      if (screenshot.latitude != null && screenshot.longitude != null) {
        coordinates = LatLng(screenshot.latitude!, screenshot.longitude!);
      } else {
        // 2. 緯度・経度がない場合はジオコーディングを実行
        debugPrint('緯度・経度がないため、ジオコーディング実行: ${screenshot.location}');
        coordinates = await _geocodeAndSave(screenshot, isar);
      }

      if (coordinates != null) {
        try {
          final marker = Marker(
            markerId: MarkerId('marker_$i'),
            position: coordinates,
            infoWindow: InfoWindow(
              title: screenshot.title ?? 'タイトルなし',
              snippet: 'タップして詳細を表示',
              onTap: () {
                // InfoWindowがタップされたときに詳細表示
                if (mounted) {
                  _showScreenshotDetails(screenshot);
                }
              },
            ),
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          );
          markers.add(marker);
        } catch (e) {
          debugPrint('マーカー作成エラー: $e');
        }
      } else {
        debugPrint('座標取得失敗: ${screenshot.location}');
      }
    }

    debugPrint('作成されたマーカー数: ${markers.length}');

    if (!mounted) return;

    setState(() {
      _markers = markers;
    });
  }

  /// ジオコーディングを実行してIsarに保存
  Future<LatLng?> _geocodeAndSave(Screenshot screenshot, Isar isar) async {
    try {
      // Google Geocoding API キーのチェック
      if (!GoogleGeocodingService.isApiKeyConfigured()) {
        debugPrint('Google Geocoding API キーが設定されていません');
        return null;
      }

      // 住所から座標を取得
      final coordinates = await _geocodeAddress(screenshot.location!);

      if (coordinates != null) {
        // Isarに緯度・経度を保存
        await isar.writeTxn(() async {
          screenshot.latitude = coordinates.latitude;
          screenshot.longitude = coordinates.longitude;
          await isar.screenshots.put(screenshot);
        });

        return coordinates;
      }
    } catch (e) {
      debugPrint('ジオコーディング・保存エラー: $e');
    }
    return null;
  }

  /// 住所から座標を取得
  Future<LatLng?> _geocodeAddress(String address) async {
    try {
      // 日本の住所の場合、「日本」を追加してより正確にする
      String searchAddress = address;
      if (!address.toLowerCase().contains('japan') && !address.contains('日本')) {
        searchAddress = '$address, 日本';
      }

      final result =
          await GoogleGeocodingService.getCoordinatesFromAddress(searchAddress);

      if (result != null) {
        return LatLng(result.latitude, result.longitude);
      } else {
        debugPrint('Geocoding結果なし: $searchAddress');

        // フォールバック: より簡単な検索を試す
        if (searchAddress != address) {
          debugPrint('フォールバック: 元の住所で再試行 - $address');
          final fallbackResult =
              await GoogleGeocodingService.getCoordinatesFromAddress(address);
          if (fallbackResult != null) {
            debugPrint(
                'フォールバックGeocoding成功: ${fallbackResult.latitude}, ${fallbackResult.longitude}');
            return LatLng(fallbackResult.latitude, fallbackResult.longitude);
          }
        }
      }
    } catch (e) {
      debugPrint('Google Geocoding API エラー: $e, address: $address');
    }
    return null;
  }

  /// スクリーンショット詳細を表示
  void _showScreenshotDetails(Screenshot screenshot) async {
    if (!mounted) return;

    // AssetEntityを取得
    final AssetEntity? asset = await AssetEntity.fromId(screenshot.assetId);
    if (asset == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('画像を取得できませんでした')),
      );
      return;
    }

    // 共通サービスを使用してPopupContainerを表示
    ScreenshotActionsService.showScreenshotPopup(
      context: context,
      screenshot: screenshot,
      assetEntity: asset,
      onRefresh: _refreshMapData,
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('削除に失敗しました: $error'),
            backgroundColor: Colors.red,
          ),
        );
      },
    );
  }

  /// マップデータを再読み込み
  Future<void> _refreshMapData() async {
    await _loadLocationData();
  }

  /// ズームイン
  Future<void> _zoomIn() async {
    if (_mapController != null) {
      final newZoom = _currentZoom + 1;
      if (newZoom <= 20) {
        await _mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
        setState(() {
          _currentZoom = newZoom;
        });
      } else {
        debugPrint('ズームイン制限: 最大ズーム値に達しています');
      }
    } else {
      debugPrint('ズームイン失敗: マップコントローラーがnull');
    }
  }

  /// ズームアウト
  Future<void> _zoomOut() async {
    if (_mapController != null) {
      final newZoom = _currentZoom - 1;
      if (newZoom >= 1) {
        await _mapController!.animateCamera(CameraUpdate.zoomTo(newZoom));
        setState(() {
          _currentZoom = newZoom;
        });
      } else {
        debugPrint('ズームアウト制限: 最小ズーム値に達しています');
      }
    } else {
      debugPrint('ズームアウト失敗: マップコントローラーがnull');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreen(
      child: Column(
        children: [
          // ヘッダー
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                const Icon(Icons.map, color: Colors.black),
                const SizedBox(width: 8),
                Text(
                  'マップ (${_locationScreenshots.length}件)',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // エラーメッセージ
          if (_errorMessage.isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                  ),
                ],
              ),
            ),

          // マップまたはコンテンツ
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? _buildErrorState()
                    : _locationScreenshots.isEmpty
                        ? _buildEmptyState()
                        : _buildMap(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (GoogleMapController controller) {
            if (mounted) {
              _mapController = controller;
              if (_initialPosition != null) {
                setState(() {
                  _currentZoom = _initialPosition!.zoom;
                });
              }
            }
          },
          onCameraMove: (CameraPosition position) {
            if (mounted) {
              setState(() {
                _currentZoom = position.zoom;
              });
            }
          },
          initialCameraPosition: _initialPosition ??
              const CameraPosition(
                target: LatLng(35.6762, 139.6503),
                zoom: 10,
              ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          mapType: MapType.normal,
          zoomControlsEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
          minMaxZoomPreference: const MinMaxZoomPreference(1.0, 20.0),
        ),

        // カスタムズームコントロール
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: FloatingActionButton(
                  mini: true,
                  heroTag: "zoom_in",
                  onPressed: _currentZoom < 20
                      ? () {
                          _zoomIn();
                        }
                      : null,
                  backgroundColor: Colors.white,
                  foregroundColor:
                      _currentZoom < 20 ? Colors.black : Colors.grey,
                  child: const Icon(Icons.add),
                ),
              ),
              FloatingActionButton(
                mini: true,
                heroTag: "zoom_out",
                onPressed: _currentZoom > 1
                    ? () {
                        _zoomOut();
                      }
                    : null,
                backgroundColor: Colors.white,
                foregroundColor: _currentZoom > 1 ? Colors.black : Colors.grey,
                child: const Icon(Icons.remove),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// エラー状態を表示
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'マップの読み込みに失敗しました',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _errorMessage = '';
              });
              _loadLocationData();
            },
            child: const Text('再試行'),
          ),
        ],
      ),
    );
  }

  /// 空の状態を表示
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '場所タグの位置情報がありません',
            style: TextStyle(color: Colors.grey, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            'ホーム画面でスクリーンショットに\n"場所"タグと住所を付けてください',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
