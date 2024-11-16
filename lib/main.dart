import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:location_permission/app_button.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Current location Data',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> locationRequests = [];
  Timer? _timer;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadLocationRequests();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // appBar: AppBar(
      //   title: const Text("Test App"),
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.black.withOpacity(0.8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _getTestAppText(context),
                  if (screenWidth > 450)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _getRequestLocationPermissionButton(context)),
                            const SizedBox(width: 30,),
                            Expanded(child: _getRequestNotificationPermissionButton(context)),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: _getStartLocationPermissionButton(context)),
                            const SizedBox(width: 30,),
                            Expanded(child: _getStopLocationPermissionButton(context)),
                          ],
                        )
                      ],
                    )
                  else
                    Column(
                      children: [
                        _getRequestLocationPermissionButton(context),
                        const SizedBox(
                          height: 20,
                        ),
                        _getRequestNotificationPermissionButton(context),
                        const SizedBox(
                          height: 20,
                        ),
                        _getStartLocationPermissionButton(context),
                        const SizedBox(
                          height: 20,
                        ),
                        _getStopLocationPermissionButton(context),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    )
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _getCurrentLocationDetails(context),
        ],
      ),
    );
  }

  Widget _getTestAppText(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 30, bottom: 20),
      child: Text(
        "Test App",
        style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _getRequestLocationPermissionButton(BuildContext context) {
    return AppButton(
      height: 50,
      onTap: () {
        _requestLocationPermission(context);
      },
      label: "Request Location Permission",
      labelColor: Colors.white,
      color: Colors.blue,
    );
  }

  Widget _getRequestNotificationPermissionButton(BuildContext context) {
    return AppButton(
        label: "Request Notification Permission",
        labelColor: Colors.black,
        color: Colors.yellow,
        onTap: () {
          _requestNotificationPermission(context);
        });
  }

  Widget _getStartLocationPermissionButton(BuildContext context) {
    return AppButton(
      label: "Start Location Update",
      color: Colors.green,
      labelColor: Colors.white,
      onTap: () {
        _startLocationUpdates();
      },
    );
  }

  Widget _getStopLocationPermissionButton(BuildContext context) {
    return AppButton(
      label: "Stop Location Update",
      color: Colors.red,
      labelColor: Colors.white,
      onTap: () {
        _stopLocationUpdates();
        _saveLocationRequests();
      },
    );
  }

  Widget _getCurrentLocationDetails(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 450;

          return Padding(
            padding: const EdgeInsets.only(top: 10),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    isWideScreen ? 2 : 1,
                mainAxisSpacing: 20,
                crossAxisSpacing: 30,
                childAspectRatio: 4,
              ),
              itemCount: locationRequests.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final request = locationRequests[index];
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Request${request['id']}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _getLatitudeData(request['lat']),
                          _getLongitudeData(request['lng']),
                          _getSpeedData(request['speed']),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _getLatitudeData(String latitude) {
    return Row(
      children: [
        const Text(" Lat: ", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(latitude),
      ],
    );
  }

  Widget _getLongitudeData(String longitude) {
    return Row(
      children: [
        const Text("Lng: ", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(longitude),
      ],
    );
  }

  Widget _getSpeedData(String speed) {
    return Row(
      children: [
        const Text("Speed: ", style: TextStyle(fontWeight: FontWeight.bold)),
        Text(speed),
      ],
    );
  }

  ///location permission
  Future<void> _requestLocationPermission(BuildContext context) async {
    var status = await Permission.location.request();
    if (await Permission.location.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Permission already granted"),
      ));
      return;
    }

    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Location permission granted"),
      ));
    } else if (status.isDenied) {
      openAppSettings();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Location permission denied"),
      ));
    }
  }

  ///After tapping stop location all the current location will be saved
  Future<void> _saveLocationRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(locationRequests);
    await prefs.setString('location_requests', jsonString);
    debugPrint(jsonString);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location requests saved!")),
    );
  }

  ///Saved current location data
  Future<void> _loadLocationRequests() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString('location_requests');
    if (jsonString != null) {
      setState(() {
        locationRequests =
            List<Map<String, dynamic>>.from(jsonDecode(jsonString));
      });
    }
    debugPrint("$locationRequests");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location requests loaded!")),
    );
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  ///Notification alert
  Future<void> _showNotification(String title, String message) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'location_channel',
      'Location Updates',
      channelDescription: 'Channel for location updates',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      message,
      platformDetails,
    );
  }

  ///Notification permission
  Future<void> _requestNotificationPermission(BuildContext context) async {
    if (await Permission.notification.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Notification permission is already granted."),
      ));
      return;
    }

    PermissionStatus status = await Permission.notification.request();
    if (status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Notification permission granted."),
      ));
    } else if (status.isDenied || status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content:
            Text("Notification permission denied. Opening app settings..."),
      ));
      await openAppSettings();
    }
  }

  ///start location update button
  Future<void> _startLocationUpdates() async {
    await _showNotification(
        "Location Update", "Location updates have started.");
    if (await Permission.location.isGranted) {
      int id = 0;
      _timer = Timer.periodic(const Duration(seconds: 30), (timer) async {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best,
        );

        setState(() {
          id = locationRequests.length + 1;
          locationRequests.add({
            'id': id,
            'lat': position.latitude.toStringAsFixed(6),
            'lng': position.longitude.toStringAsFixed(6),
            'speed': position.speed.toStringAsFixed(2),
          });
        });
      });
    }
  }

  ///After stop location update button
  Future<void> _stopLocationUpdates() async {
    _timer?.cancel();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Location updates stopped")),
    );
    await _showNotification(
        "Location Update", "Location updates have stopped.");
  }
}
