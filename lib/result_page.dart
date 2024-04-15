import 'package:flutter/material.dart';

class ResultPage extends StatefulWidget {
  final String apiResponse;

  const ResultPage({Key? key, required this.apiResponse}) : super(key: key);

  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result Page'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            widget.apiResponse,
            style: const TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}