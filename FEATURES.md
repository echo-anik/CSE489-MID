# Feature Documentation

This document provides detailed descriptions of all features implemented in the Bangladesh Landmark Management App.

## Table of Contents

1. [Bottom Navigation System](#bottom-navigation-system)
2. [Map View (Overview Tab)](#map-view-overview-tab)
3. [List View (Records Tab)](#list-view-records-tab)
4. [Add/Edit Landmark Form](#addedit-landmark-form)
5. [Image Handling](#image-handling)
6. [Error Handling & User Feedback](#error-handling--user-feedback)
7. [Offline Caching (Bonus)](#offline-caching-bonus)
8. [User Authentication (Bonus)](#user-authentication-bonus)
9. [Custom Map Themes](#custom-map-themes)

---

## Bottom Navigation System

### Overview
The app uses a persistent bottom navigation bar to switch between three main sections, providing quick access to all core functionalities.

### Implementation Details

#### Navigation Tabs
| Tab Index | Icon | Label | Screen | Purpose |
|-----------|------|-------|--------|---------|
| 0 | Map | Overview | MapScreen | Interactive map view of all landmarks |
| 1 | List | Records | ListScreen | Scrollable list of landmarks |
| 2 | Add | New Entry | AddEditScreen | Form to create new landmarks |

#### Features
- **State Persistence**: Selected tab is maintained across app lifecycle
- **Visual Feedback**: Active tab highlighted with accent color
- **Smooth Transitions**: Animated transitions between tabs
- **Icon Design**: Material Design icons for consistency
- **Badge Support**: Optional notification badges on tabs

#### Code Structure
```dart
BottomNavigationBar(
  currentIndex: _selectedIndex,
  onTap: _onTabTapped,
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Overview'),
    BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Records'),
    BottomNavigationBarItem(icon: Icon(Icons.add_location), label: 'New Entry'),
  ],
)
```

#### User Experience
- Tap on any tab to instantly switch views
- Visual indicator shows current active tab
- Consistent navigation accessible from all screens
- Fast switching without data loss

---

## Map View (Overview Tab)

### Overview
An interactive map displaying all landmarks with custom markers, allowing users to explore locations visually and access detailed information through bottom sheets.

### Core Features

#### 1. Map Integration
- **Provider Options**:
  - Google Maps (primary)
  - OpenStreetMap (alternative/fallback)
- **Map Types**: Normal, Satellite, Terrain, Hybrid
- **Controls**: Zoom in/out, pan, rotate, tilt
- **Gestures**: Touch gestures for navigation

#### 2. Custom Markers

**Visual Design**:
- Unique marker icons for landmarks
- Color-coded markers (optional categorization)
- Marker clustering for dense areas
- Animated marker drops on load

**Marker Information**:
- Display landmark title on marker tap
- Show thumbnail image
- Coordinates display
- Distance from current location

**Interaction**:
```dart
markers.add(Marker(
  markerId: MarkerId(landmark.id),
  position: LatLng(landmark.lat, landmark.lon),
  infoWindow: InfoWindow(title: landmark.title),
  onTap: () => _showLandmarkDetails(landmark),
));
```

#### 3. Bottom Sheet Details

**Triggered By**:
- Tapping on map marker
- Selecting from search results
- Deep linking from notifications

**Sheet Content**:
- Full-size landmark image
- Complete title and description
- Precise coordinates (lat/lon)
- Action buttons:
  - Edit landmark
  - Delete landmark
  - Get directions
  - Share location

**Sheet Behavior**:
- Draggable (expand/collapse)
- Dismissible by swipe down
- Modal and persistent modes
- Smooth animations

**Implementation**:
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => LandmarkBottomSheet(landmark: landmark),
  isScrollControlled: true,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
  ),
);
```

#### 4. Location Features

**Current Location**:
- Blue dot indicator for user position
- Auto-center on app launch
- Follow mode (camera follows user)
- Location accuracy indicator

**Camera Controls**:
- Zoom to fit all markers
- Center on specific landmark
- Smooth animated transitions
- Bearing and tilt adjustments

#### 5. Map Customization

**Styling**:
- Custom map themes (light/dark)
- Minimalist design for clarity
- Highlight important landmarks
- Hide unnecessary labels

**Performance**:
- Lazy loading of markers
- Viewport-based marker rendering
- Efficient memory management
- Smooth 60fps rendering

---

## List View (Records Tab)

### Overview
A scrollable, searchable list displaying all landmarks with quick access to edit and delete functions through intuitive swipe gestures.

### Core Features

#### 1. List Display

**Layout**:
- Card-based design for each landmark
- Thumbnail image (left side)
- Title and coordinates (center)
- Action icons (right side)
- Dividers between items

**Item Information**:
```dart
ListTile(
  leading: CircleAvatar(backgroundImage: landmark.imageProvider),
  title: Text(landmark.title),
  subtitle: Text('${landmark.lat}, ${landmark.lon}'),
  trailing: Icon(Icons.chevron_right),
  onTap: () => _navigateToDetails(landmark),
)
```

#### 2. Swipe Actions

**Swipe-to-Delete**:
- Swipe left to reveal delete button
- Red background with trash icon
- Confirmation dialog before deletion
- Undo option with snackbar

**Swipe-to-Edit** (optional):
- Swipe right to reveal edit button
- Blue background with edit icon
- Direct navigation to edit form

**Implementation**:
```dart
Dismissible(
  key: Key(landmark.id),
  direction: DismissDirection.endToStart,
  background: Container(color: Colors.red, child: Icon(Icons.delete)),
  confirmDismiss: (direction) => _confirmDelete(context),
  onDismissed: (direction) => _deleteLandmark(landmark.id),
  child: LandmarkCard(landmark: landmark),
)
```

#### 3. Search and Filter

**Search Bar**:
- Fixed at top of list
- Real-time search as you type
- Search by landmark title
- Clear button to reset search

**Filter Options**:
- Sort by name (A-Z, Z-A)
- Sort by distance from user
- Sort by date added
- Filter by region/category

#### 4. Pull-to-Refresh

**Functionality**:
- Pull down gesture to refresh data
- Fetches latest landmarks from API
- Visual loading indicator
- Success/error feedback

**Implementation**:
```dart
RefreshIndicator(
  onRefresh: _refreshLandmarks,
  child: ListView.builder(
    itemCount: landmarks.length,
    itemBuilder: (context, index) => LandmarkCard(landmark: landmarks[index]),
  ),
)
```

#### 5. Empty State

**When No Landmarks**:
- Friendly illustration
- Helpful message
- Quick action button to add first landmark
- Tips for getting started

#### 6. Performance Optimization

**Efficient Rendering**:
- ListView.builder for lazy loading
- Only renders visible items
- Efficient memory usage
- Smooth scrolling performance

**Image Optimization**:
- Cached network images
- Thumbnail generation
- Lazy image loading
- Memory-efficient rendering

---

## Add/Edit Landmark Form

### Overview
A comprehensive form for creating new landmarks or editing existing ones, featuring GPS auto-detection, image selection, and input validation.

### Core Features

#### 1. Form Fields

**Title Input**:
- Text field with character limit (e.g., 100 chars)
- Required field validation
- Auto-capitalization
- Input decoration with label and hint

**Location Input**:
- Latitude field (decimal degrees)
- Longitude field (decimal degrees)
- Numeric keyboard for coordinates
- Range validation (-90 to 90 for lat, -180 to 180 for lon)
- Formatted display (e.g., 6 decimal places)

**Image Selection**:
- Preview of selected/current image
- Placeholder when no image selected
- Image picker button
- Replace image option

#### 2. GPS Auto-Detection

**Features**:
- One-tap location detection
- Uses device GPS/location services
- Loading indicator during detection
- Automatic field population
- Accuracy indicator

**Implementation**:
```dart
IconButton(
  icon: Icon(Icons.my_location),
  onPressed: () async {
    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _latController.text = position.latitude.toStringAsFixed(6);
      _lonController.text = position.longitude.toStringAsFixed(6);
    });
  },
)
```

**Permission Handling**:
- Request location permissions
- Handle denied permissions gracefully
- Show rationale for permission request
- Fallback to manual input

#### 3. Image Selection and Upload

**Source Options**:
- Camera capture
- Gallery selection
- Bottom sheet for source selection

**Image Picker Dialog**:
```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Column(
    children: [
      ListTile(
        leading: Icon(Icons.camera),
        title: Text('Take Photo'),
        onTap: () => _pickImage(ImageSource.camera),
      ),
      ListTile(
        leading: Icon(Icons.photo_library),
        title: Text('Choose from Gallery'),
        onTap: () => _pickImage(ImageSource.gallery),
      ),
    ],
  ),
);
```

**Image Processing**:
- Automatic resize to 800x600 pixels
- Maintain aspect ratio
- Compress for optimal file size
- Base64 encoding for API transmission
- Preview before submission

#### 4. Input Validation

**Validation Rules**:
- Title: Required, 1-100 characters
- Latitude: Required, -90 to 90
- Longitude: Required, -180 to 180
- Image: Required for new landmarks

**Visual Feedback**:
- Error messages below fields
- Red border on invalid fields
- Success checkmark on valid fields
- Disabled submit until all valid

**Implementation**:
```dart
TextFormField(
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a title';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  },
)
```

#### 5. Form Actions

**Submit Button**:
- Validates all fields
- Shows loading indicator
- Calls API service
- Handles success/error
- Navigates back on success

**Cancel Button**:
- Confirmation dialog if changes made
- Discards unsaved changes
- Navigates back to previous screen

**Reset Button**:
- Clears all fields
- Resets to default values
- Confirmation for data loss prevention

#### 6. Edit Mode

**Differences from Add Mode**:
- Pre-populated fields with existing data
- Show current image
- Update API endpoint instead of create
- "Update" button instead of "Add"
- Delete option available

**Data Loading**:
- Fetch landmark data by ID
- Display loading state
- Handle missing landmark
- Populate form fields

---

## Image Handling

### Overview
Comprehensive image management system for selecting, processing, and uploading landmark images with automatic optimization.

### Core Features

#### 1. Image Selection

**Source Options**:
- **Camera**: Capture new photo
- **Gallery**: Select existing image
- User choice via bottom sheet dialog

**Implementation**:
```dart
final ImagePicker _picker = ImagePicker();

Future<void> _pickImage(ImageSource source) async {
  final XFile? image = await _picker.pickImage(source: source);
  if (image != null) {
    await _processImage(image.path);
  }
}
```

**Permissions**:
- Camera permission request
- Photo library permission request
- Permission rationale dialogs
- Graceful fallback handling

#### 2. Image Processing

**Automatic Resizing**:
- Target dimensions: 800x600 pixels
- Maintain aspect ratio with cropping
- High-quality compression
- JPEG format optimization

**Resize Algorithm**:
```dart
import 'package:image/image.dart' as img;

Future<File> resizeImage(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  img.Image? image = img.decodeImage(bytes);

  if (image != null) {
    // Resize to 800x600
    img.Image resized = img.copyResize(
      image,
      width: 800,
      height: 600,
      interpolation: img.Interpolation.cubic,
    );

    // Save as JPEG with 85% quality
    final resizedBytes = img.encodeJpg(resized, quality: 85);

    // Write to temporary file
    final tempFile = File('${imageFile.path}_resized.jpg');
    await tempFile.writeAsBytes(resizedBytes);

    return tempFile;
  }
  return imageFile;
}
```

#### 3. Base64 Encoding

**Conversion Process**:
- Read image file as bytes
- Encode bytes to Base64 string
- Attach to JSON payload
- Decode on server/display

**Implementation**:
```dart
import 'dart:convert';
import 'dart:io';

Future<String> encodeImageToBase64(File imageFile) async {
  final bytes = await imageFile.readAsBytes();
  return base64Encode(bytes);
}

Image decodeBase64ToImage(String base64String) {
  final bytes = base64Decode(base64String);
  return Image.memory(bytes);
}
```

#### 4. Image Preview

**Features**:
- Thumbnail preview in form
- Full-size preview on tap
- Zoom and pan in preview
- Replace/remove image options

**Preview Widget**:
```dart
GestureDetector(
  onTap: () => _showFullImage(context),
  child: Container(
    height: 200,
    decoration: BoxDecoration(
      image: DecorationImage(
        image: FileImage(_imageFile!),
        fit: BoxFit.cover,
      ),
      borderRadius: BorderRadius.circular(8),
    ),
  ),
)
```

#### 5. Image Caching

**Cache Strategy**:
- Use cached_network_image package
- Memory and disk caching
- Automatic cache eviction
- Placeholder while loading
- Error image on failure

**Implementation**:
```dart
CachedNetworkImage(
  imageUrl: landmark.imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  fit: BoxFit.cover,
  memCacheWidth: 800,
  memCacheHeight: 600,
)
```

#### 6. Error Handling

**Scenarios**:
- Image selection cancelled
- Unsupported image format
- File size too large
- Processing errors
- Upload failures

**User Feedback**:
- Clear error messages
- Retry options
- Format/size requirements
- Helpful suggestions

---

## Error Handling & User Feedback

### Overview
Comprehensive error handling and user feedback system ensuring users are always informed of app state, actions, and issues.

### Core Features

#### 1. Snackbar Notifications

**Use Cases**:
- Success messages (e.g., "Landmark added successfully")
- Error notifications (e.g., "Failed to load landmarks")
- Information alerts (e.g., "Pull to refresh data")
- Action confirmations

**Implementation**:
```dart
void showSnackbar(BuildContext context, String message, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
      duration: Duration(seconds: 3),
      action: SnackBarAction(
        label: 'DISMISS',
        textColor: Colors.white,
        onPressed: () {},
      ),
    ),
  );
}
```

**Undo Functionality**:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Landmark deleted'),
    action: SnackBarAction(
      label: 'UNDO',
      onPressed: () => _restoreLandmark(deletedLandmark),
    ),
  ),
);
```

#### 2. Confirmation Dialogs

**Delete Confirmation**:
```dart
Future<bool> confirmDelete(BuildContext context, String landmarkTitle) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Landmark'),
      content: Text('Are you sure you want to delete "$landmarkTitle"?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('DELETE', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  ) ?? false;
}
```

**Discard Changes**:
- Shown when navigating away from unsaved form
- Confirm data loss
- Save draft option (optional)

#### 3. Network Error Handling

**Error Types**:
- No internet connection
- Server unreachable (timeout)
- 404 Not Found
- 500 Server Error
- Invalid response format

**Error Recovery**:
```dart
try {
  final response = await http.get(Uri.parse(apiUrl));
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw HttpException('Server error: ${response.statusCode}');
  }
} on SocketException {
  showErrorDialog(context, 'No Internet Connection',
    'Please check your network settings and try again.');
} on TimeoutException {
  showErrorDialog(context, 'Request Timeout',
    'The server is not responding. Please try again later.');
} catch (e) {
  showErrorDialog(context, 'Error', 'An unexpected error occurred: $e');
}
```

**Retry Mechanism**:
- Automatic retry for transient failures
- Exponential backoff
- Manual retry button
- Offline queue for pending actions

#### 4. Loading Indicators

**Full Screen Loading**:
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircularProgressIndicator(),
      SizedBox(height: 16),
      Text('Loading landmarks...'),
    ],
  ),
)
```

**Inline Loading**:
- Skeleton screens
- Shimmer effects
- Progress bars for uploads
- Button loading states

#### 5. Input Validation Feedback

**Real-time Validation**:
- Error text below invalid fields
- Red border on error
- Green checkmark on valid
- Helper text for guidance

**Form-level Validation**:
- Validation on submit
- Focus first invalid field
- Scroll to error
- Summary of errors

#### 6. Empty States

**No Data Available**:
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.location_off, size: 64, color: Colors.grey),
      SizedBox(height: 16),
      Text('No landmarks yet'),
      SizedBox(height: 8),
      ElevatedButton(
        onPressed: () => _navigateToAddScreen(),
        child: Text('Add First Landmark'),
      ),
    ],
  ),
)
```

