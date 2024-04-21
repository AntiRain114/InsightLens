import 'package:flutter/material.dart';
import 'dart:async';

class ResultPage extends StatefulWidget {
  final String apiResponse;

  const ResultPage({Key? key, required this.apiResponse}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  String _displayedText = '';
  int _currentIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTextAnimation();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTextAnimation() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        if (_currentIndex < widget.apiResponse.length) {
          _displayedText += widget.apiResponse[_currentIndex];
          _currentIndex++;
        } else {
          _timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Page'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.blue[100],
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Text(
              _displayedText,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }
}