import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailVerificationPage extends StatefulWidget {
  @override
  _EmailVerificationPageState createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = '';

  Future<void> checkEmailVerified() async {
    User? user = _auth.currentUser;
    await user?.reload();
    if (user != null && user.emailVerified) {
      Navigator.pushReplacementNamed(context, '/usernameSetup');
    } else {
      setState(() {
        errorMessage = 'Email is not verified yet. Please check your inbox.';
      });
    }
  }

  Future<void> resendVerificationEmail() async {
    User? user = _auth.currentUser;
    try {
      await user?.sendEmailVerification();
      setState(() {
        errorMessage =
            'Verification email sent again. Please check your inbox.';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'An error occurred. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Email'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: checkEmailVerified,
              child: Text('I have verified my email'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: resendVerificationEmail,
              child: Text('Resend Verification Email'),
            ),
            SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
