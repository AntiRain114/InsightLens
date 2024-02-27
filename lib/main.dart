import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsightLens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SearchPage(),
    );
  }
}

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  CameraController? cameraController;
  LocationData? currentLocation;
  Location location = Location();
  String? imagePath;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
    _getLocation();
  }
  
  

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    cameraController!.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  Future<void> _getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    currentLocation = await location.getLocation();
  }

  Future<void> _takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await cameraController!.takePicture();
      setState(() {
        imagePath = image.path;
      });
      await _getLocation();
      if (currentLocation != null) {
        await _sendData(image.path, currentLocation!);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> _sendData(String imagePath, LocationData locationData) async {
    setState(() {
      isUploading = true;
    });

    Uri apiUri = Uri.parse('Your_GPT-4.0_API_Endpoint');

    var request = http.MultipartRequest('POST', apiUri)
      ..fields['latitude'] = locationData.latitude.toString()
      ..fields['longitude'] = locationData.longitude.toString()
      ..files.add(await http.MultipartFile.fromPath(
        'image', 
        imagePath,
      ));

    try {
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        // Handle the data received from the API
        print(data);
      } else {
        print('Failed to load data');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('InsightLens'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      
      
      body: Column(
        children: <Widget>[
          Expanded(
            child: CameraPreview(cameraController!),
          ),
          if (isUploading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          if (!isUploading && imagePath != null)
            Image.file(File(imagePath!)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Capture Image'),
              onPressed: _takePicture,
            ),
          ),
          if (currentLocation != null)
            Text('Location: Lat:${currentLocation!.latitude}, Long:${currentLocation!.longitude}'),
        ],
      ),
    );
    
  }

   
}

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true;
  double volume = 0.5;
  // Add other settings variables here

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: Text("Enable Notifications"),
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value;
              });
              // Implement saving this setting preferably
            },
          ),
          ListTile(
            title: Text("Account Settings"),
            subtitle: Text("Manage your account"),
            onTap: () {
              // Navigate to account settings page or show account info
            },
          ),
          Slider(
            value: volume,
            min: 0,
            max: 1,
            divisions: 10,
            label: volume.round().toString(),
            onChanged: (double value) {
              setState(() {
                volume = value;
              });
              // Implement saving this setting preferably
            },
          ),
          ListTile(
            title: Text("Privacy Policy"),
            onTap: () {
              // Open privacy policy
            },
          ),
          ListTile(
            title: Text("Terms of Service"),
            onTap: () {
              // Open terms of service
            },
          ),
          // Add more settings here as needed
        ],
      ),
    );
  }
}