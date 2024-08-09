import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:binge/routes/routes.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final TextEditingController phoneController = TextEditingController();
  PhoneNumber phoneNumber = PhoneNumber(isoCode: 'IN'); // Default country code

  Future<void> _googleSignInFunction() async {
    try {
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (userCredential.additionalUserInfo!.isNewUser) {
          Navigator.pushReplacementNamed(context, Routes.usernameSetup);
        } else {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _sendPhoneNumberVerification() {
    final phoneNumberStr = phoneNumber.phoneNumber ?? '';
    // Print phone number for debugging
    print("Phone Number with country code: $phoneNumberStr");

    // Validate phone number
    if (phoneNumberStr.isEmpty) {
      _showError("Phone number cannot be empty.");
      return;
    }

    // Validate phone number format
    final RegExp phoneRegExp = RegExp(r'^\+?\d{10,15}$');
    if (!phoneRegExp.hasMatch(phoneNumberStr)) {
      _showError("Invalid phone number format.");
      return;
    }

    Navigator.pushNamed(
      context,
      Routes.verify,
      arguments: phoneNumberStr,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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
            colors: [
              Colors.black,
              buttonColor
            ], // Dark mode: black to primary color
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : LinearGradient(
            colors: [
              Colors.white,
              buttonColor
            ], // Light mode: white to primary color
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
                SizedBox(height: 20),
                Text(
                  "Welcome Back!",
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Sign in to continue",
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 16,
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
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        phoneNumber = number;
                      });
                    },
                    initialValue: phoneNumber,
                    textFieldController: phoneController,
                    formatInput: false,
                    inputDecoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Phone Number",
                      hintStyle: TextStyle(color: secondaryTextColor),
                      contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    selectorConfig: SelectorConfig(
                      selectorType: PhoneInputSelectorType.DIALOG,
                      showFlags: true,
                      setSelectorButtonAsPrefixIcon: true,
                      trailingSpace: false,
                    ),
                    selectorTextStyle: TextStyle(
                      color: primaryTextColor,
                    ),
                    cursorColor: buttonColor,
                    textStyle: TextStyle(
                      color: primaryTextColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _sendPhoneNumberVerification,
                  child: Text(
                    "Send Verification Code",
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
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: secondaryTextColor,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "or sign in with",
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: secondaryTextColor,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _googleSignInFunction,
                  icon: Image.asset(
                    'assets/google_logo.png',
                    height: 24.0,
                    width: 24.0,
                  ),
                  label: Text('Sign in with Google'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    side: BorderSide(
                        color:
                            isDarkMode ? Color(0xFF282828) : Colors.grey[300]!),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
