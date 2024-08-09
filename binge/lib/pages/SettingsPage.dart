import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:binge/routes/routes.dart';

class SettingsPage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Settings Page'),
      ),
      body: Center(
        child: user != null
            ? FutureBuilder<DocumentSnapshot>(
                future: _firestore.collection('users').doc(user.uid).get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasError) {
                    return Text('Error fetching user data.');
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('No user data available.');
                  }
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Username: ${userData['username'] ?? user.email}'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await _auth.signOut();
                            Navigator.pushReplacementNamed(
                                context, Routes.splash);
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Error signing out. Please try again.'),
                              ),
                            );
                          }
                        },
                        child: Text('Logout'),
                      ),
                    ],
                  );
                },
              )
            : Text('No user is signed in'),
      ),
    );
  }
}