**Search No Results**:
- "No results found for '{query}'"
- Clear search button
- Search suggestions

---

## Offline Caching (Bonus)

### Overview
Local database caching system using SQLite to enable offline access, reduce API calls, and improve app performance.

### Core Features

#### 1. Local Database Setup

**Database Structure**:
```sql
CREATE TABLE landmarks (
  id TEXT PRIMARY KEY,
  title TEXT NOT NULL,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  image TEXT NOT NULL,
  created_at INTEGER,
  updated_at INTEGER,
  is_synced INTEGER DEFAULT 1
);
```

**Implementation**:
```dart
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'landmarks.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE landmarks(id TEXT PRIMARY KEY, title TEXT, '
          'latitude REAL, longitude REAL, image TEXT, is_synced INTEGER)',
        );
      },
    );
  }
}
```

#### 2. Cache Strategy

**Write-Through Caching**:
- Write to API first
- On success, update local cache
- On failure, queue for later sync

**Read Strategy**:
- Read from cache first
- Display cached data immediately
- Fetch from API in background
- Update cache with fresh data

**Implementation**:
```dart
Future<List<Landmark>> getLandmarks() async {
  // Read from cache first
  final cachedLandmarks = await _databaseService.getAllLandmarks();

  // Return cached data immediately
  if (cachedLandmarks.isNotEmpty) {
    _updateUI(cachedLandmarks);
  }

  // Fetch fresh data in background
  try {
    final freshLandmarks = await _apiService.fetchLandmarks();
    await _databaseService.saveAllLandmarks(freshLandmarks);
    _updateUI(freshLandmarks);
    return freshLandmarks;
  } catch (e) {
    // Network error - use cached data
    return cachedLandmarks;
  }
}
```

