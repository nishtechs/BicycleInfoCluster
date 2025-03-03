import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      // Use builder only if you need to use library outside ScreenUtilInit context
      builder: (_, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // You can use the library anywhere in the app even in theme
          theme: ThemeData(
            primarySwatch: Colors.deepPurple,
            textTheme: Typography.englishLike2018.apply(fontSizeFactor: 1.sp),
          ),
          home: child,
        );
      },
      child: const BicycleComputerScreen(),
    );

/*    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        // Use builder only if you need to use library outside ScreenUtilInit context
        builder: (_, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Bicycle Computer',
            theme: ThemeData(
              primarySwatch: Colors.blue,
            ),
            home: BicycleComputerScreen(),
          );
        },
      child
        );*/
  }
}

class BicycleComputerScreen extends StatefulWidget {
  const BicycleComputerScreen({super.key});

  @override
  _BicycleComputerScreenState createState() => _BicycleComputerScreenState();
}

class _BicycleComputerScreenState extends State<BicycleComputerScreen> {
  double _speed = 0.0;
  double _distance = 0.0;
  double _heading = 0.0;
  String _direction = '';
  DateTime _currentTime = DateTime.now();
  // FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initCompass();
    _initLocation();
    _initNotifications();
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
        _speed = position.speed;
        _distance += position.speed * (1 / 3600); // Update distance in km
      });
    });
  }

  void _initNotifications() {
/*    var initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);*/
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
    });
    Future.delayed(const Duration(seconds: 1), _updateTime);
  }

  void _setAlarm() async {
  /*  var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'alarm_channel',
      'Alarm Channel',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Alarm',
      'Time to take a break!',
      platformChannelSpecifics,
    );*/
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
        centerTitle: true,
        title: Text(
          'Bikxter',
          style: GoogleFonts.poppins(fontSize: 25.sp, fontWeight: FontWeight.w600, fontFeatures: [FontFeature.alternativeFractions()], color: Colors.black),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${_currentTime.hour}:${_currentTime.minute}', style: GoogleFonts.poppins(fontSize: 30.sp, fontWeight: FontWeight.w600, color: Colors.lightGreenAccent)),
                SizedBox(
                  height: 5.h,
                ),
                // Compass UI with Rotating Circle
                SizedBox(
                  width: 250.w,
                  height: 250.h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating Compass Background

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

                      // Static Arrow (Fixed)
                      Icon(
                        Icons.navigation,
                        size: 80.h,
                        color: Colors.red,
                      ),

                      // Center Dot
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
                Text('Speed: ${_speed.toStringAsFixed(2)} km/h', style: GoogleFonts.poppins(fontSize: 24.sp, color: Colors.black)),
                SizedBox(height: 5.h),
                // ODO Meter
                Text('Distance: ${_distance.toStringAsFixed(2)} km', style: GoogleFonts.poppins(fontSize: 24.sp, color: Colors.black)),
                SizedBox(height: 5.h),
                // Compass Heading and Direction
                Text('Compass: ${_heading.toStringAsFixed(2)}°', style: GoogleFonts.poppins(fontSize: 24.sp, color: Colors.black)),
                SizedBox(height: 5.h),
                Text('Direction: $_direction', style: GoogleFonts.poppins(fontSize: 24.sp, color: Colors.black)),
                SizedBox(height: 5.h),
                // Current Time
                SizedBox(height: 5.h),
                // Alarm Button
                ElevatedButton(
                  onPressed: _setAlarm,
                  child: const Text('Set Alarm'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
