import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:binge/routes/routes.dart';
import 'avatar.dart'; // Import the AvatarSelectionModal

class UsernameSetupPage extends StatefulWidget {
  @override
  _UsernameSetupPageState createState() => _UsernameSetupPageState();
}

class _UsernameSetupPageState extends State<UsernameSetupPage> {
  final TextEditingController usernameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String errorMessage = '';
  bool isLoading = false;
  String selectedAvatar = 'assets/avatar4.png'; // Default avatar

  Future<void> saveUsername() async {
    setState(() {
      errorMessage = '';
      isLoading = true;
    });

    if (usernameController.text.isEmpty) {
      setState(() {
        errorMessage = 'Username cannot be empty.';
        isLoading = false;
      });
      return;
    }

    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'username': usernameController.text,
          'avatar': selectedAvatar,
        }, SetOptions(merge: true));

        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
        isLoading = false;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _openAvatarSelectionModal() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AvatarSelectionModal(
          selectedAvatar: selectedAvatar,
          onAvatarSelected: (avatar) {
            setState(() {
              selectedAvatar = avatar;
            });
          },
        );
      },
    );
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
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Complete Your Profile",
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                GestureDetector(
                  onTap: _openAvatarSelectionModal,
                  child: CircleAvatar(
                    radius: 70, // Increased size
                    backgroundColor: Colors.transparent,
                    child: ClipOval(
                      child: Image.asset(
                        selectedAvatar,
                        fit: BoxFit.cover,
                        height: 140,
                        width: 140,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10), // Added space between avatar and text
                Text(
                  "Tap to change avatar",
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 40),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color:
                            isDarkMode ? Color(0xFF282828) : Colors.grey[300]!),
                  ),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Username",
                      hintStyle: TextStyle(color: secondaryTextColor),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: isLoading ? null : saveUsername,
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: primaryTextColor,
                        )
                      : Text(
                          "Save",
                          style: TextStyle(
                            color: primaryTextColor,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                if (errorMessage.isNotEmpty)
                  Text(
                    errorMessage,
                    style: TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
