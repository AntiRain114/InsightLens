import 'package:flutter/material.dart';
import 'dart:async';

// A StatefulWidget to display the result of an API call in an animated way.
class ResultPage extends StatefulWidget {
  // API response data to be displayed on the page.
  final String apiResponse;

  // Constructor requiring the API response string.
  const ResultPage({Key? key, required this.apiResponse}) : super(key: key);

  @override
  // Create the state for this widget.
  _ResultPageState createState() => _ResultPageState();
}

// State class for ResultPage to manage the animation of text display.
class _ResultPageState extends State<ResultPage> {
  // String to hold the displayed text incrementally.
  String _displayedText = '';
  // Index to track the current position in the API response.
  int _currentIndex = 0;
  // Timer to manage the periodic animation.
  late Timer _timer;

  @override
  // Initialize the state, starting the text animation when the widget is inserted into the tree.
  void initState() {
    super.initState();
    _startTextAnimation();
  }

  @override
  // Dispose method to clean up the timer when the widget is removed from the tree.
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Function to start the animation of the text display.
  void _startTextAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        // Check if there are more characters to display.
        if (_currentIndex < widget.apiResponse.length) {
          // Add next character to the displayed text.
          _displayedText += widget.apiResponse[_currentIndex];
          _currentIndex++;
        } else {
          // Cancel the timer if all characters are displayed.
          _timer.cancel();
        }
      });
    });
  }

  @override
  // Build method that describes the part of the user interface represented by this widget.
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with a title and a back button.
      appBar: AppBar(
        title: const Text('Result Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Return to the previous screen when the back button is pressed.
            Navigator.pop(context);
          },
        ),
      ),
      // Body of the Scaffold containing the displayed text within a styled container.
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[100], // Light blue background color.
              borderRadius: BorderRadius.circular(16.0), // Rounded corners.
            ),
            child: Text(
              _displayedText,
              style: const TextStyle(fontSize: 18), // Text style with larger font size.
            ),
          ),
        ),
      ),
    );
  }
}