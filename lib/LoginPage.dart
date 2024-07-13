import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:traffic_analysis/Homepage.dart';
import 'package:traffic_analysis/Wellcome.dart';
import 'PenaltyPage.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _controller = TextEditingController();

  void _login() {
    final username = _controller.text.trim().toUpperCase();
    if (username.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Wellcome(username: username)),
      );
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SafeArea(
                  child: Column(
                    children: [
                  
                      

                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Container(
                            
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.6),
                            ),

                            
                          
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                children: [


                                  SizedBox(height: 20,),

                                  Image.asset(
                            'assets/ligicon.png',
                            height: 80,
                            
                          ),
                                            
                          SizedBox(height: 10,),
                              
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10,right: 10),
                                    child: TextField(
                                                        controller: _controller,
                                                        obscureText: false,
                                                        decoration: InputDecoration(
                                                        border: OutlineInputBorder(),
                                                        labelText: 'Username',
                                                        ),
                                                      ),
                                  ),

                                  SizedBox(height: 10),

                                  Padding(
                                    padding: const EdgeInsets.only(left: 10,right: 10),
                                    child: TextField(
                                                        obscureText: true,
                                                        decoration: InputDecoration(
                                                        border: OutlineInputBorder(),
                                                        labelText: 'Password',
                                                        ),
                                                      ),
                                  ),
                          
                          
                                  SizedBox(height: 20),
                                                // Penalty button
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10,right: 10),
                                    child: Container(
                                                        width: double.infinity,
                                                        child: ElevatedButton(
                                                          onPressed: _login,
                                                          child: const Text(
                                                            'Login',
                                                            style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                                                          ),
                                                          style: ElevatedButton.styleFrom(
                                                        padding: const EdgeInsets.all(16),
                                                        backgroundColor: Color.fromARGB(255, 0, 0, 0).withOpacity(0.7),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(16),
                                                        ),
                                                        elevation: 8,
                                                      ),
                                                     ),
                                                  ),
                                  ),
                          
                          
                                                SizedBox(height: 40,),
                          
                          
                          
                              
                              
                                ],
                              ),
                            ),
                          
                          
                          ),
                        ),


                    
                  
                  
                      
                      
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
