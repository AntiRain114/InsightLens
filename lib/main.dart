import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'result_page.dart';




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

  Future<String> convertImageToBase64(XFile image) async {
  final bytes = await image.readAsBytes(); // Read the image file
  return base64Encode(bytes); // Encode to base64
}

Future<void> cacheBase64Image(String base64Image) async {
  final directory = await getApplicationDocumentsDirectory(); // Get directory
  final filePath = '${directory.path}/cachedImage_${DateTime.now().millisecondsSinceEpoch}.txt'; // Define path
  final file = File(filePath); // Create a File instance
  await file.writeAsString(base64Image); // Write the base64 string to the file
  print('Base64 image cached at $filePath');
}

  Future<void> _takePicture() async {
  if (cameraController == null || !cameraController!.value.isInitialized) {
    return;
  }

  try {
    final XFile? image = await cameraController!.takePicture();
    if (image != null) {
      final String base64Image = await convertImageToBase64(image);
      
      await cacheBase64Image(base64Image);

      // Get the current location
      await _getLocation();

      if (currentLocation != null) {
        final String locationDescription = 'This photo was taken at latitude ${currentLocation!.latitude} and longitude ${currentLocation!.longitude}.';

        // At this point, the base64Image is both converted and cached, and the location is retrieved.
        print('Image captured and cached in base64 format with location: $locationDescription');

        // Upload the image with location description
        await uploadImageWithOpenAI(base64Image, locationDescription);
        final String apiResponse = await uploadImageWithOpenAI(base64Image, locationDescription);

        // Navigate to the ResultPage and pass the apiResponse
        Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultPage(apiResponse: apiResponse),
        ),
      );
      } else {
        print('Location not available. Uploading image without location.');
        await uploadImageWithOpenAI(base64Image, '');

        
      }
    } else {
      print("No image captured.");
    }
  } catch (e) {
    print(e); // Handle errors
  }
}

//   Future<String> getImageBase64() async {
//   final ImagePicker _picker = ImagePicker();
//   final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

//   if (image != null) {
//     final bytes = await File(imagePath).readAsBytes(); // Use asynchronous read
//   return base64Encode(bytes);
//   } else {
//     return '';
//   }
// }



  // Future<void> _takePicture() async {
  //   if (cameraController == null || !cameraController!.value.isInitialized) {
  //     return;
  //   }

  //   try {
  //     final image = await cameraController!.takePicture();
  //     setState(() {
  //       imagePath = image.path;
  //     });
  //     await _getLocation();
  //     if (currentLocation != null) {
  //       await _sendData(image.path, currentLocation!);
  //     }
  //   } catch (e) {
  //     print(e);
  //   }
  // }

  //  Future<void> _sendData(String imagePath, LocationData locationData) async {
  //   setState(() {
  //     isUploading = true;
  //   });

  //   Uri apiUri = Uri.parse('GPTAPI');

  //   var request = http.MultipartRequest('POST', apiUri)
  //     ..fields['latitude'] = locationData.latitude.toString()
  //     ..fields['longitude'] = locationData.longitude.toString()
  //     ..files.add(await http.MultipartFile.fromPath(
  //       'image', 
  //       imagePath,
  //     ));

  //   try {
  //     var streamedResponse = await request.send();
  //     var response = await http.Response.fromStream(streamedResponse);
      
  //     if (response.statusCode == 200) {
  //       var data = jsonDecode(response.body);
  //       // Handle the data received from the API
  //       print(data);
  //     } else {
  //       print('Failed to load data');
  //     }
  //   } catch (e) {
  //     print(e);
  //   } finally {
  //     setState(() {
  //       isUploading = false;
  //     });
  //   }
  // }
Future<String> uploadImageWithOpenAI(String base64Image, String locationDescription) async {
  final String apiKey = Platform.environment['OPENAI_API_KEY'] ?? '';


  final directory = await getApplicationDocumentsDirectory();
  final files = await directory.list().toList();
  final cachedImageFiles = files.where((file) => file.path.endsWith('.txt')).toList();

    if (cachedImageFiles.isEmpty) {
    print("No cached image found.");
    return 'Error: No cached image found.';
  }

  final cachedImageFile = cachedImageFiles.last;
  final file = File(cachedImageFile.path);
  String base64Image = await file.readAsString();

  var headers = {
    "Content-Type": "application/json",
    "Authorization": "Bearer $apiKey"
  };

  var payload = jsonEncode({
    "model": "gpt-4-vision-preview",
    "messages": [
      {
        "role": "user",
        "content": "What's in this image?\n\n$locationDescription\n\ndata:image/jpeg;base64,$base64Image"
      }
    ],
    "max_tokens": 300
  });

  var response = await http.post(
    Uri.parse("https://api.openai.com/v1/chat/completions"),
    headers: headers,
    body: payload,
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final apiResponse = jsonResponse['choices'][0]['message']['content'];
    return apiResponse;
  } else {
    print("Failed to upload image to OpenAI: ${response.statusCode}");
    return 'Error: ${response.statusCode}';
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