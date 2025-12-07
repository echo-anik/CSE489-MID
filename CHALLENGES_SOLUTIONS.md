# Landmark Management App - Challenges and Solutions

## Table of Contents
1. [Technical Challenges](#technical-challenges)
2. [Development Workflow Challenges](#development-workflow-challenges)
3. [Screenshots and Documentation](#screenshots-and-documentation)

---

## Technical Challenges

### Challenge 1: Handling Image Uploads with Multipart/Form-Data in Flutter

#### Problem Description
Uploading images to the REST API requires sending data as `multipart/form-data`, which is different from standard JSON requests. Flutter developers often struggle with:
- Converting `File` objects to multipart format
- Properly structuring the request with both text fields and file data
- Handling large image files that may cause memory issues
- Managing asynchronous file reading operations

#### Solution

**Using the `http` package:**

```dart
import 'package:http/http.dart' as http;
import 'dart:io';

Future<void> uploadLandmark(String title, double lat, double lon, File imageFile) async {
  final uri = Uri.parse('https://labs.anontech.info/cse489/t3/api.php');

  // Create multipart request
  var request = http.MultipartRequest('POST', uri);

  // Add text fields
  request.fields['title'] = title;
  request.fields['lat'] = lat.toString();
  request.fields['lon'] = lon.toString();

  // Add image file using ByteStream to avoid loading entire file into memory
  var imageStream = http.ByteStream(imageFile.openRead());
  var imageLength = await imageFile.length();

  var multipartFile = http.MultipartFile(
    'image',                          // Field name from API
    imageStream,                      // File stream
    imageLength,                      // File size
    filename: imageFile.path.split('/').last,  // Filename
  );

  request.files.add(multipartFile);

  // Send request and handle response
  try {
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Upload successful: ${response.body}');
    } else {
      print('Upload failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error uploading: $e');
  }
}
```

**Using the `dio` package (recommended for complex scenarios):**

```dart
import 'package:dio/dio.dart';
import 'dart:io';

Future<void> uploadLandmarkDio(String title, double lat, double lon, File imageFile) async {
  final dio = Dio();

  FormData formData = FormData.fromMap({
    'title': title,
    'lat': lat.toString(),
    'lon': lon.toString(),
    'image': await MultipartFile.fromFile(
      imageFile.path,
      filename: imageFile.path.split('/').last,
    ),
  });

  try {
    Response response = await dio.post(
      'https://labs.anontech.info/cse489/t3/api.php',
      data: formData,
      onSendProgress: (sent, total) {
        print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
      },
    );

    print('Upload successful: ${response.data}');
  } on DioException catch (e) {
    print('Upload error: ${e.message}');
  }
}
```

**Key Points:**
- Use `ByteStream` with `http` package to avoid memory issues with large files
- Dio provides built-in progress tracking
- Always handle exceptions for network failures
- Convert numeric values to strings for form data

---

### Challenge 2: PUT Requests with x-www-form-urlencoded Format

#### Problem Description
The UPDATE endpoint requires `application/x-www-form-urlencoded` content type, which is different from the default JSON format. Common issues include:
- Incorrect header configuration causing 400 errors
- Body encoding problems
- Confusion between form-data and x-www-form-urlencoded

#### Solution

**Correct implementation:**

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> updateLandmark(int id, String title, double lat, double lon) async {
  final uri = Uri.parse('https://labs.anontech.info/cse489/t3/api.php');

  try {
    final response = await http.put(
      uri,
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',  // Critical header
      },
      body: {
        'id': id.toString(),
        'title': title,
        'lat': lat.toString(),
        'lon': lon.toString(),
      },  // http package automatically encodes this as x-www-form-urlencoded
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Update successful: ${data['message']}');
    } else {
      print('Update failed: ${response.statusCode}');
    }
  } catch (e) {
    print('Error: $e');
  }
}
```

**Using Dio:**

```dart
import 'package:dio/dio.dart';

Future<void> updateLandmarkDio(int id, String title, double lat, double lon) async {
  final dio = Dio();

  try {
    Response response = await dio.put(
      'https://labs.anontech.info/cse489/t3/api.php',
      data: {
        'id': id.toString(),
        'title': title,
        'lat': lat.toString(),
        'lon': lon.toString(),
      },
      options: Options(
        contentType: Headers.formUrlEncodedContentType,  // Dio constant
      ),
    );

    print('Update successful: ${response.data}');
  } on DioException catch (e) {
    print('Error: ${e.message}');
  }
}
```

**Key Differences:**

| Format | Content-Type | Use Case | Data Structure |
|--------|-------------|----------|----------------|
| multipart/form-data | multipart/form-data | File uploads | Boundary-separated parts |
| x-www-form-urlencoded | application/x-www-form-urlencoded | Form submissions | URL-encoded key=value pairs |
| JSON | application/json | API data exchange | JSON object |

---

### Challenge 3: Map Integration - Google Maps API Key Setup OR OpenStreetMap

#### Problem Description
Integrating maps requires proper API configuration and platform-specific setup. Challenges include:
- API key generation and configuration
- Platform-specific setup (Android/iOS)
- Choosing between Google Maps (paid) and OpenStreetMap (free)
- Handling permissions

#### Solution Option 1: Google Maps

**Step 1: Get API Key**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable "Maps SDK for Android" and "Maps SDK for iOS"
4. Create credentials (API Key)
5. Restrict the API key to your app's package name

**Step 2: Android Configuration**

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- Add API key -->
        <meta-data
            android:name="com.google.android.geo.API_KEY"
            android:value="YOUR_API_KEY_HERE"/>
    </application>

    <!-- Add permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```

**Step 3: iOS Configuration**

Edit `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("YOUR_API_KEY_HERE")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

**Step 4: Add Dependencies**

```yaml
dependencies:
  google_maps_flutter: ^2.5.0
  geolocator: ^11.0.0
```

**Step 5: Implementation**

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(23.8103, 90.4125),  // Dhaka, Bangladesh
        zoom: 12,
      ),
      markers: markers,
      onMapCreated: (controller) {
        mapController = controller;
      },
      onTap: (LatLng position) {
        // Handle map tap
        addMarker(position);
      },
    );
  }

  void addMarker(LatLng position) {
    setState(() {
      markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
      ));
    });
  }
}
```

#### Solution Option 2: OpenStreetMap (Free Alternative)

**Step 1: Add Dependency**

```yaml
dependencies:
  flutter_map: ^6.1.0
  latlong2: ^0.9.0
```

**Step 2: Implementation**

```dart
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class OpenStreetMapScreen extends StatefulWidget {
  @override
  _OpenStreetMapScreenState createState() => _OpenStreetMapScreenState();
}

class _OpenStreetMapScreenState extends State<OpenStreetMapScreen> {
  List<Marker> markers = [];

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        center: LatLng(23.8103, 90.4125),
        zoom: 12.0,
        onTap: (tapPosition, point) {
          addMarker(point);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        MarkerLayer(
          markers: markers,
        ),
      ],
    );
  }

  void addMarker(LatLng point) {
    setState(() {
      markers.add(
        Marker(
          point: point,
          width: 40,
          height: 40,
          builder: (ctx) => Icon(
            Icons.location_on,
            color: Colors.red,
            size: 40,
          ),
        ),
      );
    });
  }
}
```

**Comparison:**

| Feature | Google Maps | OpenStreetMap |
|---------|-------------|---------------|
| Cost | Requires billing account | Free |
| API Key | Required | Not required |
| Features | Advanced (traffic, 3D) | Basic |
| Performance | Optimized | Good |
| Customization | Limited | Highly customizable |

---

### Challenge 4: Custom Map Markers and Styling

#### Problem Description
Default markers are generic and don't provide good UX. Custom markers help users identify landmarks visually.

#### Solution

**Custom Marker with Google Maps:**

```dart
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/services.dart';

class CustomMarkerHelper {
  // Create marker from asset image
  static Future<BitmapDescriptor> createCustomMarker(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: 100,  // Resize for performance
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // Create marker from network image
  static Future<BitmapDescriptor> createMarkerFromUrl(String imageUrl) async {
    final http.Response response = await http.get(Uri.parse(imageUrl));
    final Uint8List bytes = response.bodyBytes;

    final ui.Codec codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 100,
    );
    final ui.FrameInfo frameInfo = await codec.getNextFrame();
    final ByteData? byteData = await frameInfo.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
}

// Usage
class MapWithCustomMarkers extends StatefulWidget {
  final List<Landmark> landmarks;

  @override
  _MapWithCustomMarkersState createState() => _MapWithCustomMarkersState();
}

class _MapWithCustomMarkersState extends State<MapWithCustomMarkers> {
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    loadMarkers();
  }

  Future<void> loadMarkers() async {
    final customIcon = await CustomMarkerHelper.createCustomMarker(
      'assets/marker_icon.png',
    );

    for (var landmark in widget.landmarks) {
      markers.add(
        Marker(
          markerId: MarkerId(landmark.id.toString()),
          position: LatLng(landmark.lat, landmark.lon),
          icon: customIcon,
          infoWindow: InfoWindow(
            title: landmark.title,
            snippet: 'Tap for details',
          ),
          onTap: () {
            // Show landmark details
            showLandmarkDetails(landmark);
          },
        ),
      );
    }

    setState(() {});
  }

  void showLandmarkDetails(Landmark landmark) {
    showModalBottomSheet(
      context: context,
      builder: (context) => LandmarkDetailsSheet(landmark: landmark),
    );
  }
}
```

**Custom Marker with OpenStreetMap:**

```dart
import 'package:flutter_map/flutter_map.dart';
import 'package:cached_network_image/cached_network_image.dart';

List<Marker> createCustomOSMMarkers(List<Landmark> landmarks) {
  return landmarks.map((landmark) {
    return Marker(
      point: LatLng(landmark.lat, landmark.lon),
      width: 80,
      height: 80,
      builder: (ctx) => GestureDetector(
        onTap: () {
          // Handle marker tap
        },
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: landmark.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.location_on),
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.red, size: 20),
          ],
        ),
      ),
    );
  }).toList();
}
```

---

### Challenge 5: Image Resizing to 800x600 Before Upload

#### Problem Description
Uploading high-resolution images wastes bandwidth and increases upload time. Images should be resized client-side before upload.

#### Solution

**Using the `image` package:**

```dart
import 'package:image/image.dart' as img;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class ImageProcessor {
  static Future<File> resizeImage(File imageFile) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();

      // Decode image
      img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception('Unable to decode image');
      }

      // Resize to 800x600 maintaining aspect ratio
      img.Image resized = img.copyResize(
        image,
        width: 800,
        height: 600,
        interpolation: img.Interpolation.linear,
      );

      // Encode as JPEG with quality compression
      List<int> encoded = img.encodeJpg(resized, quality: 85);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempPath = '${tempDir.path}/resized_$timestamp.jpg';
      final tempFile = File(tempPath);

      await tempFile.writeAsBytes(encoded);

      print('Original size: ${imageFile.lengthSync()} bytes');
      print('Resized size: ${tempFile.lengthSync()} bytes');

      return tempFile;
    } catch (e) {
      print('Error resizing image: $e');
      rethrow;
    }
  }

  // Alternative: Resize maintaining aspect ratio
  static Future<File> resizeImageMaintainAspect(File imageFile, int maxWidth) async {
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);

    if (image == null) throw Exception('Unable to decode image');

    // Calculate new height maintaining aspect ratio
    int newHeight = (image.height * maxWidth / image.width).round();

    img.Image resized = img.copyResize(
      image,
      width: maxWidth,
      height: newHeight,
    );

    List<int> encoded = img.encodeJpg(resized, quality: 85);

    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/resized_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(encoded);

    return tempFile;
  }
}

// Usage in UI
Future<void> pickAndResizeImage() async {
  final ImagePicker picker = ImagePicker();
  final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile != null) {
    File imageFile = File(pickedFile.path);

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    try {
      // Resize image
      File resizedImage = await ImageProcessor.resizeImage(imageFile);

      Navigator.pop(context);  // Close loading dialog

      // Now upload the resized image
      await uploadLandmark(title, lat, lon, resizedImage);

      // Clean up temp file
      await resizedImage.delete();
    } catch (e) {
      Navigator.pop(context);
      showErrorDialog('Error processing image: $e');
    }
  }
}
```

**Key Points:**
- Always resize images client-side to save bandwidth
- Use JPEG compression with quality 85 for good balance
- Clean up temporary files after upload
- Show loading indicator during processing
- Maintain aspect ratio to avoid distortion

---

### Challenge 6: GPS Location Detection

#### Problem Description
Getting accurate GPS coordinates requires proper permissions and handling various edge cases like disabled location services, permission denial, and location accuracy.

#### Solution

**Step 1: Add Dependencies**

```yaml
dependencies:
  geolocator: ^11.0.0
  permission_handler: ^11.1.0
```

**Step 2: Configure Permissions**

**Android** (`android/app/src/main/AndroidManifest.xml`):

```xml
<manifest>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
</manifest>
```

**iOS** (`ios/Runner/Info.plist`):

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to your location to mark landmarks on the map.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to your location to mark landmarks on the map.</string>
```

**Step 3: Location Service Implementation**

```dart
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  static Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current position with error handling
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable them in settings.');
      }

      // Check permissions
      LocationPermission permission = await checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permissions are permanently denied. Please enable them in app settings.',
        );
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get location with custom accuracy
  static Future<Position?> getLocationWithAccuracy(LocationAccuracy accuracy) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: Duration(seconds: 15),
      );
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  // Stream location updates
  static Stream<Position> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,  // Update every 10 meters
      ),
    );
  }
}

