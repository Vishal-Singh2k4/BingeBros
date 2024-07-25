import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String errorMessage = '';

  Future<void> signUp() async {
    setState(() {
      errorMessage = '';
    });

    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = 'Email cannot be empty.';
      });
      return;
    }

    if (passwordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Password cannot be empty.';
      });
      return;
    }

    if (confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = 'Confirm Password cannot be empty.';
      });
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
      return;
    }

    try {
      // Check if the email is already in use
      List<String> signInMethods =
          await _auth.fetchSignInMethodsForEmail(emailController.text);
      if (signInMethods.isNotEmpty) {
        setState(() {
          errorMessage = 'The email address is already in use.';
        });
        return;
      }

      // If email is not in use, proceed with sign-up
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Send verification email
      await userCredential.user?.sendEmailVerification();

      // Redirect to a page for email verification check
      Navigator.pushReplacementNamed(context, '/emailVerification');
    } catch (e) {
      setState(() {
        if (e is FirebaseAuthException) {
          switch (e.code) {
            case 'invalid-email':
              errorMessage = 'The email address is badly formatted.';
              break;
            case 'weak-password':
              errorMessage = 'The password is too weak.';
              break;
            case 'email-already-in-use':
              errorMessage = 'The email address is already in use.';
              break;
            default:
              errorMessage = 'An undefined error happened.';
          }
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: signUp,
              child: Text('Sign Up'),
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
