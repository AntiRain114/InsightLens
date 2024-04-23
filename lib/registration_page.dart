import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';


// A StatefulWidget to handle user registration.
class RegistrationPage extends StatefulWidget {
  @override
  // Create the state for the RegistrationPage.
  _RegistrationPageState createState() => _RegistrationPageState();
}

// State class for RegistrationPage to manage registration operations.
class _RegistrationPageState extends State<RegistrationPage> {
  // Key to maintain the state of the form.
  final _formKey = GlobalKey<FormState>();
  // Text editing controllers to manage email and password inputs.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instance of FirebaseAuth to handle authentication tasks.
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle user registration.
  void _register() async {
    // Validate form fields before proceeding.
    if (_formKey.currentState!.validate()) {
      try {
        // Attempt to create a new user account using email and password.
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Check if registration was successful and handle email verification.
        User? user = userCredential.user;
        if (user != null && !user.emailVerified) {
          await user.sendEmailVerification();
          // Display a dialog to inform the user about the verification email.
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Registration Successful'),
                content: Text('A verification email has been sent to your email address. Please verify your email to complete the registration.'),
                actions: [
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog.
                      Navigator.of(context).pop(); // Navigate back.
                    },
                  ),
                ],
              );
            },
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle errors like weak password or email already in use.
        if (e.code == 'weak-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The password provided is too weak.')),
          );
        } else if (e.code == 'email-already-in-use') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('The account already exists for that email.')),
          );
        }
      }
    }
  }

  @override
  // Build method that describes the part of the user interface represented by this widget.
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with a title.
      appBar: AppBar(
        title: Text('Registration'),  // Title of the AppBar.
      ),
      // Body of the Scaffold using SingleChildScrollView to allow scrolling.
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Associate the form key.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text field for user's email input.
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),  // Label for the email field.
                validator: (value) {
                  // Validate the email field.
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!EmailValidator.validate(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              // Text field for user's password input.
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'), // Label for the password field.
                obscureText: true,  // Obscure text for security.
                validator: (value) {
                  // Validate the password field.
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?!.*?[^\w\s]).{6,}$').hasMatch(value)) {
                    return 'Password must contain uppercase, lowercase letters and numbers';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              // Button to initiate the registration process.
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
