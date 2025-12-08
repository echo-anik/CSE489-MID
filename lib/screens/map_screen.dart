import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/landmark.dart';
import '../providers/landmark_provider.dart';
import 'form_screen.dart';

/// Map screen displaying landmarks on OpenStreetMap
/// Uses flutter_map - NO API KEY REQUIRED!
class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  Landmark? _selectedLandmark;

  // Default location: Dhaka, Bangladesh
  static const LatLng _defaultLocation = LatLng(23.8103, 90.4125);
  static const double _defaultZoom = 12.0;

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  /// Build markers from landmarks
  List<Marker> _buildMarkers(List<Landmark> landmarks) {
    return landmarks.map((landmark) {
      return Marker(
        point: LatLng(landmark.latitude, landmark.longitude),
        width: 40,
        height: 40,
        child: GestureDetector(
          onTap: () => _showLandmarkDetails(landmark),
          child: const Icon(
            Icons.location_on,
            size: 40,
            color: Colors.red,
          ),
        ),
      );
    }).toList();
  }

  /// Show landmark details in bottom sheet
  void _showLandmarkDetails(Landmark landmark) {
    setState(() {
      _selectedLandmark = landmark;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildLandmarkBottomSheet(landmark),
    );
  }

  /// Build bottom sheet content
  Widget _buildLandmarkBottomSheet(Landmark landmark) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                // Landmark image
                if (landmark.imageUrl?.isNotEmpty ?? false)
                  _buildImageWidget(landmark.imageUrl),

                const SizedBox(height: 16),

                // Title
                Text(
                  landmark.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                // Coordinates
                _buildInfoRow(
                  Icons.location_on,
                  'Coordinates',
                  '${landmark.latitude.toStringAsFixed(6)}, ${landmark.longitude.toStringAsFixed(6)}',
                ),

                const SizedBox(height: 12),

                // ID
                _buildInfoRow(
                  Icons.tag,
                  'ID',
                  landmark.id?.toString() ?? 'N/A',
                ),

                const SizedBox(height: 24),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleEdit(landmark),
                        icon: const Icon(Icons.edit),
                        label: const Text('Edit'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleDelete(landmark),
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Build image widget - handles both URLs and base64
  Widget _buildImageWidget(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    // Check if it's a base64 string
    if (imageUrl.startsWith('data:') ||
        (!imageUrl.contains('/') && !imageUrl.contains('.') && imageUrl.length > 100)) {
      try {
        final base64String = imageUrl.replaceFirst(RegExp(r'^data:image\/[^;]+;base64,'), '');
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(base64String),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported, size: 50),
              );
            },
          ),
        );
      } catch (e) {
        return Container(
          width: double.infinity,
          height: 200,
          color: Colors.grey[300],
          child: const Icon(Icons.image_not_supported, size: 50),
        );
      }
    } else {
      // It's a URL or path
      final fullUrl = imageUrl.startsWith('http')
          ? imageUrl
          : 'https://labs.anontech.info/cse489/t3/$imageUrl';

      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          fullUrl,
          width: double.infinity,
          height: 200,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported, size: 50),
            );
          },
        ),
      );
    }
  }

  /// Build info row widget
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Handle edit action
  void _handleEdit(Landmark landmark) {
    Navigator.pop(context); // Close bottom sheet
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormScreen(landmark: landmark),
      ),
    );
  }

  /// Handle delete action
  void _handleDelete(Landmark landmark) {
    Navigator.pop(context); // Close bottom sheet

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Landmark'),
        content: Text('Are you sure you want to delete "${landmark.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteLandmark(landmark);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete landmark
  Future<void> _deleteLandmark(Landmark landmark) async {
    try {
      final provider = Provider.of<LandmarkProvider>(context, listen: false);
      await provider.deleteLandmark(landmark.id!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${landmark.title} deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LandmarkProvider>(
      builder: (context, provider, child) {
        final markers = _buildMarkers(provider.landmarks);

        return Stack(
          children: [
            // OpenStreetMap - NO API KEY NEEDED!
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultLocation,
                initialZoom: _defaultZoom,
                minZoom: 3,
                maxZoom: 18,
              ),
              children: [
                // Tile layer from OpenStreetMap
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.cse489.bangladesh_landmarks',
                  maxZoom: 19,
                ),
                // Markers layer
                MarkerLayer(markers: markers),
              ],
            ),

            // Loading indicator
            if (provider.isLoading)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),

            // Empty state
            if (!provider.isLoading && provider.landmarks.isEmpty)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[850]
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.map_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No landmarks yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a new landmark to see it on the map',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