#### 3. Offline Mode Detection

**Network Monitoring**:
```dart
import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get isOnline => _connectivity.onConnectivityChanged.map(
    (result) => result != ConnectivityResult.none,
  );

  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }
}
```

**Offline Indicator**:
- Banner at top of screen
- "Offline Mode" message
- Sync status indicator
- Last sync timestamp

#### 4. Pending Actions Queue

**Queue Management**:
```dart
class PendingAction {
  final String id;
  final String type; // 'create', 'update', 'delete'
  final Map<String, dynamic> data;
  final DateTime timestamp;
}

Future<void> queueAction(PendingAction action) async {
  await _database.insert('pending_actions', action.toMap());
}

Future<void> processPendingActions() async {
  final actions = await _getPendingActions();
  for (final action in actions) {
    try {
      await _executeAction(action);
      await _removePendingAction(action.id);
    } catch (e) {
      // Keep in queue, will retry later
    }
  }
}
```

**Auto-Sync**:
- Sync on network reconnection
- Background sync at intervals
- Sync on app foreground
- Manual sync option

#### 5. Data Synchronization

**Conflict Resolution**:
- Last-write-wins strategy
- Server data takes precedence
- Timestamp-based decisions
- User notification on conflicts

**Sync Process**:
```dart
Future<void> synchronize() async {
  if (!await _networkService.checkConnection()) {
    return; // Skip if offline
  }

  // 1. Upload pending changes
  await _uploadPendingChanges();

  // 2. Fetch latest from server
  final serverData = await _apiService.fetchAllLandmarks();

  // 3. Compare with local data
  final localData = await _databaseService.getAllLandmarks();

  // 4. Merge and resolve conflicts
  final mergedData = _mergeData(localData, serverData);

  // 5. Update local cache
  await _databaseService.replaceAllLandmarks(mergedData);

  // 6. Update UI
  _updateUI(mergedData);
}
```

