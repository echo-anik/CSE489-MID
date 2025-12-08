import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'map_screen.dart';
import 'list_screen.dart';
import 'form_screen.dart';
import '../providers/landmark_provider.dart';
import '../providers/theme_provider.dart';

/// Home screen with bottom navigation bar
/// Manages navigation between Map, Records, and New Entry tabs
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Start with List view instead of Map (better for web)

  // Screens for each tab
  final List<Widget> _screens = [
    const MapScreen(),
    const ListScreen(),
    const FormScreen(),
  ];

  // Titles for each tab
  final List<String> _titles = [
    'Map Overview',
    'Landmark Records',
    'New Entry',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch landmarks when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLandmarks();
    });
  }

  /// Load landmarks from API
  Future<void> _loadLandmarks() async {
    try {
      final provider = Provider.of<LandmarkProvider>(context, listen: false);
      await provider.fetchLandmarks();
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to load landmarks: ${e.toString()}');
      }
    }
  }

  /// Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _loadLandmarks,
        ),
      ),
    );
  }

  /// Handle logout
  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen (if implemented)
              // Navigator.pushReplacementNamed(context, '/login');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Logout functionality not implemented')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  /// Handle refresh action
  Future<void> _handleRefresh() async {
    await _loadLandmarks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        elevation: 2,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Theme toggle button
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(
                  themeProvider.themeMode == ThemeMode.dark
                      ? Icons.light_mode
                      : Icons.dark_mode,
                ),
                tooltip: themeProvider.themeMode == ThemeMode.dark
                    ? 'Switch to Light Mode'
                    : 'Switch to Dark Mode',
                onPressed: () {
                  themeProvider.toggleTheme();
                },
              );
            },
          ),
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _handleRefresh,
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[850]
            : Colors.white,
        selectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.tealAccent
            : Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[500]
            : Colors.grey[600],
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
            tooltip: 'Map Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Records',
            tooltip: 'Landmark Records',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_location),
            label: 'New Entry',
            tooltip: 'Add New Landmark',
          ),
        ],
      ),
    );
  }
}
