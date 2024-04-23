import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';

// A StatefulWidget to handle password reset functionality.
class ResetPasswordPage extends StatefulWidget {
  @override
  // Create the state for this widget.
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

// State class for ResetPasswordPage to manage password reset operations.
class _ResetPasswordPageState extends State<ResetPasswordPage> {
  // Key to maintain the state of the form.
  final _formKey = GlobalKey<FormState>();
  // Text editing controller to manage email input.
  final _emailController = TextEditingController();

  // Instance of FirebaseAuth to handle authentication tasks.
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to reset the password.
  void _resetPassword() async {
    // Validate the form fields before proceeding.
    if (_formKey.currentState!.validate()) {
      try {
        // Attempt to send a password reset email.
        await _auth.sendPasswordResetEmail(email: _emailController.text);
        // Show dialog on successful password reset email sending.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Password Reset'),
              content: Text('A password reset link has been sent to your email address.'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog.
                    Navigator.of(context).pop(); // Go back to the previous screen.
                  },
                ),
              ],
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        // Handle errors like no user found with that email.
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found for that email.')),
          );
        }
      }
    }
  }

  @override
  // Build method that describes the part of the user interface represented by this widget.
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar widget with a title.
      appBar: AppBar(
        title: Text('Reset Password'), // Title of the AppBar.
      ),
      // Body of the Scaffold using SingleChildScrollView to prevent overflow.
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Associate the form key.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text field for user's email input.
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'), // Label for the email field.
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
              SizedBox(height: 16.0),
              // Button to initiate the password reset process.
              ElevatedButton(
                onPressed: _resetPassword,
                child: Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}