#### 6. Cache Management

**Cache Size Limits**:
- Maximum cached images
- Automatic cleanup of old data
- User-controlled cache clearing

**Cache Settings**:
```dart
Future<void> clearCache() async {
  await _databaseService.clearAllLandmarks();
  await _imageCacheManager.emptyCache();
  showSnackbar(context, 'Cache cleared successfully');
}

Future<int> getCacheSize() async {
  final dbSize = await _databaseService.getDatabaseSize();
  final imageSize = await _imageCacheManager.getCacheSize();
  return dbSize + imageSize;
}
```

---

## User Authentication (Bonus)

### Overview
Secure user authentication system for protecting landmark management features and personalizing user experience.

### Core Features

#### 1. User Registration

**Registration Form**:
- Username (unique, 3-20 chars)
- Email (valid format)
- Password (min 8 chars, complexity rules)
- Confirm password (must match)

**Validation**:
```dart
String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain an uppercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(value)) {
    return 'Password must contain a number';
  }
  return null;
}
```

**Registration Process**:
```dart
Future<void> register() async {
  try {
    final response = await _apiService.registerUser(
      username: _usernameController.text,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (response.success) {
      await _saveUserCredentials(response.user);
      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ));
    } else {
      showErrorDialog(context, 'Registration Failed', response.message);
    }
  } catch (e) {
    showErrorDialog(context, 'Error', 'Registration failed: $e');
  }
}
```