// Usage in UI
class AddLandmarkScreen extends StatefulWidget {
  @override
  _AddLandmarkScreenState createState() => _AddLandmarkScreenState();
}

class _AddLandmarkScreenState extends State<AddLandmarkScreen> {
  double? latitude;
  double? longitude;
  bool isLoadingLocation = false;

  Future<void> getCurrentLocation() async {
    setState(() {
      isLoadingLocation = true;
    });

    try {
      Position? position = await LocationService.getCurrentLocation();

      if (position != null) {
        setState(() {
          latitude = position.latitude;
          longitude = position.longitude;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location detected successfully')),
        );
      } else {
        throw Exception('Unable to get location');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () {
              Geolocator.openLocationSettings();
            },
          ),
        ),
      );
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (latitude != null && longitude != null)
          Text('Location: $latitude, $longitude'),

        ElevatedButton.icon(
          onPressed: isLoadingLocation ? null : getCurrentLocation,
          icon: isLoadingLocation
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(Icons.my_location),
          label: Text(isLoadingLocation ? 'Getting location...' : 'Use Current Location'),
        ),
      ],
    );
  }
}
```

---

### Challenge 7: Offline Caching and Sync

#### Problem Description
Users need to work offline and have changes sync when connectivity returns. This requires local database storage and a sync queue system.

#### Solution

**Step 1: Add Dependencies**

```yaml
dependencies:
  sqflite: ^2.3.0
  path: ^1.8.3
  connectivity_plus: ^5.0.2
