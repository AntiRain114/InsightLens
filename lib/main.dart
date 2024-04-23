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
import 'agreement_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'privacy_policy_page.dart';
import 'terms_of_service_page.dart';
import 'account_settings_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';






// Entry point of the Flutter application. Initializes necessary libraries and runs the app.
void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures proper initialization of async operations.
  await Firebase.initializeApp( // Initializes Firebase with default options.
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp()); // Starts the application.
}

// Class to handle environment variables, specifically for retrieving API keys.
class Environment {
  static const String apiKey = String.fromEnvironment('API_KEY'); // Retrieves the API key from environment.
}




// The root widget of the application.
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsightLens', // Application title.
      theme: ThemeData( // Defines the visual theme of the app.
        primarySwatch: Colors.blue,
      ),
      home: AgreementPage(), // Sets the initial route of the app to the AgreementPage.
    );
  }
}

// A StatefulWidget for displaying an agreement page before accessing the main features.
class AgreementPage extends StatefulWidget {
  @override
  _AgreementPageState createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  int _countdown = 5; // Countdown timer starting from 5 seconds.
  late Timer _timer; // Timer object to handle countdown.

  @override
  void initState() {
    super.initState();
    startTimer(); // Initiates the countdown timer.
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancels the timer when the widget is disposed.
    super.dispose();
  }

  void startTimer() { // Method to start the countdown timer.
    const oneSec = Duration(seconds: 1); // Duration of one second.
    _timer = Timer.periodic(oneSec, (Timer timer) {
      if (_countdown == 0) {
        timer.cancel(); // Stops the timer when countdown reaches zero.
      } else {
        setState(() {
          _countdown--; // Decrements the countdown each second.
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Important Agreement', // Agreement title.
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'By using this software, you agree not to trust its advice regarding whether potentially toxic substances, animals, plants, and fungi are dangerous or edible. The information provided by this software should not be relied upon for determining the safety or edibility of any substance or organism.', // Agreement text.
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _countdown == 0 ? () { // Button that becomes enabled when countdown is over.
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => SearchPage()),
                );
              } : null,
              child: Text('I Agree'),
            ),
            SizedBox(height: 10),
            Text(
              'Button will be enabled in $_countdown seconds', // Shows remaining seconds until the button is enabled.
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

// A StatefulWidget for the main functionality of searching and using the camera.
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  CameraController? cameraController; // Controller for camera operations.
  LocationData? currentLocation; // Holds the current location data.
  Location location = Location(); // Location instance for location services.
  String? imagePath; // Path of the captured image.
  bool isUploading = false; // Indicates whether an upload is in progress.
  List<Map<String, dynamic>> searchHistory = []; // Stores search history.

  @override
  void initState() {
    super.initState();
    _initCamera(); // Initializes the camera.
    _getLocation(); // Fetches the current location.
  }

  Future<void> _initCamera() async { // Initializes camera controller with settings.
    final cameras = await availableCameras(); // Gets the list of available cameras.
    final firstCamera = cameras.first; // Selects the first available camera.

    cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
    );

    await cameraController!.initialize(); // Initializes the camera controller.

    if (!mounted) {
      return; // Checks if the widget is still in the tree.
    }

    setState(() {}); // Triggers a rebuild to update UI.
  }

  Widget _buildCameraPreview() { // Builds the camera preview widget.
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return Container(); // Returns an empty container if camera is not initialized.
    }

    final previewSize = cameraController!.value.previewSize!;
    final aspectRatio = previewSize.width / previewSize.height; // Calculates the aspect ratio.

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onScaleStart: _handleScaleStart, // Handles pinch to zoom start.
        onScaleUpdate: _handleScaleUpdate, // Handles pinch to zoom update.
        child: CameraPreview(cameraController!), // Displays the camera preview.
      ),
    );
  }

  double _currentScale = 1.0; // Current zoom scale.
  double _baseScale = 1.0; // Base scale when zoom started.

  void _handleScaleStart(ScaleStartDetails details) { // Handles the start of a scale gesture.
    _baseScale = _currentScale; // Sets the base scale.
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) { // Handles updates to the scaling gesture.
    setState(() {
      _currentScale = _baseScale * details.scale; // Updates the current scale based on the gesture.
      cameraController!.setZoomLevel(_currentScale); // Sets the zoom level on the camera.
    });
  }

