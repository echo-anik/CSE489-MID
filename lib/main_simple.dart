import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bangladesh Landmarks',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
      ),
      home: const LandmarkListScreen(),
    );
  }
}

class Landmark {
  final int id;
  final String title;
  final double latitude;
  final double longitude;

  Landmark({
    required this.id,
    required this.title,
    required this.latitude,
    required this.longitude,
  });
}

class LandmarkListScreen extends StatefulWidget {
  const LandmarkListScreen({Key? key}) : super(key: key);

  @override
  State<LandmarkListScreen> createState() => _LandmarkListScreenState();
}

class _LandmarkListScreenState extends State<LandmarkListScreen> {
  final List<Landmark> _landmarks = [
    Landmark(id: 1, title: 'Shaheed Minar', latitude: 23.7272, longitude: 90.3969),
    Landmark(id: 2, title: 'National Martyrs Memorial', latitude: 23.9102, longitude: 90.2701),
    Landmark(id: 3, title: 'Lalbagh Fort', latitude: 23.7186, longitude: 90.3876),
    Landmark(id: 4, title: 'Ahsan Manzil', latitude: 23.7083, longitude: 90.4061),
    Landmark(id: 5, title: 'Sixty Dome Mosque', latitude: 22.6865, longitude: 89.4429),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bangladesh Landmarks'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: _landmarks.length,
        padding: const EdgeInsets.all(8.0),
        itemBuilder: (context, index) {
          final landmark = _landmarks[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
                child: Text('${landmark.id}'),
              ),
              title: Text(
                landmark.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                'Lat: ${landmark.latitude.toStringAsFixed(4)}, Lon: ${landmark.longitude.toStringAsFixed(4)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LandmarkDetailScreen(landmark: landmark),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Landmark feature coming soon!')),
          );
        },
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class LandmarkDetailScreen extends StatelessWidget {
  final Landmark landmark;

  const LandmarkDetailScreen({Key? key, required this.landmark}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(landmark.title),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Icon(
                  Icons.landscape,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              landmark.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('ID', landmark.id.toString()),
            _buildInfoRow('Latitude', landmark.latitude.toStringAsFixed(6)),
            _buildInfoRow('Longitude', landmark.longitude.toStringAsFixed(6)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Map view coming soon!')),
                  );
                },
                icon: const Icon(Icons.map),
                label: const Text('View on Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