```

**Step 2: Database Helper**

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<Database> initDatabase() async {
    String path = join(await getDatabasesPath(), 'landmarks.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Landmarks table
        await db.execute('''
          CREATE TABLE landmarks(
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            lat REAL NOT NULL,
            lon REAL NOT NULL,
            image_url TEXT,
            local_image_path TEXT,
            created_at TEXT,
            updated_at TEXT,
            is_synced INTEGER DEFAULT 1
          )
        ''');

        // Sync queue table
        await db.execute('''
          CREATE TABLE sync_queue(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            operation TEXT NOT NULL,
            landmark_data TEXT NOT NULL,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // Cache landmarks from API
  Future<void> cacheLandmarks(List<Landmark> landmarks) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('landmarks');
      for (var landmark in landmarks) {
        await txn.insert('landmarks', {
          'id': landmark.id,
          'title': landmark.title,
          'lat': landmark.lat,
          'lon': landmark.lon,
          'image_url': landmark.imageUrl,
          'created_at': landmark.createdAt?.toIso8601String(),
          'updated_at': landmark.updatedAt?.toIso8601String(),
          'is_synced': 1,
        });
      }
    });
  }

  // Get cached landmarks
  Future<List<Landmark>> getCachedLandmarks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('landmarks');

    return maps.map((map) => Landmark.fromJson(map)).toList();
  }

  // Add to sync queue
  Future<void> addToSyncQueue(String operation, Map<String, dynamic> data) async {
    final db = await database;

    await db.insert('sync_queue', {
      'operation': operation,
      'landmark_data': json.encode(data),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Get sync queue
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    final db = await database;
    return await db.query('sync_queue', orderBy: 'id ASC');
  }

  // Clear sync queue item
  Future<void> clearSyncQueueItem(int id) async {
    final db = await database;
    await db.delete('sync_queue', where: 'id = ?', whereArgs: [id]);
  }
}
```

