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
import 'loading_page.dart';
import 'history_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';




void main() => runApp(MyApp());

final String apiKey = String.fromEnvironment('OPENAI_API_KEY');


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
  List<Map<String, dynamic>> searchHistory = [];

  @override
  void initState() {
    super.initState();
    _initCamera();
    _getLocation();
  }

  Future<String> getApiKey() async {
  final file = File('api_key.txt');
  final apiKey = await file.readAsString();
  return apiKey.trim();
}


  
  

  Future<void> _initCamera() async {
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  cameraController = CameraController(
    firstCamera,
    ResolutionPreset.medium,
  );

  await cameraController!.initialize();

  // Set the desired preview size
  final previewSize = cameraController!.value.previewSize!;
  final aspectRatio = previewSize.width / previewSize.height;
  final desiredWidth = MediaQuery.of(context).size.width;
  final desiredHeight = desiredWidth / aspectRatio;

  cameraController!.value = cameraController!.value.copyWith(
    previewSize: Size(desiredWidth, desiredHeight),
  );

  if (!mounted) {
    return;
  }

  setState(() {});
}
Widget _buildCameraPreview() {
  if (cameraController == null || !cameraController!.value.isInitialized) {
    return Container();
  }

  final previewSize = cameraController!.value.previewSize!;
  final aspectRatio = previewSize.width / previewSize.height;

  return AspectRatio(
    aspectRatio: aspectRatio,
    child: GestureDetector(
      onScaleStart: _handleScaleStart,
      onScaleUpdate: _handleScaleUpdate,
      child: CameraPreview(cameraController!),
    ),
  );
}

double _currentScale = 1.0;
double _baseScale = 1.0;

void _handleScaleStart(ScaleStartDetails details) {
  _baseScale = _currentScale;
}

void _handleScaleUpdate(ScaleUpdateDetails details) {
  setState(() {
    _currentScale = _baseScale * details.scale;
    cameraController!.setZoomLevel(_currentScale);
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

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoadingPage()),
      );

      // Get the current location
      await _getLocation();

      if (currentLocation != null) {
        final String locationDescription = 'This photo was taken at latitude ${currentLocation!.latitude} and longitude ${currentLocation!.longitude}.';

        // At this point, the base64Image is both converted and cached, and the location is retrieved.
        print('Image captured and cached in base64 format with location: $locationDescription');

        // Upload the image with location description
        await uploadImageWithOpenAI(base64Image, locationDescription);
       print('Uploading image to OpenAI API...');
        final String apiResponse = await uploadImageWithOpenAI(base64Image, locationDescription);
        print('API response received: $apiResponse');

        // Navigate to the ResultPage and pass the apiResponse
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ResultPage(apiResponse: apiResponse)),
        );
        final record = {
          'image': await image.readAsBytes(),
          'description': locationDescription,
          'apiResponse': apiResponse,
        };
        setState(() {
          searchHistory.insert(0, record);
          if (searchHistory.length > 2) {
            searchHistory.removeLast();
          }
        });
      } else {
        print('Location not available. Uploading image without location.');
        await uploadImageWithOpenAI(base64Image, '');

        
      }
    } else {
      print("No image captured.");
    }
  } catch (e) {
    print('Exception occurred: $e');
  // Pop the LoadingPage if an exception occurs
  Navigator.pop(context);
  // Handle the exception, e.g., show an error message
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Exception'),
      content: Text(e.toString()),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('OK'),
        ),
      ],
    ),
  );
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
  final String apiKey = await getApiKey();


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
    "model": "gpt-4-turbo",
    "messages": [
    {
      "role": "user",
      "content": [
        {
          "type": "text",
          "text": "What's in this image? The picture was take at\n\n$locationDescription\n"
        },
        {
          "type": "image_url",
          "image_url": {
            "url": "data:image/jpeg;base64,$base64Image"
          }
        }
      ]
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
        body:  Column(
      children: [
        Expanded(child: _buildCameraPreview()), ],
        ),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Navigation'),
            ),
            ListTile(
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('History'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage(searchHistory: searchHistory)),
                );
              },
            ),
          ],
        ),
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