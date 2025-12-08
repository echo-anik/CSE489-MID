import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../models/landmark.dart';
import '../providers/landmark_provider.dart';

/// Form screen for adding or editing landmarks
/// Features image picker, GPS auto-detect, and validation
class FormScreen extends StatefulWidget {
  final Landmark? landmark;

  const FormScreen({Key? key, this.landmark}) : super(key: key);

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  File? _selectedImage;
  Uint8List? _webImageBytes;
  String? _base64Image;
  bool _isLoading = false;
  bool _isDetectingLocation = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  /// Initialize form with existing landmark data if editing
  void _initializeForm() {
    if (widget.landmark != null) {
      _titleController.text = widget.landmark!.title;
      _latitudeController.text = widget.landmark!.latitude.toString();
      _longitudeController.text = widget.landmark!.longitude.toString();
      _base64Image = widget.landmark!.imageUrl;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  /// Validate title field
  String? _validateTitle(String? value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    if (value.length > 100) {
      return 'Title must be less than 100 characters';
    }
    return null;
  }

  /// Validate latitude field
  String? _validateLatitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Latitude is required';
    }
    final lat = double.tryParse(value);
    if (lat == null) {
      return 'Enter a valid number';
    }
    if (lat < -90 || lat > 90) {
      return 'Latitude must be between -90 and 90';
    }
    return null;
  }

  /// Validate longitude field
  String? _validateLongitude(String? value) {
    if (value == null || value.isEmpty) {
      return 'Longitude is required';
    }
    final lon = double.tryParse(value);
    if (lon == null) {
      return 'Enter a valid number';
    }
    if (lon < -180 || lon > 180) {
      return 'Longitude must be between -180 and 180';
    }
    return null;
  }

  /// Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image: ${e.toString()}');
    }
  }

  /// Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 85,
      );

      if (image != null) {
        await _processImage(image);
      }
    } catch (e) {
      _showErrorSnackBar('Failed to select image: ${e.toString()}');
    }
  }

  /// Process and encode image
  Future<void> _processImage(XFile image) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bytes = await image.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        if (kIsWeb) {
          // On web, store bytes directly
          _webImageBytes = bytes;
          _selectedImage = null;
        } else {
          // On mobile/desktop, use File
          _selectedImage = File(image.path);
          _webImageBytes = null;
        }
        _base64Image = base64String;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to process image: ${e.toString()}');
    }
  }

  /// Show image picker options
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Camera option only available on mobile
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.blue),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
              ListTile(
                leading: const Icon(Icons.photo_library, color: Colors.blue),
                title: Text(kIsWeb ? 'Choose Image' : 'Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImageFromGallery();
                },
              ),
              if (_selectedImage != null || _webImageBytes != null || _base64Image != null)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Image'),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _selectedImage = null;
                      _webImageBytes = null;
                      _base64Image = null;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Detect current GPS location
  Future<void> _detectLocation() async {
    setState(() {
      _isDetectingLocation = true;
    });

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(6);
        _longitudeController.text = position.longitude.toStringAsFixed(6);
        _isDetectingLocation = false;
      });

      _showSuccessSnackBar('Location detected successfully');
    } catch (e) {
      setState(() {
        _isDetectingLocation = false;
      });
      _showErrorSnackBar('Failed to detect location: ${e.toString()}');
    }
  }

  /// Submit form
  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_base64Image == null || _base64Image!.isEmpty) {
      _showErrorSnackBar('Please select an image');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<LandmarkProvider>(context, listen: false);

      if (widget.landmark != null) {
        // Update existing landmark
        final landmarkId = widget.landmark!.id;
        if (landmarkId == null) {
          _showErrorSnackBar('Cannot update landmark without ID');
          return;
        }

        final lat = double.tryParse(_latitudeController.text);
        final lon = double.tryParse(_longitudeController.text);

        if (lat == null || lon == null) {
          _showErrorSnackBar('Invalid coordinates');
          return;
        }

        await provider.updateLandmark(
          id: landmarkId,
          title: _titleController.text.trim(),
          latitude: lat,
          longitude: lon,
          imageFile: _selectedImage,
        );
        _showSuccessSnackBar('Landmark updated successfully');
      } else {
        // Create new landmark
        final lat = double.tryParse(_latitudeController.text);
        final lon = double.tryParse(_longitudeController.text);

        if (lat == null || lon == null) {
          _showErrorSnackBar('Invalid coordinates');
          return;
        }

        await provider.addLandmark(
          title: _titleController.text.trim(),
          latitude: lat,
          longitude: lon,
          imageFile: _selectedImage,
        );
        _showSuccessSnackBar('Landmark added successfully');
      }

      setState(() {
        _isLoading = false;
      });

      // Navigate back after short delay
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to save landmark: ${e.toString()}');
    }
  }

  /// Show success message
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error message
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Build image preview
  Widget _buildImagePreview() {
    if (_webImageBytes != null) {
      // Web: Display from bytes
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _webImageBytes!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (_selectedImage != null && !kIsWeb) {
      // Mobile/Desktop: Display from file
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          _selectedImage!,
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
      );
    } else if (_base64Image != null && _base64Image!.isNotEmpty) {
      // Fallback: Display from base64
      try {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            base64Decode(_base64Image!),
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        );
      } catch (e) {
        // Invalid base64, show placeholder
        return Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 60, color: Colors.red[400]),
                const SizedBox(height: 8),
                Text(
                  'Invalid image data',
                  style: TextStyle(color: Colors.red[600]),
                ),
              ],
            ),
          ),
        );
      }
    } else {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.image, size: 60, color: Colors.grey[400]),
              const SizedBox(height: 8),
              Text(
                'No image selected',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.landmark != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Landmark' : 'New Entry'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Image preview
                  _buildImagePreview(),

                  const SizedBox(height: 12),

                  // Image picker button
                  OutlinedButton.icon(
                    onPressed: _showImagePickerOptions,
                    icon: const Icon(Icons.add_a_photo),
                    label: Text(_selectedImage != null || _webImageBytes != null || _base64Image != null
                        ? 'Change Image'
                        : 'Select Image'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter landmark title',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateTitle,
                    textCapitalization: TextCapitalization.words,
                    maxLength: 100,
                  ),

                  const SizedBox(height: 16),

                  // Latitude field
                  TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude',
                      hintText: 'Enter latitude (-90 to 90)',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateLatitude,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Longitude field
                  TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude',
                      hintText: 'Enter longitude (-180 to 180)',
                      prefixIcon: Icon(Icons.my_location),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateLongitude,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                      signed: true,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // GPS auto-detect button
                  OutlinedButton.icon(
                    onPressed: _isDetectingLocation ? null : _detectLocation,
                    icon: _isDetectingLocation
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.gps_fixed),
                    label: Text(_isDetectingLocation
                        ? 'Detecting Location...'
                        : 'Auto-Detect GPS Location'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Submit button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isEditMode ? 'Update Landmark' : 'Add Landmark',
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }
}