**Step 3: Sync Manager**

```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class SyncManager {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final LandmarkService _apiService = LandmarkService();

  // Check connectivity and sync
  Future<void> syncIfOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult != ConnectivityResult.none) {
      await performSync();
    }
  }

  // Perform sync
  Future<void> performSync() async {
    try {
      // Get sync queue
      List<Map<String, dynamic>> queue = await _dbHelper.getSyncQueue();

      for (var item in queue) {
        String operation = item['operation'];
        Map<String, dynamic> data = json.decode(item['landmark_data']);

        try {
          switch (operation) {
            case 'CREATE':
              await _apiService.createLandmark(
                title: data['title'],
                lat: data['lat'],
                lon: data['lon'],
                imageFile: File(data['local_image_path']),
              );
              break;
            case 'UPDATE':
              await _apiService.updateLandmark(
                id: data['id'],
                title: data['title'],
                lat: data['lat'],
                lon: data['lon'],
              );
              break;
            case 'DELETE':
              await _apiService.deleteLandmark(data['id']);
              break;
          }

          // Remove from queue on success
          await _dbHelper.clearSyncQueueItem(item['id']);
        } catch (e) {
          print('Error syncing item ${item['id']}: $e');
          // Keep in queue for next sync attempt
        }
      }

      // Refresh local cache with server data
      final landmarks = await _apiService.getAllLandmarks();
      await _dbHelper.cacheLandmarks(landmarks);
    } catch (e) {
      print('Sync error: $e');
    }
  }

  // Listen for connectivity changes
  void startSyncListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        syncIfOnline();
      }
    });
  }
}

// Usage
class LandmarkProviderWithOffline extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SyncManager _syncManager = SyncManager();

  List<Landmark> _landmarks = [];

  Future<void> loadLandmarks() async {
    try {
      // Try to load from API
      _landmarks = await LandmarkService().getAllLandmarks();
      await _dbHelper.cacheLandmarks(_landmarks);
    } catch (e) {
      // Load from cache on error
      _landmarks = await _dbHelper.getCachedLandmarks();
    }
    notifyListeners();
  }

  Future<void> addLandmark(String title, double lat, double lon, File image) async {
    try {
      // Try to create online
      final landmark = await LandmarkService().createLandmark(
        title: title,
        lat: lat,
        lon: lon,
        imageFile: image,
      );
      _landmarks.add(landmark);
    } catch (e) {
      // Add to sync queue if offline
      await _dbHelper.addToSyncQueue('CREATE', {
        'title': title,
        'lat': lat,
        'lon': lon,
        'local_image_path': image.path,
      });
    }
    notifyListeners();
  }
}
```