  Future<void> _getLocation() async { // Retrieves the current location.
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return; // Exits if unable to enable services.
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return; // Exits if permissions are denied.
      }
    }

    currentLocation = await location.getLocation(); // Fetches the current location.
  }
  
  Future<String> convertImageToBase64(XFile image) async { // Converts an image file to a base64 string.
    final bytes = await image.readAsBytes(); // Reads the image as bytes.
    return base64Encode(bytes); // Encodes the bytes to base64.
  }

  Future<void> cacheBase64Image(String base64Image) async { // Caches a base64 encoded image.
    final directory = await getApplicationDocumentsDirectory(); // Gets the application documents directory.
    final filePath = '${directory.path}/cachedImage_${DateTime.now().millisecondsSinceEpoch}.txt'; // Generates a file path.
    final file = File(filePath); // Creates a file at the path.
    await file.writeAsString(base64Image); // Writes the base64 string to the file.
    print('Base64 image cached at $filePath'); // Logs the path to the console.
  }

  Future<void> _takePicture() async { // Handles taking a picture with the camera.
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return; // Returns early if the camera is not initialized.
    }

    try {
      final XFile? image = await cameraController!.takePicture();
      if (image != null) {
        final String base64Image = await convertImageToBase64(image); // Converts the image to base64.
        
        await cacheBase64Image(base64Image); // Caches the base64 image.

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoadingPage()), // Navigates to a loading page.
        );

        // Get the current location
        await _getLocation(); // Fetches the current location.

        if (currentLocation != null) {
          final String locationDescription = 'This photo was taken at latitude ${currentLocation!.latitude} and longitude ${currentLocation!.longitude}.'; // Formats the location description.

          // At this point, the base64Image is both converted and cached, and the location is retrieved.
          print('Image captured and cached in base64 format with location: $locationDescription');

          // Upload the image with location description
          await uploadImageWithOpenAI(base64Image, locationDescription);
          print('Uploading image to OpenAI API...');
          final String apiResponse = await uploadImageWithOpenAI(base64Image, locationDescription); // Uploads the image to OpenAI and retrieves the response.
          print('API response received: $apiResponse');

          // Navigate to the ResultPage and pass the apiResponse
          Navigator.pop(context); // Pops the current page off the navigation stack.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResultPage(apiResponse: apiResponse)), // Navigates to the ResultPage with the API response.
          );
          final record = {
            'image': await image.readAsBytes(), // Stores the image bytes.
            'description': locationDescription, // Stores the location description.
            'apiResponse': apiResponse, // Stores the API response.
          };
          setState(() {
            searchHistory.insert(0, record); // Inserts the new record at the beginning of the search history.
            if (searchHistory.length > 2) {
              searchHistory.removeLast(); // Removes the last record if there are more than 2 records.
            }
          });
        } else {
          print('Location not available. Uploading image without location.');
          await uploadImageWithOpenAI(base64Image, ''); // Uploads the image without a location.
          
        }
      } else {
        print("No image captured."); // Logs if no image was captured.
      }
    } catch (e) {
      print('Exception occurred: $e'); // Logs any exceptions that occur.
      // Pop the LoadingPage if an exception occurs
      Navigator.pop(context);
      // Handle the exception, e.g., show an error message
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Exception'), // Displays an exception dialog.
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
  
  // Method to upload an image and receive a response from an API.
  Future<String> uploadImageWithOpenAI(String base64Image, String locationDescription) async {
    const String apiKey  = Environment.apiKey; // Retrieves the API key from the environment.
    
    if (apiKey == null) {
      print("API key not found in environment variables.");
      return 'Error: API key not found.'; // Returns an error if no API key is found.
    } else {
      print("API key: yes");
    }

    final directory = await getApplicationDocumentsDirectory(); // Gets the application documents directory.
    final files = await directory.list().toList(); // Lists all files in the directory.
    final cachedImageFiles = files.where((file) => file.path.endsWith('.txt')).toList(); // Filters files to find those ending in .txt.

    if (cachedImageFiles.isEmpty) {
      print("No cached image found.");
      return 'Error: No cached image found.'; // Returns an error if no cached image is found.
    }

    final cachedImageFile = cachedImageFiles.last; // Gets the last cached image file.
    final file = File(cachedImageFile.path); // Creates a file object for the cached image.
    String base64Image = await file.readAsString(); // Reads the base64 image from the file.

    var headers = {
      "Content-Type": "application/json", // Sets the content type header for the HTTP request.
      "Authorization": "Bearer $apiKey" // Sets the authorization header using the API key.
    };

    var payload = jsonEncode({ // Encodes the payload as JSON.
      "model": "gpt-4-turbo", // Specifies the model to use.
      "messages": [
      {
        "role": "user",
        "content": [
          {
            "type": "text",
            "text": "What's in this image? The picture was take at\n\n$locationDescription\n" // Text message describing the image location.
          },
          {
            "type": "image_url",
            "image_url": {
              "url": "data:image/jpeg;base64,$base64Image" // Provides the base64 encoded image data.
            }
          }
        ]
      }
    ],
      "max_tokens": 300 // Sets the maximum number of tokens for the model's response.
    });

    var response = await http.post( // Sends an HTTP POST request.
      Uri.parse("https://api.openai.com/v1/chat/completions"), // Specifies the URL to which the request is sent.
      headers: headers, // Includes the headers in the request.
      body: payload, // Includes the payload in the request.
    );

    if (response.statusCode == 200) { // Checks if the response status code is 200 (OK).
      final jsonResponse = jsonDecode(response.body); // Decodes the JSON response.
      final apiResponse = jsonResponse['choices'][0]['message']['content']; // Retrieves the content from the response.
      return apiResponse; // Returns the API response.
    } else {
      print("Failed to upload image to OpenAI: ${response.statusCode}"); // Logs if the upload failed.
      return 'Error: ${response.statusCode}'; // Returns an error if the upload failed.
    }
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) { // Checks if the camera is not initialized.
      return Scaffold(
        body:  Column(
      children: [
        Expanded(child: _buildCameraPreview()), // Builds the camera preview.
      ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('InsightLens'), // Title of the app bar.
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage()), // Navigates to the settings page.
              );
            },
          ),
        ],
      ),
      drawer: Drawer( // Drawer for navigation.
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Navigation'), // Drawer header text.
            ),
            ListTile(
              title: const Text('Home'), // Home option in the drawer.
              onTap: () {
                Navigator.pop(context); // Closes the drawer when tapped.
              },
            ),
            ListTile(
              title: const Text('History'), // History option in the drawer.
              onTap: () {
                Navigator.pop(context); // Closes the drawer when tapped.
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HistoryPage(searchHistory: searchHistory)), // Navigates to the history page with the search history.
                );
              },
            ),
          ],
        ),
      ),
      
      body: Column(
        children: <Widget>[
          Expanded(
            child: CameraPreview(cameraController!), // Displays the camera preview.
          ),
          if (isUploading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(), // Displays a loading indicator if uploading is in progress.
            ),
          if (!isUploading && imagePath != null)
            Image.file(File(imagePath!)), // Displays the captured image if available.
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              icon: Icon(Icons.camera_alt),
              label: Text('Capture Image'), // Button to capture an image.
              onPressed: _takePicture, // Triggers the _takePicture method when pressed.
            ),
          ),
          if (currentLocation != null)
            Text('Location: Lat:${currentLocation!.latitude}, Long:${currentLocation!.longitude}'), // Displays the current location.
        ],
      ),
    );
    
  }

   
}


