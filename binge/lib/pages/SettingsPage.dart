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
  String _authProvider = ''; // Variable to hold the auth provider info
  String _authInfo = ''; // Variable to hold the auth info (phone or email)

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

      // Determine the authentication provider and relevant info
      if (user.providerData.isNotEmpty) {
        var provider = user.providerData.first.providerId;
        if (provider == 'google.com') {
          _authProvider = 'Google Account';
          _authInfo = user.email ?? 'No email';
        } else if (provider == 'phone') {
          _authProvider = 'Phone Number';
          _authInfo = user.phoneNumber ?? 'No phone number';
        } else {
          _authProvider = 'Other';
          _authInfo = 'N/A';
        }
      }

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

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                _startAccountDeletion();
              },
            ),
          ],
        );
      },
    );
  }

  void _startAccountDeletion() {
    // Show a loading indicator or message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Account deletion will start in 5 seconds.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.orange,
      ),
    );

    // Delay for 5 seconds before deleting the account
    Future.delayed(Duration(seconds: 5), () {
      _deleteAccount();
    });
  }

  void _deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Delete Firestore document
        await _firestore.collection('users').doc(user.uid).delete();

        // Delete Firebase Auth account
        await user.delete();

        // Navigate to splash or login screen
        Navigator.pushReplacementNamed(context, Routes.splash);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error deleting account. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final Color buttonColor = Color(0xFF9166FF);
    final Color subtleTextColor = isDarkMode ? Colors.grey[600]! : Colors.grey[500]!;

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
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 40), // Space from the top
            Text(
              "Settings",
              style: TextStyle(
                color: primaryTextColor,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildUsernameSection(primaryTextColor, secondaryTextColor, buttonColor),
                    SizedBox(height: 40),
                    _buildAuthProviderSection(subtleTextColor),
                    SizedBox(height: 40), // Space before the logout button
                    _buildLogoutButton(primaryTextColor, buttonColor),
                    SizedBox(height: 20), // Space before the delete account button
                    _buildDeleteAccountButton(primaryTextColor, buttonColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsernameSection(Color primaryTextColor, Color secondaryTextColor, Color buttonColor) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Color(0xFF282828) : Colors.grey[300]!,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _usernameController,
              enabled: _isEditingUsername,
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
          if (_isEditingUsername)
            IconButton(
              icon: Icon(
                Icons.cancel,
                color: Color(0xFFB71C1C),
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
    );
  }

  Widget _buildAuthProviderSection(Color subtleTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Auth Provider: $_authProvider",
          style: TextStyle(
            color: subtleTextColor,
            fontSize: 16,
          ),
        ),
        SizedBox(height: 8),
        Text(
          "Account info: $_authInfo",
          style: TextStyle(
            color: subtleTextColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(Color primaryTextColor, Color buttonColor) {
    return ElevatedButton(
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
      style: ElevatedButton.styleFrom(
        backgroundColor: buttonColor,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        'Logout',
        style: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(Color primaryTextColor, Color buttonColor) {
    return ElevatedButton(
      onPressed: _showDeleteAccountDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
      child: Text(
        'Delete Account',
        style: TextStyle(
          color: primaryTextColor,
          fontSize: 16,
        ),
      ),
    );
  }
}
