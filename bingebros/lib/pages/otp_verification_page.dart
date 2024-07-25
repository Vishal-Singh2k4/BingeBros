import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'username_setup_page.dart';
import 'home_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String verificationId;
  final String phoneNumber;

  OtpVerificationPage({
    required this.verificationId,
    required this.phoneNumber,
  });

  @override
  _OtpVerificationPageState createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _smsCode = '';

  void _signInWithPhoneNumber() async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: _smsCode,
      );

      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        if (user.metadata.creationTime == user.metadata.lastSignInTime) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => UsernameSetupPage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (e) {
      print(e.toString());
      // Handle exceptions (e.g., show an error message to the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter OTP'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Enter OTP',
              ),
              onChanged: (value) {
                setState(() {
                  _smsCode = value;
                });
              },
            ),
            ElevatedButton(
              onPressed: _signInWithPhoneNumber,
              child: Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
