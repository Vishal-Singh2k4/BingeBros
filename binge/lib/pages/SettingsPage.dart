import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:binge/routes/routes.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isEditingUsername = false;
  TextEditingController _usernameController = TextEditingController();

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
                  _usernameController.text = userData['username'] ?? user.email;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _usernameController,
                                // decoration:
                                //     InputDecoration(labelText: 'Username'),
                                enabled: _isEditingUsername,
                              ),
                            ),
                            IconButton(
                              icon: Icon(_isEditingUsername
                                  ? Icons.check
                                  : Icons.edit),
                              onPressed: () {
                                setState(() {
                                  _isEditingUsername = !_isEditingUsername;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      if (_isEditingUsername) ...[
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                try {
                                  await _firestore
                                      .collection('users')
                                      .doc(user.uid)
                                      .update({
                                    'username':
                                        _usernameController.text.trim(),
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Username updated successfully!'),
                                    ),
                                  );
                                  setState(() {
                                    _isEditingUsername = false;
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Error updating username. Please try again.'),
                                    ),
                                  );
                                }
                              },
                              child: Text('Update Username'),
                            ),
                            SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditingUsername = false;
                                  _usernameController.text =
                                      userData['username'] ??
                                          user.email; // Reset to original value
                                });
                              },
                              child: Text('Cancel'),
                              // style: ElevatedButton.styleFrom(
                              //     backgroundColor: Color.fromARGB(255, 74, 143, 204)),
                            ),
                          ],
                        ),
                      ],
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
