import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:binge/routes/routes.dart';
import 'package:binge/notifiers/category_notifier.dart';
import 'package:provider/provider.dart';

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
  String _authInfo = '';
  String _selectedAvatar = 'assets/default_avatar.png'; // Default avatar

  @override
  void initState() {
    super.initState();
    _loadUserProfile(); // Load both username and avatar
  }

  // Load user profile data (username, avatar, auth provider details)
  void _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot snapshot =
          await _firestore.collection('users').doc(user.uid).get();
      var userData = snapshot.data() as Map<String, dynamic>;
      _originalUsername = userData['username'] ?? user.email!;
      _selectedAvatar = userData['avatar'] ?? _selectedAvatar;
      _usernameController.text = _originalUsername;

      // Determine the authentication provider and relevant info
      if (user.providerData.isNotEmpty) {
        var provider = user.providerData.first.providerId;
        if (provider == 'google.com') {
          _authProvider = 'Google Account';
          _authInfo = user.email ?? 'No email associated';
        } else if (provider == 'phone') {
          _authProvider = 'Phone Number';
          _authInfo = user.phoneNumber ?? 'No phone number associated';
        } else {
          _authProvider = 'Other';
          _authInfo = 'N/A';
        }
      }

      setState(() {}); // Ensure the UI is updated after loading the user data
    }
  }

  // Toggle between edit and view mode for the username
  void _toggleEditMode() {
    setState(() {
      if (_isEditingUsername) {
        _saveUserProfile(); // Save changes when exiting edit mode
      } else {
        _isEditingUsername = true;
      }
    });
  }

  // Save updated username and avatar to Firestore
  void _saveUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).update({
        'username': _usernameController.text.trim(),
        'avatar': _selectedAvatar,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Profile updated successfully!',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.green,
          ),
        );
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error updating profile. Please try again.',
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

  // Cancel editing and revert to the original username
  void _cancelEdit() {
    setState(() {
      _usernameController.text =
          _originalUsername; // Revert to original username
      _isEditingUsername = false; // Exit edit mode
    });
  }

  // Show confirmation dialog before account deletion
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Account Deletion'),
          content: Text(
              'Are you sure you want to delete your account? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
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

  // Delay account deletion by 5 seconds with a snackbar warning
  void _startAccountDeletion() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Your account is being deleted.'),
        duration: Duration(seconds: 2),
        backgroundColor: Colors.red,
      ),
    );

    Future.delayed(Duration(seconds: 5), () {
      _deleteAccount();
    });
  }

  // Delete the account and associated Firestore data
  void _deleteAccount() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        await _firestore.collection('users').doc(user.uid).delete();
        await user.delete();
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

  // Show modal for avatar selection
  void _showAvatarSelectionModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return GridView.count(
          crossAxisCount: 3,
          children: List.generate(8, (index) {
            // Add more avatar options as needed
            String avatarPath = 'assets/avatar${index + 1}.png';
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = avatarPath;
                });
                Navigator.pop(context); // Close the modal
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage(avatarPath),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  // Build the widget tree for the settings page UI
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode =
        MediaQuery.of(context).platformBrightness == Brightness.dark;

    final Color primaryTextColor = isDarkMode ? Colors.white : Colors.black;
    final Color secondaryTextColor =
        isDarkMode ? Colors.grey[400]! : Colors.grey[700]!;
    final Color buttonColor = Color(0xFF9166FF);
    final Color subtleTextColor =
        isDarkMode ? Colors.grey[600]! : Colors.grey[500]!;

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
        child: SingleChildScrollView(
          child: Column(
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

              _buildAvatarSection(
                  primaryTextColor, buttonColor), // Avatar section
              SizedBox(height: 20),

              _buildUsernameSection(
                  primaryTextColor, secondaryTextColor, buttonColor),
              SizedBox(height: 20), // Space between username and dropdown

              Divider(height: 40, color: subtleTextColor),

              // Category dropdown section matching _buildAuthProviderSection style
              _buildCategoryDropdown(primaryTextColor, buttonColor),

              Divider(height: 40, color: subtleTextColor),

              _buildAuthProviderSection(primaryTextColor),

              Divider(height: 40, color: subtleTextColor),
              SizedBox(height: 20), // Space before the buttons

              _buildLogoutButton(primaryTextColor, buttonColor),
              SizedBox(height: 10), // Space between buttons

              _buildDeleteAccountButton(primaryTextColor),
              SizedBox(height: 20), // Space from the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Build the username section widget
  Widget _buildUsernameSection(
      Color primaryTextColor, Color secondaryTextColor, Color buttonColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Username",
          style: TextStyle(
            color: secondaryTextColor,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _usernameController,
                readOnly: !_isEditingUsername,
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 18,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 10),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: buttonColor),
                  ),
                ),
              ),
            ),
            SizedBox(width: 10),

            // Cancel (Cross) Button when in edit mode
            if (_isEditingUsername) ...[
              GestureDetector(
                onTap: _cancelEdit,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.cancel,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
              SizedBox(width: 10), // Space between icons
            ],

            // Edit/Check (Tick) Button
            GestureDetector(
              onTap: _toggleEditMode,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: buttonColor,
                child: Icon(
                  _isEditingUsername ? Icons.check : Icons.edit,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build the avatar section widget
  Widget _buildAvatarSection(Color primaryTextColor, Color buttonColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: _showAvatarSelectionModal,
          child: CircleAvatar(
            radius: 50,
            backgroundImage: AssetImage(_selectedAvatar),
            backgroundColor: Colors.grey[300],
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Tap to change avatar",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(Color primaryTextColor, Color buttonColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header for Select Category
        Text(
          "Select Category:",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8), // Space between header and dropdown
        // Container with same width as logout button
        SizedBox(
          width: double.infinity, // Makes the container as wide as the parent
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            decoration: BoxDecoration(
              color: buttonColor, // Box background color
              borderRadius: BorderRadius.circular(8.0), // Rounded corners
            ),
            child: DropdownButton<String>(
              isExpanded: true, // Ensure dropdown takes up full width
              value: Provider.of<CategoryNotifier>(context).selectedCategory,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  Provider.of<CategoryNotifier>(context, listen: false)
                      .setCategory(newValue);
                }
              },
              items: <String>['Games', 'Books', 'Movies', 'Anime']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: TextStyle(color: primaryTextColor),
                  ),
                );
              }).toList(),
              dropdownColor: buttonColor, // Match dropdown background color
              iconEnabledColor: primaryTextColor, // Match icon color
              underline: SizedBox(), // Remove the underline
            ),
          ),
        ),
        SizedBox(height: 16), // Space after dropdown
      ],
    );
  }

  // Build the authentication provider section widget
  Widget _buildAuthProviderSection(Color primaryTextColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Account Details",
          style: TextStyle(
            color: primaryTextColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.security,
              color: primaryTextColor,
              size: 20,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                "Authentication Method: $_authProvider",
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 14,
                ),
                overflow: TextOverflow
                    .ellipsis, // Truncate the text with ellipsis if it overflows
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Row(
          children: [
            Icon(
              Icons.info_outline,
              color: primaryTextColor,
              size: 20,
            ),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                "Account Info: $_authInfo",
                style: TextStyle(
                  color: primaryTextColor,
                  fontSize: 14,
                ),
                overflow: TextOverflow
                    .ellipsis, // Truncate the text with ellipsis if it overflows
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoutButton(Color primaryTextColor, Color buttonColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
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
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteAccountButton(Color primaryTextColor) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _showDeleteAccountDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          padding: EdgeInsets.symmetric(vertical: 16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
        child: Text(
          'Delete Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