---

### Challenge 8: Swipe Gestures in List View

#### Problem Description
Users expect intuitive swipe-to-delete functionality in list views, similar to popular mobile apps.

#### Solution

**Using Dismissible Widget:**

```dart
class LandmarkListView extends StatelessWidget {
  final List<Landmark> landmarks;
  final Function(Landmark) onDelete;
  final Function(Landmark) onEdit;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: landmarks.length,
      itemBuilder: (context, index) {
        final landmark = landmarks[index];

        return Dismissible(
          key: Key(landmark.id.toString()),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20),
            child: Icon(Icons.delete, color: Colors.white, size: 30),
          ),
          secondaryBackground: Container(
            color: Colors.blue,
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.edit, color: Colors.white, size: 30),
          ),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              // Swipe right - Delete
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Landmark'),
                  content: Text('Are you sure you want to delete ${landmark.title}?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            } else {
              // Swipe left - Edit
              onEdit(landmark);
              return false;
            }
          },
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              onDelete(landmark);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${landmark.title} deleted')),
              );
            }
          },
          child: LandmarkListItem(landmark: landmark),
        );
      },
    );
  }
}
```

---

## Development Workflow Challenges

### Challenge 1: Testing REST API Endpoints

#### Problem Description
Manual testing is time-consuming and error-prone. Automated testing ensures API reliability.

#### Solution

**Unit Testing API Service:**

```dart
// test/services/landmark_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

void main() {
  group('LandmarkService Tests', () {
    late LandmarkService service;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      service = LandmarkService(client: mockClient);
    });

    test('getAllLandmarks returns list on success', () async {
      // Arrange
      when(mockClient.get(any)).thenAnswer(
        (_) async => http.Response(
          json.encode({
            'success': true,
            'data': [
              {'id': 1, 'title': 'Test', 'lat': 23.8, 'lon': 90.4, 'image_url': 'url'}
            ]
          }),
          200,
        ),
      );

      // Act
      final landmarks = await service.getAllLandmarks();

      // Assert
      expect(landmarks.length, 1);
      expect(landmarks[0].title, 'Test');
    });

    test('createLandmark throws exception on error', () async {
      // Arrange
      when(mockClient.post(any, body: anyNamed('body'))).thenAnswer(
        (_) async => http.Response('Error', 400),
      );

      // Act & Assert
      expect(
        () => service.createLandmark(
          title: 'Test',
          lat: 23.8,
          lon: 90.4,
          imageFile: File('test.jpg'),
        ),
        throwsException,
      );
    });
  });
}
```

