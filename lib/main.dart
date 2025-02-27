import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GPS Speed Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SpeedTracker(),
    );
  }
}

class SpeedTracker extends StatefulWidget {
  const SpeedTracker({super.key});

  @override
  _SpeedTrackerState createState() => _SpeedTrackerState();
}

class _SpeedTrackerState extends State<SpeedTracker> {
  String _speed = '0.0';
  late Position _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request them
      return;
    }

    // Check location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return;
      }
    }

    // Get the current location with desired accuracy
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high, // Set the desired accuracy
      distanceFilter: 10, // Minimum distance (in meters) between location updates
    );

    // Start listening to location updates
    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position position) {
      setState(() {
        _currentPosition = position;
        double speedInMetersPerSecond = _currentPosition.speed;
        double speedInKilometersPerHour = speedInMetersPerSecond * 3.6; // Convert m/s to km/h
        _speed = speedInKilometersPerHour.toStringAsFixed(2); // Speed in km/h
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS Speed Tracker'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Current Speed:',
                style: TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              Text(
                '$_speed km/h', // Display speed in km/h
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}