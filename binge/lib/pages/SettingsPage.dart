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
  String _originalUsername = '';
  TextEditingController _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  void _loadUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      var userData = snapshot.data() as Map<String, dynamic>;
      _originalUsername = userData['username'] ?? user.email;
      _usernameController.text = _originalUsername;
      setState(() {}); // Ensure the UI is updated after loading the username
    }
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditingUsername) {
        // Save the new username
        _saveUsername();
      } else {
        _isEditingUsername = true;
      }
    });
  }

  void _saveUsername() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'username': _usernameController.text.trim(),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Username updated successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating username. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      });
    }
    setState(() {
      _isEditingUsername = false; // Exit edit mode after saving
    });
  }

  void _cancelEdit() {
    setState(() {
      _usernameController.text =
          _originalUsername; // Revert to original username
      _isEditingUsername = false; // Exit edit mode
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final Color buttonColor = Color(0xFF9166FF);

    final Gradient backgroundGradient = isDarkMode
        ? LinearGradient(
            colors: [Colors.black, buttonColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [Colors.white, buttonColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: backgroundGradient,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        "Settings",
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 40),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.0),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Color(0xFF1E1E1E)
                                    : Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Color(0xFF282828)
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: TextField(
                                controller: _usernameController,
                                enabled: _isEditingUsername,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Username",
                                  hintStyle:
                                      TextStyle(color: secondaryTextColor),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 16.0),
                                ),
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          if (_isEditingUsername)
                            IconButton(
                              icon: Icon(
                                Icons.cancel,
                                color: buttonColor,
                              ),
                              onPressed: _cancelEdit,
                            ),
                          IconButton(
                            icon: Icon(
                              _isEditingUsername ? Icons.check : Icons.edit,
                              color: buttonColor,
                            ),
                            onPressed: _toggleEditMode,
                          ),
                        ],
                      ),
                      if (_isEditingUsername) SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: ElevatedButton.icon(
                onPressed: () async {
                  try {
                    await _auth.signOut();
                    Navigator.pushReplacementNamed(context, Routes.splash);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error signing out. Please try again.',
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: Icon(Icons.logout, color: primaryTextColor),
                label: Text(
                  'Logout',
                  style: TextStyle(color: primaryTextColor),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
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