// A StatefulWidget for managing settings within the application.
class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool notificationsEnabled = true; // Boolean flag for notifications setting.
  double volume = 0.5; // Volume setting value.
  String selectedApi = 'openai'; // Currently selected API.

  List<String> availableApis = ['openai', 'Coming Soon']; // List of available APIs.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"), // Title of the settings page.
      ),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: Text("Enable Notifications"), // Toggle for notifications.
            value: notificationsEnabled,
            onChanged: (bool value) {
              setState(() {
                notificationsEnabled = value; // Updates the notifications setting.
              });
              // Implement saving this setting preferably
            },
          ),
          ListTile(
  title: Text("Account Settings"),
  subtitle: Text("Manage your account"), // Navigates to the account settings page.
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AccountSettingsPage()), // Navigates to the AccountSettingsPage.
    );
  },
),
          Slider(
            value: volume,
            min: 0,
            max: 1,
            divisions: 10,
            label: volume.round().toString(), // Displays the current volume level.
            onChanged: (double value) {
              setState(() {
                volume = value; // Updates the volume setting.
              });
              // Implement saving this setting preferably
            },
          ),
          ListTile(
            title: Text("API Selection"),
            subtitle: Text("Select the API to use"), // Dropdown for selecting the API.
            trailing: DropdownButton<String>(
              value: selectedApi,
              onChanged: (String? newValue) {
                setState(() {
                  selectedApi = newValue!; // Updates the selected API.
                });
                // Implement saving this setting preferably
              },
              items: availableApis.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value), // Displays the API options.
                );
              }).toList(),
            ),
          ),
          ListTile(
  title: Text("Privacy Policy"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrivacyPolicyPage()), // Navigates to the PrivacyPolicyPage.
    );
  },
),
          ListTile(
  title: Text("Terms of Service"),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TermsOfServicePage()), // Navigates to the TermsOfServicePage.
    );
  },
),
          // Add more settings here as needed
        ],
      ),
    );
  }
}