#### 2. User Login

**Login Form**:
- Username or email
- Password
- Remember me checkbox
- Forgot password link

**Login Flow**:
```dart
Future<void> login() async {
  try {
    final response = await _apiService.loginUser(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (response.success) {
      await _authService.saveToken(response.token);
      await _authService.saveUser(response.user);

      if (_rememberMe) {
        await _saveCredentials();
      }

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => HomeScreen(),
      ));
    } else {
      showSnackbar(context, 'Invalid credentials', isError: true);
    }
  } catch (e) {
    showErrorDialog(context, 'Login Error', e.toString());
  }
}
```

#### 3. Session Management

**Token Storage**:
```dart
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && !_isTokenExpired(token);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
```

**Auto-Login**:
- Check for saved token on app launch
- Validate token expiration
- Auto-navigate to home if valid
- Redirect to login if invalid/expired

#### 4. Protected Routes

**Authentication Guard**:
```dart
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({required this.child});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SplashScreen();
        }

        if (snapshot.data == true) {
          return child;
        } else {
          return LoginScreen();
        }
      },
    );
  }
}
```

**Usage**:
```dart
void main() {
  runApp(MaterialApp(
    home: AuthGuard(child: HomeScreen()),
  ));
}
```

#### 5. API Authentication

**Token Injection**:
```dart
Future<http.Response> authenticatedRequest(String url) async {
  final token = await _authService.getToken();

  return await http.get(
    Uri.parse(url),
    headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    },
  );
}
```

