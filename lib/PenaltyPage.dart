import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class PenaltyPage extends StatefulWidget {
  final String username;

  const PenaltyPage({super.key, required this.username});

  @override
  State<PenaltyPage> createState() => _PenaltyPageState();
}

class _PenaltyPageState extends State<PenaltyPage> {
  //final DatabaseReference _database = FirebaseDatabase.instance.reference().child('Penalty');
  final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Penalty');
  List<DataRow> _penaltyRows = [];
  double _totalPenalty = 0;
  int _remainingCases = 0;

  @override
  void initState() {
    super.initState();
    _fetchPenaltyData();
   
  }

Future<void> _fetchPenaltyData() async {
   print(widget.username);
  final userRef = _database.child(widget.username);
  final DataSnapshot snapshot = await userRef.get();

  if (snapshot.exists) {
    Map<dynamic, dynamic> data = snapshot.value as Map<dynamic, dynamic>;
    List<DataRow> rows = [];
    double totalPenalty = 0;
    int remainingCases=0;

    data.forEach((key, value) {
      rows.add(
        DataRow(
          cells: [
            DataCell(Text(value['date_time'])),
            DataCell(Text(value['type'])),
            DataCell(Text(value['location'])),
            DataCell(Text('Rs ${value['penalty']}')),
          ],
        ),
      );
      totalPenalty += value['penalty'];
      remainingCases = remainingCases+1;
    });

    setState(() {
      _penaltyRows = rows;
      _totalPenalty = totalPenalty;
      _remainingCases = remainingCases;
    });
  } else {
    print('No data available for this user.');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Penalty Data'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 152, 227, 171),
                borderRadius: BorderRadius.circular(8),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(11.0),
                child: Center(
                  child: Text(
                    "${widget.username} Penalty Data",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: double.infinity,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color.fromARGB(255, 163, 209, 174),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text(
                            "Total Penalty:",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 50),
                        Text(
                          "Rs $_totalPenalty",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500,color: Colors.black),
                        ),
                      ],
                    ),

                    const SizedBox(height: 1),
                    
                    Padding(
                      padding: const EdgeInsets.only(bottom: 0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(left: 20),
                            child: Text(
                              "Total Cases:",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(width: 50),
                          Text(
                            "  $_remainingCases",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),




                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text(
              "Your Penalties",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ),
          const SizedBox(height: 0),
          Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Container(
              width: double.infinity,
              height: 400,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 226, 223, 231),
                borderRadius: BorderRadius.circular(5),
              ),
              child: DataTable(
                columnSpacing: 12.0,
                columns: [
                  const DataColumn(
                    label: Expanded(
                      child: Text(
                        'DateTime',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  const DataColumn(
                    label: Expanded(
                      child: Text(
                        'Type',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  const DataColumn(
                    label: Expanded(
                      child: Text(
                        'Location',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                  const DataColumn(
                    label: Expanded(
                      child: Text(
                        'Penalty',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  ),
                ],
                rows: _penaltyRows,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
