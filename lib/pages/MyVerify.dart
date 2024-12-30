import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pinput/pinput.dart';
import 'package:binge/routes/routes.dart';

class MyVerify extends StatefulWidget {
  final String phoneNumber;
  const MyVerify({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  State<MyVerify> createState() => _MyVerifyState();
}

class _MyVerifyState extends State<MyVerify> {
  String _verificationId = '';
  final TextEditingController otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _verifyPhoneNumber();
  }

  void _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: widget.phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
        setState(() {
          _isLoading = false; // Stop loading on failure
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed. Please try again.')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false; // Stop loading after code is sent
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isLoading = false; // Stop loading on timeout
        });
      },
    );
  }

  void _verifyCode() async {
    String otp = otpController.text.trim();
    if (_verificationId.isEmpty) {
      print('Verification ID is not set.');
      return;
    }

    setState(() {
      _isLoading = true; // Start loading on code verification
    });

    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: _verificationId,
      smsCode: otp,
    );

    try {
      await _signInWithCredential(credential);
    } catch (e) {
      print('Error verifying code: ${e.toString()}');
      setState(() {
        _isLoading = false; // Stop loading on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid code. Please try again.')),
      );
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Check if the user already has an account
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        Navigator.pushReplacementNamed(context, Routes.usernameSetup);
      } else {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } catch (e) {
      print('Error signing in with credential: ${e.toString()}');
      setState(() {
        _isLoading = false; // Stop loading on sign-in error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed. Please try again.')),
      );
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

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        color: primaryTextColor,
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        border: Border.all(
            color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!),
        borderRadius: BorderRadius.circular(20),
        color: isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
        color: isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1E1E1E) : Color(0xFFF5F5F5),
      ),
    );
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation
        return false;
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
                    "Phone Verification",
                    style: TextStyle(
                      color: primaryTextColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "We need to register your phone before getting started!",
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 40),
                  Pinput(
                    length: 6,
                    controller: otpController,
                    showCursor: true,
                    defaultPinTheme: defaultPinTheme,
                    focusedPinTheme: focusedPinTheme,
                    submittedPinTheme: submittedPinTheme,
                    onCompleted: (pin) => _verifyCode(),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _verifyCode,
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Text(
                            "Verify Phone Number",
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
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Edit Phone Number?",
                      style: TextStyle(
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
