import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool? _isInCollege;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    try {
      final result = await isInCollege();
      if (mounted) {
        setState(() {
          _isInCollege = result;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        setState(() {
          _isInCollege = false;
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return false;
  }

  Future<bool> isInCollege() async {
    final allowed = await requestLocationPermission();
    if (!allowed) {
      return false;
    }

    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');
      return false;
    }

    // ALWAYS get current position for security (no cached location)
    Position position;
    try {
      position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            forceAndroidLocationManager: true,
          ).timeout(
            const Duration(seconds: 15),
            onTimeout: () =>
                throw Exception('Location timeout - ensure GPS is on'),
          );
    } catch (e) {
      print('Location error: $e');
      return false;
    }

    print('Current position: ${position.latitude}, ${position.longitude}');

    final distanceInMeters = Geolocator.distanceBetween(
      position.latitude,
      position.longitude,
      31.111140995327748,
      77.13516598512842,
    );

    print('Distance: $distanceInMeters meters');

    return distanceInMeters <= 100;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Check')),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Text(
                _isInCollege == true
                    ? '✅ You are at the college location'
                    : '❌ You are NOT at the college location',
                style: const TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
      ),
    );
  }
}
