import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:traffic_analysis/Homepage.dart';
import 'package:traffic_analysis/LoginPage.dart';
import 'package:traffic_analysis/PenaltyPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';





class Wellcome extends StatefulWidget {
  final String username;
  const Wellcome({super.key, required this.username});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<Wellcome> {
  late String _timeString;
  late String greeting;
  late String day;
    final DatabaseReference _database = FirebaseDatabase.instance.ref().child('Penalty');
  List<DataRow> _penaltyRows = [];
  double _totalPenalty = 0;
  int _remainingCases = 0;


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


  // String key = 'c43d638dfd66fcd72f8030b298ddabc2469fd8e9';
  // AirQuality airQuality = new AirQuality(key);


  @override
  void initState() {
    super.initState();
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(const Duration(seconds: 1), (Timer t) => _getTime());
    greeting = _getGreeting(DateTime.now());
    day = DateFormat('EEEE').format(DateTime.now());
    _fetchPenaltyData();
  }

  void _getTime() {
    final String formattedDateTime = _formatDateTime(DateTime.now());
    setState(() {
      _timeString = formattedDateTime;
      greeting=_getGreeting(DateTime.now());
    });
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('h:mm:ss a').format(dateTime);
  }


    String _getGreeting(DateTime dateTime) {
    int hour = dateTime.hour;
    if (hour < 12) {
      return 'Good Morning!';
    } else if (hour < 17) {
      return 'Good Afternoon!';
    } else {
      return 'Good Evening!';
    }
  }


    

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              'assets/blue.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child:  Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Center(
                                child: Text(
                                  _timeString,
                                                        
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
          
                        child: Image.asset('assets/night.png' ,height: 80,),

                      ),
                    ],
                  ),


                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child:   Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                           Text( 
                          '      Hello ${widget.username},',
                          style: const TextStyle(
                            fontSize: 18,fontWeight: FontWeight.w500
                          ),
                        ),

                        
                      ],
                    ),
                  ),




                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            greeting,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,color:Color.fromARGB(255, 59, 57, 57)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 50),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'You are in,',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8,),
                          Center(
                            child: Text(
                              'PADAVIYA',
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                                fontWeight: FontWeight.w800
                              ),
                            ),
                          ),
                        
                        
                      ],
                    ),
                  ),




                   const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.7),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child:  const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        
                          
                        
                           Center(
                             child: Text(
                              '  Air Index : Good',
                              style: TextStyle(
                                fontSize: 17,
                                color: Color.fromARGB(234, 72, 67, 67),
                                fontWeight: FontWeight.w500
                              ),
                                                       ),
                           ),
                        
                        
                      ],
                    ),
                  ),


                 
                 
                 Column(
                    children: [
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _remainingCases > 0 ? const Color.fromARGB(255, 242, 51, 51) : const Color.fromARGB(255, 58, 195, 108).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_remainingCases > 0) ...[
                              Center(
                                child: Text(
                                  '  Current Penalty : Rs $_totalPenalty',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(234, 231, 225, 225),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Center(
                                child: Text(
                                  '   Penalty Cases :  $_remainingCases',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color.fromARGB(234, 231, 225, 225),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ] else ...[
                              const Center(
                                child: Text(
                                  'No Penalties such a good driver!',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),


                  

                  



                  const SizedBox(height: 20,),





                //Penalty button
                  ElevatedButton(
                      onPressed: () {  
                    
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PenaltyPage(username: widget.username),
                        ),
                      );
                    
                      },
                      child: const Text('Penalty Data',style: TextStyle(color: Colors.black),),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16), backgroundColor: const Color.fromARGB(255, 58, 195, 108).withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                    ),

                     const SizedBox(height: 10,),

                //Penalty button
                  ElevatedButton(
                      onPressed: () {  
                    
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyApp(),
                        ),
                      );
                    
                      },
                      child: const Text('Go to Map',style: TextStyle(color: Colors.black),),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16), backgroundColor: const Color.fromARGB(255, 58, 195, 108).withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                      ),
                    ),
                  
                  


                  



                




                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      margin: const EdgeInsets.only(bottom: 10),
                  
                      child:  ElevatedButton(
                      onPressed: () {  
                    
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LoginPage(),
                        ),
                      );
                    
                      },
                      child: const Text('Logout',style: TextStyle(color: Colors.black , fontSize: 14),),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16), backgroundColor: const Color.fromARGB(255, 58, 195, 108).withOpacity(0.8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 8,
                      ),
                    ),
                  
                  
                    ),
                  ),
                ),

                 
                 



                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}