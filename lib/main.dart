import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:homofix_expert/Login/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'New_Booking/newBookingOrderlist.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Add this line
  AndroidInitializationSettings androidSetting =
      const AndroidInitializationSettings("@mipmap/ic_launcher");
  DarwinInitializationSettings iosSetting = const DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestCriticalPermission: true,
      requestSoundPermission: true);

  InitializationSettings initializationSettings = InitializationSettings(
    android: androidSetting,
    iOS: iosSetting,
  );
  bool? initialized = await flutterLocalNotificationsPlugin.initialize(
      initializationSettings, onDidReceiveNotificationResponse: (response) {
    log(response.payload.toString());
    // if (response.payload != null) {
    //   int bookingId = int.parse(response.payload.toString());
    // Navigate to the OrderScreen with the bookingId
    Navigator.push(
      GlobalKey<NavigatorState>().currentState!.context,
      MaterialPageRoute(
        builder: (context) => ProductScreenView(
          expertId: '',
          expertname: '',
        ),
      ),
    );
    //  }
  });
  log("Notification: $initialized");
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Timer? newBookingTimer;
  BuildContext? appContext;
  void startNewBookingTimer() {
    newBookingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkForNewBooking();
      print("__________________Hello__");
    });
  }

  void stopNewBookingTimer() {
    newBookingTimer?.cancel();
  }

  void getCurruntPosition() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      //    print("Permission not given");
      LocationPermission asked = await Geolocator.requestPermission();
    } else {
      Position curruntPossition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );
      setState(() {});

      List<Placemark> placemarks = await placemarkFromCoordinates(
        curruntPossition.latitude,
        curruntPossition.longitude,
      );
      Placemark placemark = placemarks.first;
      String address =
          '${placemark.name}, ${placemark.street}, ${placemark.subLocality}, ${placemark.locality}, ${placemark.administrativeArea}, ${placemark.postalCode}, ${placemark.country}';
      // print(address);
    }
  }

  int previousBookingId = -1;
  void checkForNewBooking() async {
    final prefs = await SharedPreferences.getInstance();
    final idS = prefs.getString('id');

    final response = await http.get(Uri.parse(
        'https://support.homofixcompany.com/api/Task/?technician_id=$idS'));

    if (response.statusCode == 200) {
      final bookings = jsonDecode(response.body) as List<dynamic>;
      final latestBooking = bookings.last;

      if (latestBooking['id'] != previousBookingId) {
        showNotification();

        previousBookingId = latestBooking['id'];
      }
    } else {
      throw Exception('Failed to load API');
    }
  }

  void showNotification() async {
    AndroidNotificationDetails androidDetails =
        const AndroidNotificationDetails(
            "Homofix Company", "You have new task assign",
            priority: Priority.high,
            importance: Importance.max,
            colorized: true);
    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    NotificationDetails notiDetails =
        NotificationDetails(android: androidDetails, iOS: iosDetails);
    await flutterLocalNotificationsPlugin.show(
      1,
      "Homofix",
      "You have new task assign",
      notiDetails,
      payload: previousBookingId.toString(),
    );
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    getCurruntPosition();
    startNewBookingTimer();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    stopNewBookingTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      stopNewBookingTimer();
    } else if (state == AppLifecycleState.resumed) {
      checkForNewBooking();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
            color: Colors.white,
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.white)),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Colors.black,
        ),
        brightness: Brightness.light,
        primarySwatch: const MaterialColor(
          0xffFFFFFF,
          {
            50: Color(0xffFFFFFF),
            100: Color(0xffFFFFFF),
            200: Color(0xffFFFFFF),
            300: Color(0xffFFFFFF),
            400: Color(0xffFFFFFF),
            500: Color(0xffFFFFFF),
            600: Color(0xffFFFFFF),
            700: Color(0xffFFFFFF),
            800: Color(0xffFFFFFF),
            900: Color(0xffFFFFFF),
          },
        ),
      ),
      home: const Login(),
    );
  }
}