**Token Refresh**:
- Automatic token refresh before expiry
- Refresh on 401 Unauthorized response
- Logout on refresh failure

#### 6. User Profile

**Profile Features**:
- View user information
- Edit profile details
- Change password
- Delete account
- Logout

**Profile Screen**:
```dart
class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User>(
      future: _authService.getCurrentUser(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return CircularProgressIndicator();

        final user = snapshot.data!;
        return Column(
          children: [
            CircleAvatar(radius: 50, child: Text(user.initials)),
            Text(user.username, style: Theme.of(context).textTheme.headline6),
            Text(user.email),
            ElevatedButton(
              onPressed: _editProfile,
              child: Text('Edit Profile'),
            ),
            TextButton(
              onPressed: _logout,
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}
```

---

## Custom Map Themes

### Overview
Customizable map styling to enhance visual appeal, improve readability, and match app branding.

### Core Features

#### 1. Theme Options

**Available Themes**:
- **Standard**: Default Google Maps style
- **Silver**: Minimalist grayscale design
- **Night**: Dark theme for low-light conditions
- **Retro**: Vintage map appearance
- **Minimal**: Clean, distraction-free view
- **Custom**: Brand-specific styling

#### 2. Theme Implementation

**JSON Style Definition**:
```json
[
  {
    "elementType": "geometry",
    "stylers": [{"color": "#f5f5f5"}]
  },
  {
    "elementType": "labels.icon",
    "stylers": [{"visibility": "off"}]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{"color": "#c9c9c9"}]
  }
]
```

**Apply Theme**:
```dart
GoogleMap(
  onMapCreated: (controller) {
    controller.setMapStyle(_loadMapStyle('assets/map_styles/silver.json'));
  },
)

Future<String> _loadMapStyle(String path) async {
  return await rootBundle.loadString(path);
}
```

#### 3. Dynamic Theme Switching

**Theme Selector**:
```dart
DropdownButton<MapTheme>(
  value: _selectedTheme,
  items: MapTheme.values.map((theme) {
    return DropdownMenuItem(
      value: theme,
      child: Text(theme.name),
    );
  }).toList(),
  onChanged: (theme) {
    setState(() {
      _selectedTheme = theme;
      _applyMapTheme(theme);
    });
  },
)
```

**Theme Persistence**:
- Save selected theme in preferences
- Auto-apply on app launch
- Sync across devices (with auth)

#### 4. Custom Branding

**Brand Colors**:
- Primary color for markers
- Accent color for selected landmarks
- Background matching app theme
- Consistent color scheme

**Custom Elements**:
- Branded marker icons
- Custom info window design
- Styled map controls
- Logo watermark (optional)

#### 5. Accessibility

**High Contrast Mode**:
- Enhanced visibility
- Color-blind friendly palettes
- Clear text labels
- Sufficient contrast ratios

**Readability**:
- Larger text labels
- Simplified map features
- Reduced clutter
- Clear landmark distinction

---

## Performance Optimizations

### Key Strategies

1. **Lazy Loading**: Load data as needed
2. **Image Caching**: Reduce network requests
3. **Database Indexing**: Fast queries
4. **Pagination**: Load landmarks in chunks
5. **Debouncing**: Limit API calls during search
6. **Widget Optimization**: Use const constructors
7. **Memory Management**: Dispose resources properly

---

## Accessibility Features

### Implemented Features

1. **Screen Reader Support**: Semantic labels
2. **Keyboard Navigation**: Tab order and shortcuts
3. **Text Scaling**: Respect system font size
4. **Color Contrast**: WCAG AA compliance
5. **Touch Targets**: Minimum 48x48 dp
6. **Alternative Text**: Images and icons

---

**Last Updated**: December 2025
