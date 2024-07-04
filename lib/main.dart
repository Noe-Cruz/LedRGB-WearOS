import 'package:controlled/firebase_options.dart';
import 'package:controlled/services/notification_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:wear/wear.dart';
import 'dart:async';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initNotifications();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Led',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.compact,
      ),
      home: const WatchScreen(),
    );
  }
}

class WatchScreen extends StatelessWidget {
  const WatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WatchShape(
      builder: (context, shape, child) {
        return AmbientMode(
          builder: (context, mode, child) {
            return LedScreen(mode);
          },
        );
      },
    );
  }
}

class LedScreen extends StatefulWidget {
  
  final WearMode mode;

  const LedScreen(this.mode, {super.key});

  @override
  State<LedScreen> createState() => _LedScreenState();
}

class _LedScreenState extends State<LedScreen> {
  late String _status;
  late String _currentTime;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  late StreamSubscription<DatabaseEvent> _statusSubscription;

  @override
  void initState() {
    _status = "OFF";
    _currentTime = _getCurrentTime();
    _startListeningToStatusChanges();
    super.initState();
  }

  @override
  void dispose() {
    _statusSubscription.cancel();
    super.dispose();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    final hours = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final minutes = now.minute.toString().padLeft(2, '0');
    final period = now.hour >= 12 ? 'pm' : 'am';
    return "$hours:$minutes $period";
  }

  //Actualizazción de claves en Firebase y variables locales
  Future<void> _updateStatus(String status) async {
    try {
      await _database.child('status').set(status);
      await _database.child('color').set(status == "ON" ? "255,255,255" : "0,0,0");
      setState(() {
        _status = status;
      });
    } catch (e) {
      // Handle error
      print('Error updating status: $e');
    }
  }

  //Escucha y actualizazción automatica de claves en Firebase y variables locales
  void _startListeningToStatusChanges() {
    _statusSubscription = _database.child('status').onValue.listen((event) {
      if (event.snapshot.value != null) {
        final newStatus = event.snapshot.value.toString();
        if (newStatus != _status) {
          showNotification(newStatus);
          setState(() {
            _status = newStatus;
          });
        }
      } else {
        print('Status is null');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Colors.black,
      body: SafeArea(
        child: Stack(
          children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _currentTime,
                style: TextStyle(
                  color: widget.mode == WearMode.active
                      ? Colors.white
                      : Colors.white54,
                  fontSize: 13,
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Text(
                    "Control LED",
                    style: TextStyle(
                      color: widget.mode == WearMode.active 
                      ? Colors.white 
                      : Colors.white54,
                      fontSize: 15
                      ),
                    ),
                ),
                const SizedBox(height: 5.0),
                Center(
                  child: Icon( 
                    _status == "ON"
                    ? Icons.light_mode
                    : Icons.light_mode_outlined, 
                    size: 60,
                    color:Colors.white,
                    ),
                ),
                _buildWidgetButton(),
                ],
              ),
            ),
          ]
        )
      ),
    );
  }

  Widget _buildWidgetButton() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        ElevatedButton(
          onPressed: () {
              showNotification("ON");
              _updateStatus("ON");
          },
          style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: widget.mode == WearMode.active
                  ? const Color.fromRGBO(88, 201, 88, 1)
                  : const Color.fromARGB(62, 88, 201, 88)
            ),
            child: const Icon(
                Icons.power_settings_new, 
                size: 24,
                color: Colors.black,
              ),
        ),
        ElevatedButton(
          onPressed: () {
            showNotification("OFF");
            _updateStatus("OFF");
          },
          style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(16),
              backgroundColor: widget.mode == WearMode.active
                  ? const Color.fromARGB(255, 201, 88, 88)
                  : const Color.fromARGB(75, 201, 88, 88)
            ),
            child: const Icon(
                Icons.power_settings_new, 
                size: 24,
                color: Colors.black,
              ),
        ),
      ],
    );
  }
}