import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ucbs_attendance_app/presentation/screens/main/student/colors/student_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  bool? _isInCollege;
  bool _isLoading = true;
  Position? _currentPosition;
  double? _distance;
  String? _errorMessage;
  int _currentAttempt = 0;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentAttempt = 0;
    });

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
          _errorMessage = e.toString();
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

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('Location services are disabled');
      return false;
    }

    Position? bestPosition;
    int attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts) {
      setState(() {
        _currentAttempt = attempts + 1;
      });

      try {
        print('Checking location... Attempt ${attempts + 1}');
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
          timeLimit: const Duration(seconds: 8),
        );

        print('Attempt ${attempts + 1}: accuracy ${position.accuracy}m');

        if (position.accuracy <= 50) {
          bestPosition = position;
          print('Good accuracy achieved: ${position.accuracy}m');
          break;
        }

        if (bestPosition == null || position.accuracy < bestPosition.accuracy) {
          bestPosition = position;
        }

        attempts++;

        if (attempts < maxAttempts) {
          await Future.delayed(const Duration(milliseconds: 1500));
        }
      } catch (e) {
        print('Attempt ${attempts + 1} failed: $e');
        attempts++;
      }
    }

    if (bestPosition == null) {
      throw Exception('GPS timeout. Turn off VPN/DNS and go outside!');
    }

    _currentPosition = bestPosition;
    print(
      'Final: ${bestPosition.latitude}, ${bestPosition.longitude}, accuracy: ${bestPosition.accuracy}m',
    );

    final distanceInMeters = Geolocator.distanceBetween(
      bestPosition.latitude,
      bestPosition.longitude,
      31.111140995327748,
      77.13516598512842,
    );

    _distance = distanceInMeters;
    print('Distance: $distanceInMeters meters');

    final threshold = bestPosition.accuracy <= 50
        ? 100.0
        : 100.0 + (bestPosition.accuracy * 0.5);
    print('Threshold: $threshold meters (accuracy: ${bestPosition.accuracy}m)');

    return distanceInMeters <= threshold;
  }

  Future<void> _openInMaps() async {
    const lat = 31.111140995327748;
    const lng = 77.13516598512842;
    final url = Uri.parse('geo:$lat,$lng?q=$lat,$lng(UCBS Campus)');
    final fallbackUrl = Uri.parse('https://maps.google.com/?q=$lat,$lng');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StudentTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    if (_isLoading) _buildLoadingCard(),
                    if (!_isLoading && _isInCollege == true)
                      _buildSuccessCard(),
                    if (!_isLoading && _isInCollege == false)
                      _buildFailureCard(),
                    const SizedBox(height: 20),
                    _buildMapCard(),
                    const SizedBox(height: 20),
                    if (!_isLoading) _buildRetryButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.arrow_back, size: 20),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            "We're Watching You 👀",
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(color: StudentTheme.accentcoral),
          const SizedBox(height: 24),
          Text(
            'Checking Location...',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Attempt $_currentAttempt of 3',
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: StudentTheme.accentcoral,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Turn off VPN/DNS for better accuracy',
            style: GoogleFonts.inter(fontSize: 11, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, size: 64, color: Colors.green),
          ),
          const SizedBox(height: 24),
          Text(
            'You\'re at College! 🎓',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_distance?.toStringAsFixed(0) ?? '0'}m from campus',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: StudentTheme.accentcoral.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_off,
              size: 64,
              color: StudentTheme.accentcoral,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Not at College 📍',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (_distance != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: StudentTheme.accentcoral.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${(_distance! / 1000).toStringAsFixed(2)}km away',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: StudentTheme.accentcoral,
                ),
              ),
            ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _errorMessage!,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMapCard() {
    return GestureDetector(
      onTap: _openInMaps,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Campus Location',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'UCBS Campus',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: StudentTheme.accentcoral.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.map, color: StudentTheme.accentcoral),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: const LatLng(
                      31.111140995327748,
                      77.13516598512842,
                    ),
                    initialZoom: 16,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.pinchZoom | InteractiveFlag.drag,
                    ),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.ucbs_attendance_app',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: const LatLng(
                            31.111140995327748,
                            77.13516598512842,
                          ),
                          width: 40,
                          height: 40,
                          child: Icon(
                            Icons.location_on,
                            color: StudentTheme.accentcoral,
                            size: 40,
                          ),
                        ),
                        if (_currentPosition != null)
                          Marker(
                            point: LatLng(
                              _currentPosition!.latitude,
                              _currentPosition!.longitude,
                            ),
                            width: 30,
                            height: 30,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.black38),
                const SizedBox(width: 6),
                Text(
                  'Tap to open in Google Maps',
                  style: GoogleFonts.inter(fontSize: 11, color: Colors.black38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: _checkLocation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: StudentTheme.accentcoral,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.refresh, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              'RETRY VERIFICATION',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
