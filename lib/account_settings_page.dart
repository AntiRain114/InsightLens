import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'main.dart';
import 'registration_page.dart';
import 'reset_password_page.dart';
// Define a StatefulWidget to manage account settings page.
class AccountSettingsPage extends StatefulWidget {
  @override
  // Create the state for the AccountSettingsPage.
  _AccountSettingsPageState createState() => _AccountSettingsPageState();
}

// State class for AccountSettingsPage to handle account-related actions.
class _AccountSettingsPageState extends State<AccountSettingsPage> {
  // Keys to maintain form state.
  final _formKey = GlobalKey<FormState>();
  // Text editing controllers to manage email and password inputs.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Instance of FirebaseAuth to handle authentication tasks.
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Function to handle user login with email and password.
  void _login() async {
    // Validate form fields before proceeding.
    if (_formKey.currentState!.validate()) {
      try {
        // Attempt to sign in the user using email and password.
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Display success dialog if login is successful.
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Login Successful'),
              content: Text('Welcome back!'),
              actions: [
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();  // Close the dialog.
                    Navigator.pushReplacement(  // Navigate to SearchPage.
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );
                  },
                ),
              ],
            );
          },
        );
      } on FirebaseAuthException catch (e) {
        // Handle different authentication errors.
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found for that email.')),
          );
        } else if (e.code == 'wrong-password') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Wrong password provided.')),
          );
        }
      }
    }
  }

  // Function to register a new user.
  void _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Attempt to create a new user account using email and password.
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );
        // Handle registration success, potentially navigating to another page.
      } on FirebaseAuthException catch (e) {
        // Handle registration errors like weak password or existing email.
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

  // Function to send password reset email to the user.
  void _resetPassword() async {
    if (_formKey.currentState!.validate()) {
      try {
        // Send password reset email.
        await _auth.sendPasswordResetEmail(email: _emailController.text);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent.')),
        );
      } on FirebaseAuthException catch (e) {
        // Handle case where no user is found with the provided email.
        if (e.code == 'user-not-found') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No user found for that email.')),
          );
        }
      }
    }
  }

  // Build the UI for the account settings page.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Account Settings"),  // Set the title of the AppBar.
      ),
      body: SingleChildScrollView(  // Allow the form to scroll.
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,  // Associate the form key.
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Text field for user's email.
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
                validator: (value) {
                  // Validate email field.
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!EmailValidator.validate(value)) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              // Text field for user's password.
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: "Password"),
                obscureText: true,  // Obscure text for password.
                validator: (value) {
                  // Validate password field.
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
              // Buttons for login, registration, and password reset.
              ElevatedButton(
                onPressed: _login,
                child: Text("Login"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegistrationPage()),
                  );
                },
                child: Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ResetPasswordPage()),
                  );
                },
                child: Text('Forgot Password?'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}