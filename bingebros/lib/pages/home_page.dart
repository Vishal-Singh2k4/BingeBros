import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await _auth.signOut();
                // Navigate to sign-in page after successful sign-out
                Navigator.pushReplacementNamed(context, '/');
              } catch (e) {
                // Handle any errors that occur during sign-out
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error signing out. Please try again.'),
                  ),
                );
              }
            },
          ),
        ],
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
                    return Text('Error fetching username.');
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return Text('No username set.');
                  }
                  var userData = snapshot.data!.data() as Map<String, dynamic>;
                  return Text('Welcome, ${userData['username'] ?? user.email}');
                },
              )
            : Text('No user is signed in'),
      ),
    );
  }
}