**Integration Testing:**

```dart
// integration_test/api_integration_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('API Integration Tests', () {
    testWidgets('Full CRUD flow', (WidgetTester tester) async {
      final service = LandmarkService();

      // Create
      final created = await service.createLandmark(
        title: 'Integration Test',
        lat: 23.8,
        lon: 90.4,
        imageFile: File('test_assets/test.jpg'),
      );
      expect(created.title, 'Integration Test');

      // Read
      final landmarks = await service.getAllLandmarks();
      expect(landmarks.any((l) => l.id == created.id), true);

      // Update
      final updated = await service.updateLandmark(
        id: created.id,
        title: 'Updated',
        lat: 23.8,
        lon: 90.4,
      );
      expect(updated.title, 'Updated');

      // Delete
      await service.deleteLandmark(created.id);
      final afterDelete = await service.getAllLandmarks();
      expect(afterDelete.any((l) => l.id == created.id), false);
    });
  });
}
```

---

### Challenge 2: Debugging Network Requests

#### Solution

**Using Dio Interceptors:**

```dart
import 'package:dio/dio.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('REQUEST[${options.method}] => PATH: ${options.path}');
    print('Headers: ${options.headers}');
    print('Body: ${options.data}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    print('Data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    print('Message: ${err.message}');
    super.onError(err, handler);
  }
}

// Setup
final dio = Dio()..interceptors.add(LoggingInterceptor());
```

---

### Challenge 3: Managing App State

#### Solution Comparison

**1. Provider (Recommended for beginners):**

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LandmarkProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

**2. Riverpod (Modern alternative):**

```dart
final landmarkProvider = StateNotifierProvider<LandmarkNotifier, List<Landmark>>((ref) {
  return LandmarkNotifier();
});
```

**3. Bloc (For large apps):**

```dart
class LandmarkBloc extends Bloc<LandmarkEvent, LandmarkState> {
  LandmarkBloc() : super(LandmarkInitial()) {
    on<LoadLandmarks>(_onLoadLandmarks);
    on<AddLandmark>(_onAddLandmark);
  }
}
```

---

### Challenge 4: Handling Async Operations

#### Solution

**Using FutureBuilder:**

```dart
FutureBuilder<List<Landmark>>(
  future: landmarkService.getAllLandmarks(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return ErrorWidget(error: snapshot.error.toString());
    }

    if (!snapshot.hasData || snapshot.data!.isEmpty) {
      return EmptyStateWidget();
    }

    return LandmarkListView(landmarks: snapshot.data!);
  },
)
```

---

## Screenshots and Documentation

### Required Screenshots

Include the following screenshots in your submission:

1. **Home Screen** - List of all landmarks
2. **Map View** - Landmarks displayed on map with custom markers
3. **Add Landmark Screen** - Form with GPS location button
4. **Landmark Detail** - Individual landmark details
5. **Image Picker** - Gallery/camera selection
6. **Swipe Gesture** - Demonstrating delete/edit swipe
7. **GPS Location** - Permission dialog and location detection
8. **Offline Mode** - App working without internet
9. **Error Handling** - Network error message
10. **Loading States** - Progress indicators

### Screenshot Guidelines

**Device & Settings:**
- Use Android emulator or iOS simulator
- Resolution: 1080x1920 (vertical) or 1920x1080 (horizontal) for map views
- Enable demo mode (hide status bar clutter)

**Capture Methods:**
1. Android Studio: Device screenshot button
2. iOS: Cmd + S in simulator
3. Physical device: Hardware buttons

**Editing:**
- Use tools like Figma or Sketch for annotations
- Add arrows or highlights to important features
- Include captions for clarity

**Organization:**
```
screenshots/
  - 01_home_screen.png
  - 02_map_view.png
  - 03_add_landmark.png
  - 04_landmark_detail.png
  - 05_image_picker.png
  - 06_swipe_gesture.png
  - 07_gps_location.png
  - 08_offline_mode.png
  - 09_error_handling.png
  - 10_loading_states.png
```

---

**Document Version:** 1.0
**Last Updated:** 2024-01-15
