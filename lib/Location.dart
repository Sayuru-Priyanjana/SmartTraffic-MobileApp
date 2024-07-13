import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'Homepage.dart';
import 'package:fl_chart/fl_chart.dart';

class LocationDetailPage extends StatefulWidget {
  final Location location;
  const LocationDetailPage({super.key, required this.location});

  @override
  State<LocationDetailPage> createState() => _LocationDetailPageState();
}

class _LocationDetailPageState extends State<LocationDetailPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String selectedDateTime = "";
  String current_incoming = "Loading...";
  String current_outgoing = "Loading...";

  // Initial Selected Value
  String dropdownvalue = 'day1';

  // List of items in our dropdown menu
  var items = ["day1", "day2", "day3", "day4", "day5", "day6", "day7"];

  List<TableData> table1 = [];
  List<FlSpot> chartDataIncoming = [];
  List<FlSpot> chartDataOutgoing = [];

  @override
  void initState() {
    super.initState();
    _fetchInitialData();
    _setupRealtimeListener();
    fetchTable1();
  }

  Future<void> _fetchInitialData() async {
    final snapshot = await _database
        .child('Traffic_Data/${widget.location.title}/Current')
        .get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      setState(() {
        current_incoming = data['incoming_vehicles'].toString();
        current_outgoing = data['outgoing_vehicles'].toString();
        selectedDateTime = "Live";
      });
    }
  }

  void _setupRealtimeListener() {
    _database
        .child('Traffic_Data/${widget.location.title}/Current')
        .onValue
        .listen((event) {
      final data = event.snapshot.value as Map;
      setState(() {
        current_incoming = data['incoming_vehicles'].toString();
        current_outgoing = data['outgoing_vehicles'].toString();
      });
    });
  }

  Future<void> fetchTable1() async {
    final userRef =
        _database.child('Traffic_Data/${widget.location.title}/$dropdownvalue');
    final DataSnapshot snapshot = await userRef.get();
    table1.clear();

    if (snapshot.exists) {
      Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;

      data.forEach((key, value) {
        DateTime dateTime = DateTime.parse(key.toString());
        String time = DateFormat.Hm().format(dateTime);

        TableData tabledata = TableData(
          incoming: value['incoming_vehicles'].toString(),
          outgoing: value['outgoing_vehicles'].toString(),
          time: time,
        );

        table1.add(tabledata);
      });

      // Sort table1 by time
      table1.sort((a, b) => a.time.compareTo(b.time));

      // Generate chart data
      chartDataIncoming = List.generate(table1.length, (index) {
        return FlSpot(index.toDouble(), double.parse(table1[index].incoming));
      });

      chartDataOutgoing = List.generate(table1.length, (index) {
        return FlSpot(index.toDouble(), double.parse(table1[index].outgoing));
      });

      setState(() {
        table1 = table1; // Update the state with sorted data
      });
    } else {
      print('No data available for this user.');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.location.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Longitude and latitude container
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromARGB(255, 140, 140, 140),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Lng : ${widget.location.position.longitude}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "Lat : ${widget.location.position.latitude}",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Current incoming and outgoing
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Incoming : $current_incoming",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 20),
                          Text(
                            "Outgoing : $current_outgoing",
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Image of Location
            Container(),

            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Dropdownmenu for Select Day
                Container(
              margin: EdgeInsets.only(left: 10),height: 40,width: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Color.fromARGB(255, 64, 182, 127)
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton(
                  // Initial Value
                  value: dropdownvalue,
                  // Down Arrow Icon
                  icon: const Icon(Icons.keyboard_arrow_down),
                  // Array list of items
                  items: items.map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text(items),
                    );
                  }).toList(),
                  // After selecting the desired option,it will
                  // change button value to selected value
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownvalue = newValue!;
                      fetchTable1();
                    });
                  },
                ),
              ),
            ),
                SizedBox(width: 40,),
                Text("Incoming",style: TextStyle(color: Color.fromARGB(255, 1, 92, 177) ,fontWeight: FontWeight.bold),),
                SizedBox(width: 20,),
                Text("Outgoing",style: TextStyle(color: Color.fromARGB(255, 226, 36, 36) ,fontWeight: FontWeight.bold),),

              ],
            ),

            

            // Line chart for incoming and outgoing vehicles
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineChart(
                  LineChartData(
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: chartDataIncoming,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 1,
                        dotData: FlDotData(show: false),
                      ),
                      LineChartBarData(
                        spots: chartDataOutgoing,
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 1,
                        dotData: FlDotData(show: false),
                      ),
                    ],
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            TextStyle style;
                            if (value > 150) {
                              style = TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10);
                            } else if (value > 100) {
                              style = TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10);
                            } else if (value > 80) {
                              style = TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10);
                            } else if (value > 50) {
                              style = TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10);
                            } else {
                              style = TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10);
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child:
                                  Text(value.toInt().toString(), style: style),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: false), // Hide right axis data
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            const style = TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            );
                            Widget text;
                            if (value.toInt() < table1.length) {
                              text = Text(table1[value.toInt()].time,
                                  style: style);
                            } else {
                              text = const Text('', style: style);
                            }
                            return SideTitleWidget(
                              axisSide: meta.axisSide,
                              space: 4,
                              child: text,
                            );
                          },
                        ),
                      ),
                      topTitles: AxisTitles(
                          sideTitles: SideTitles(
                              showTitles: false)), // Hide top axis data
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TableData {
  String incoming;
  String outgoing;
  String time;

  TableData(
      {required this.incoming, required this.outgoing, required this.time});
}
