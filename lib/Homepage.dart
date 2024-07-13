import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'Location.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Traffic Map',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late GoogleMapController mapController;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final LatLng _center = const LatLng(8.8944804, 80.7807722);

  final List<String> days = [
    "day1",
    "day2",
    "day3",
    "day4",
    "day5",
    "day6",
    "day7"
  ];
  List<String> timeFrames = [];

  String selectedDateTime = "";

  bool Istapped = false;
  late Location selectedLocation;

  List<Location> locations = [
    Location(title: "Location_1", position: LatLng(8.8944804, 80.7807722)),
    Location(title: "Location_2", position: LatLng(8.900000, 80.790000)),
  ];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _listenForUpdates();
    _generateTimeFrames();
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _fetchInitialData() async {
    for (var location in locations) {
      final snapshot =
          await _database.child('Traffic_Data/${location.title}/Current').get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        setState(() {
          location.incoming = data['incoming_vehicles'].toString();
          location.outgoing = data['outgoing_vehicles'].toString();
          selectedDateTime = "Live";
        });
      }
    }
  }

  void _listenForUpdates() {
    for (var location in locations) {
      _database
          .child('Traffic_Data/${location.title}/Current')
          .onValue
          .listen((event) {
        final data = event.snapshot.value as Map;
        setState(() {
          location.incoming = data['incoming_vehicles'].toString();
          location.outgoing = data['outgoing_vehicles'].toString();
          selectedDateTime = "Live";
        });
      });
    }
  }

  void _generateTimeFrames() {
    timeFrames = List<String>.generate(24 * 12, (index) {
      final minutes = (index % 12) * 5;
      final hours = index ~/ 12;
      final time = DateTime(2023, 1, 1, hours, minutes);
      return DateFormat('HH:mm:ss').format(time);
    });
  }

  String _getSelectedDate(String day) {
    DateTime now = DateTime.now();
    DateTime selectedDate;

    switch (day) {
      case 'day1':
        selectedDate = now;
        break;
      case 'day2':
        selectedDate = now.add(Duration(days: 1));
        break;
      case 'day3':
        selectedDate = now.add(Duration(days: 2));
        break;
      case 'day4':
        selectedDate = now.add(Duration(days: 3));
        break;
      case 'day5':
        selectedDate = now.add(Duration(days: 4));
        break;
      case 'day6':
        selectedDate = now.add(Duration(days: 5));
        break;
      case 'day7':
        selectedDate = now.add(Duration(days: 6));
        break;
      default:
        selectedDate = now;
    }

    return DateFormat('yyyy-MM-dd').format(selectedDate);
  }

  void _showDialog(String timestamp) {
    TextEditingController incomingController = TextEditingController();
    TextEditingController outgoingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Update Data for $timestamp"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: incomingController,
                decoration: InputDecoration(labelText: 'Incoming Vehicles'),
              ),
              TextField(
                controller: outgoingController,
                decoration: InputDecoration(labelText: 'Outgoing Vehicles'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _updateDayData(timestamp, incomingController.text,
                    outgoingController.text);
                Navigator.of(context).pop();
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void _updateDayData(String timestamp, String incoming, String outgoing) {
    for (var location in locations) {
      _database.child('Traffic_Data/${location.title}/$timestamp').update({
        'incoming_vehicles': incoming,
        'outgoing_vehicles': outgoing,
      });
    }
  }

  String _setTrafficState(String incoming, String outgoing) {
    String incomingState = "";
    String outgoingState = "";
    double incomingCount = 0;
    double outgoingCount = 0;

    try {
      incomingCount = double.parse(incoming);
      outgoingCount = double.parse(outgoing);
    } catch (e) {
      String incomingState = "";
      String outgoingState = "";
      double incomingCount = 0;
      double outgoingCount = 0;
    }

    if (incomingCount >= 150) {
      incomingState =
          "Very High ${((incomingCount / 150) * 100).toStringAsFixed(0)}%";
    } else if (incomingCount >= 100) {
      incomingState =
          "High ${((incomingCount / 150) * 100).toStringAsFixed(0)}%";
    } else if (incomingCount >= 80) {
      incomingState =
          "Moderate ${((incomingCount / 100) * 100).toStringAsFixed(0)}%";
    } else if (incomingCount >= 50) {
      incomingState = "Low ${((incomingCount / 80) * 100).toStringAsFixed(0)}%";
    } else if (incomingCount >= 0) {
      incomingState =
          "Free ${((incomingCount / 50) * 100).toStringAsFixed(0)}%";
    } else {
      incomingState = "No Data";
    }

    if (outgoingCount >= 150) {
      outgoingState =
          "Very High ${((outgoingCount / 150) * 100).toStringAsFixed(0)}%";
    } else if (outgoingCount >= 100) {
      outgoingState =
          "High ${((outgoingCount / 150) * 100).toStringAsFixed(0)}%";
    } else if (outgoingCount >= 80) {
      outgoingState =
          "Moderate ${((outgoingCount / 100) * 100).toStringAsFixed(0)}%";
    } else if (outgoingCount >= 50) {
      outgoingState = "Low ${((outgoingCount / 80) * 100).toStringAsFixed(0)}%";
    } else if (outgoingCount >= 0) {
      outgoingState =
          "Free ${((outgoingCount / 50) * 100).toStringAsFixed(0)}%";
    } else {
      outgoingState = "No Data";
    }

    return "Incoming:$incomingState Outgoing:$outgoingState";
  }

  void _updateSelectedDateTime(String dateTime) {
    setState(() {
      selectedDateTime = dateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 6, 166, 91),
            ),
            child: Center(
              child: Text(
                'You are now in : $selectedDateTime',
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(151, 0, 0, 0)),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _center,
                zoom: 12.0,
              ),
              markers: locations.map((location) {
                return Marker(
                  markerId: MarkerId(location.title),
                  position: location.position,
                  infoWindow: InfoWindow(
                    title: location.title,
                    snippet:
                        _setTrafficState(location.incoming, location.outgoing),
                    // snippet: "Incoming: ${location.incoming} Outgoing: ${location.outgoing}",
                  ),
                  onTap: () {
                    setState(() {
                      Istapped = true;
                      selectedLocation = location;
                    });
                  },
                );
              }).toSet(),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              _fetchInitialData();
              _listenForUpdates();
            },
            label: Text(
              "Go Live",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 215, 211, 211)),
            ),
            icon: Icon(
              Icons.live_tv,
              color: const Color.fromARGB(255, 215, 211, 211),
            ),
            backgroundColor: Color.fromARGB(255, 33, 47, 32),
            elevation: BitmapDescriptor.hueBlue,
          ),
          SizedBox(
            height: 10,
          ),
          Container(child: () {
            if (Istapped) {
              return FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationDetailPage(location: selectedLocation,),
                    ),
                  );
                },
                label: Text(
                  "${selectedLocation.title}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 215, 211, 211)),
                ),
                icon: Icon(
                  Icons.view_agenda,
                  color: const Color.fromARGB(255, 215, 211, 211),
                ),
                backgroundColor: Color.fromARGB(255, 33, 47, 32),
                elevation: BitmapDescriptor.hueBlue,
              );
            }
          }()),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton.extended(
            onPressed: () {
              _showDaySelectionDialog();
            },
            label: Text(
              "Find Time",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 215, 211, 211)),
            ),
            icon: Icon(
              Icons.search,
              color: const Color.fromARGB(255, 215, 211, 211),
            ),
            backgroundColor: Color.fromARGB(255, 33, 47, 32),
            elevation: BitmapDescriptor.hueBlue,
          ),
        ],
      ),
    );
  }

  void _showDaySelectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Select Day"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: days.map((day) {
              return ListTile(
                title: Text(day),
                onTap: () {
                  Navigator.of(context).pop();
                  _selectTime(day);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _selectTime(String day) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      int roundedMinute = (pickedTime.minute / 5).round() * 5;
      if (roundedMinute == 60) {
        pickedTime = pickedTime.replacing(hour: pickedTime.hour + 1, minute: 0);
      } else {
        pickedTime = pickedTime.replacing(minute: roundedMinute);
      }

      final selectedDate = _getSelectedDate(day);
      final timestamp = '$selectedDate ${pickedTime.format(context)}:00';
      _updateMarkersWithFirebaseData('$day/$timestamp');
      _updateSelectedDateTime(timestamp);
    }
  }

  void _updateMarkersWithFirebaseData(String timestamp) async {
    for (var location in locations) {
      final snapshot = await _database
          .child('Traffic_Data/${location.title}/$timestamp')
          .get();
      if (snapshot.exists) {
        final data = snapshot.value as Map;
        setState(() {
          location.incoming = data['incoming_vehicles'].toString();
          location.outgoing = data['outgoing_vehicles'].toString();
        });
      }
    }
  }
}

class Location {
  final String title;
  final LatLng position;
  String incoming;
  String outgoing;

  Location({
    required this.title,
    required this.position,
    this.incoming = "Loading...",
    this.outgoing = "Loading...",
  });
}
