import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'otp_verification_page.dart';
import 'home_page.dart';
import 'username_setup_page.dart';

class SignInPage extends StatefulWidget {
  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  String _phoneNumber = '+91'; // Default prefix for Indian phone numbers
  String _verificationId = '';
  bool _isPhoneNumberEntered = false;

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
    }
  }

  void _verifyPhoneNumber() async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // This block will not be used since we are using a separate OTP page
        },
        verificationFailed: (FirebaseAuthException e) {
          print(e.message);
          // Handle verification failure (e.g., show an error message to the user)
        },
        codeSent: (String verificationId, int? resendToken) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationPage(
                verificationId: verificationId,
                phoneNumber: _phoneNumber,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      print(e.toString());
      // Handle exceptions (e.g., show an error message to the user)
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isPhoneNumberEntered) ...[
              TextField(
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixText: '+91 ',
                  hintText: 'Enter your phone number',
                ),
                onChanged: (value) {
                  setState(() {
                    _phoneNumber = '+91' + value.replaceFirst('+91', '');
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_phoneNumber.length > 10) {
                    setState(() {
                      _isPhoneNumberEntered = true;
                    });
                    _verifyPhoneNumber();
                  }
                },
                child: Text('Verify Phone Number'),
              ),
            ],
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
                minimumSize: Size(200, 50),
                side: BorderSide(color: Colors.grey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
