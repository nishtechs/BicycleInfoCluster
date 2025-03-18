import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:google_fonts/google_fonts.dart';

import 'deepseek.dart';
import 'ocr.dart';

void main() async {
  await dotenv.load(fileName: "lib/.env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: child,
        );
      },
      child: const BicycleComputerScreen(),
    );
  }
}

class BicycleComputerScreen extends StatefulWidget {
  const BicycleComputerScreen({super.key});

  @override
  _BicycleComputerScreenState createState() => _BicycleComputerScreenState();
}

class _BicycleComputerScreenState extends State<BicycleComputerScreen> {
  double _speed = 0.0; // Speed in km/h
  double _distance = 0.0; // Distance in km
  double _heading = 0.0;
  String _direction = '';
  DateTime _currentTime = DateTime.now();
  Position? _previousPosition;

  String openApiKey = dotenv.env['OPEN_AI_KEYS'] ?? '1111';
  String deepseekApiKey = dotenv.env['DEEPSEEK_AI_KEYS'] ?? '2222';
  String baseUrl = dotenv.env['BASE_URL'] ?? '3333';
  String appName = dotenv.env['APP_NAME'] ?? '4444';

  @override
  void initState() {
    super.initState();
    _initCompass();
    _initLocation();
    _updateTime();
  }

  double convertHeading(double heading) {
    return (heading > 180) ? heading - 360 : heading;
  }

  void _initCompass() {
    FlutterCompass.events?.listen((CompassEvent event) {
      setState(() {
        _heading = convertHeading(event.heading ?? 0.0);
        _direction = _getDirection(_heading);
      });
    });
  }

  void _initLocation() {
    Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        // Convert speed from m/s to km/h
        _speed = position.speed * 3.6;

        // Calculate distance if there's a previous position
        if (_previousPosition != null) {
          double distanceInMeters = Geolocator.distanceBetween(
            _previousPosition!.latitude,
            _previousPosition!.longitude,
            position.latitude,
            position.longitude,
          );
          _distance += distanceInMeters / 1000; // Convert to km
        }

        // Update the previous position
        _previousPosition = position;
      });
    });
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
    });
    Future.delayed(const Duration(seconds: 1), _updateTime);
  }

  String _getDirection(double heading) {
    double normalizedHeading = (heading < 0) ? heading + 360 : heading;

    if (normalizedHeading >= 337.5 || normalizedHeading < 22.5) {
      return 'N';
    } else if (normalizedHeading >= 22.5 && normalizedHeading < 67.5) {
      return 'NE';
    } else if (normalizedHeading >= 67.5 && normalizedHeading < 112.5) {
      return 'E';
    } else if (normalizedHeading >= 112.5 && normalizedHeading < 157.5) {
      return 'SE';
    } else if (normalizedHeading >= 157.5 && normalizedHeading < 202.5) {
      return 'S';
    } else if (normalizedHeading >= 202.5 && normalizedHeading < 247.5) {
      return 'SW';
    } else if (normalizedHeading >= 247.5 && normalizedHeading < 292.5) {
      return 'W';
    } else if (normalizedHeading >= 292.5 && normalizedHeading < 337.5) {
      return 'NW';
    } else {
      return 'N';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        centerTitle: true,
        title: Text(
          appName,
          style: GoogleFonts.poppins(fontSize: 25.sp, fontWeight: FontWeight.w600, fontFeatures: [const FontFeature.alternativeFractions()], color: Colors.black87),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    // navigateToDeepseek();
                    navigateToOCR();
                  },
                  child: Card(
                    child: Text(
                      '${_currentTime.hour}:${_currentTime.minute}',
                      style: GoogleFonts.poppins(fontSize: 30.sp, fontWeight: FontWeight.w600, color: Colors.lightGreenAccent),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                // Compass UI with Rotating Circle
                SizedBox(
                  width: 250.w,
                  height: 250.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Transform.rotate(
                        angle: _heading * (pi / 180), // Convert degrees to radians
                        child: Image.asset(
                          'assets/compass.png', // Add a compass image with N, NE, E, etc.
                          width: 220.w,
                          height: 220.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Transform.rotate(
                        angle: _heading * (pi / -180), // Convert degrees to radians
                        child: Image.asset(
                          'assets/compass.png', // Add a compass image with N, NE, E, etc.
                          width: 180.w,
                          height: 180.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      Icon(
                        Icons.navigation,
                        size: 80.h,
                        color: Colors.red,
                      ),
                      Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                // Speedometer
                Text(
                  'Speed: ${_speed.toStringAsFixed(2)} km/h',
                  style: GoogleFonts.poppins(fontSize: 24.sp, color: Colors.black),
                ),
                SizedBox(height: 5.h),
                // ODO Meter
                Text(
                  'Distance: ${_distance.toStringAsFixed(2)} km',
                  style: GoogleFonts.poppins(fontSize: 24.sp, color: Colors.black),
                ),
                SizedBox(height: 5.h),
                // Compass Heading and Direction
                Text(
                  'Compass: ${_heading.toStringAsFixed(2)}°',
                  style: GoogleFonts.poppins(fontSize: 24.sp, color: Colors.black),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Direction: $_direction',
                  style: GoogleFonts.poppins(fontSize: 24.sp, color: Colors.black),
                ),
                SizedBox(height: 5.h),
                // Alarm Button
                ElevatedButton(
                  onPressed: () {}, // Add your alarm logic here
                  child: const Text('Set Alarm'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  navigateToDeepseek() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => Deepseek()));
  }


  navigateToOCR(){
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => OCR(title: 'OCR',)));
  }
}
