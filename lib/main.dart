import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bicycle Computer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BicycleComputerScreen(),
    );
  }
}

class BicycleComputerScreen extends StatefulWidget {
  @override
  _BicycleComputerScreenState createState() => _BicycleComputerScreenState();
}

class _BicycleComputerScreenState extends State<BicycleComputerScreen> {
  double _speed = 0.0;
  double _distance = 0.0;
  double _heading = 0.0;
  String _direction = 'N';
  DateTime _currentTime = DateTime.now();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

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
    var initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _updateTime() {
    setState(() {
      _currentTime = DateTime.now();
    });
    Future.delayed(Duration(seconds: 1), _updateTime);
  }

  void _setAlarm() async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
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
    );
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
      appBar: AppBar(
        title: Text('Bicycle Computer'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Compass UI with Rotating Circle
                Container(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Rotating Compass Background
                      Transform.rotate(
                        angle: _heading * (pi / -180), // Convert degrees to radians
                        child: Image.asset(
                          'assets/compass.png', // Add a compass image with N, NE, E, etc.
                          width: 200,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Static Arrow (Fixed)
                      Icon(
                        Icons.navigation,
                        size: 60,
                        color: Colors.red,
                      ),

                      // Center Dot
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Speedometer
                Text('Speed: ${_speed.toStringAsFixed(2)} km/h', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                // ODO Meter
                Text('Distance: ${_distance.toStringAsFixed(2)} km', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                // Compass Heading and Direction
                Text('Compass: ${_heading.toStringAsFixed(2)}°', style: TextStyle(fontSize: 24)),
                SizedBox(height: 10),
                Text('Direction: $_direction', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                // Current Time
                Text('Time: ${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}', style: TextStyle(fontSize: 24)),
                SizedBox(height: 20),
                // Alarm Button
                ElevatedButton(
                  onPressed: _setAlarm,
                  child: Text('Set Alarm'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
