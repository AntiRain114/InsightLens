import 'package:flutter/material.dart';
import 'result_page.dart';

// A stateless widget to display the search history page.
class HistoryPage extends StatelessWidget {
  // A list of maps that holds the search history data.
  final List<Map<String, dynamic>> searchHistory;

  // Constructor that initializes the HistoryPage with required searchHistory list.
  // The 'key' is optional and used for identifying the widget in the widget tree.
  const HistoryPage({Key? key, required this.searchHistory}) : super(key: key);

  @override
  // Build method that describes the part of the user interface represented by this widget.
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar widget with a title.
      appBar: AppBar(
        title: const Text('Search History'),  // Title of the AppBar.
      ),
      // Body of the Scaffold using a ListView.builder to create a list of items.
      body: ListView.builder(
        itemCount: searchHistory.length,  // The number of items in the list equals the number of records in searchHistory.
        itemBuilder: (context, index) {  // itemBuilder to build each item in the list.
          final record = searchHistory[index];  // The current record being processed.
          return ListTile(
            leading: Image.memory(record['image']),  // Display image from search history.
            title: Text('Search ${index + 1}'),  // Title for the ListTile showing search index.
            subtitle: Text(record['description']),  // Subtitle showing the description from search history.
            onTap: () {  // onTap function to handle user interaction.
              // Navigate to ResultPage when the ListTile is tapped, passing the apiResponse related to this search.
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ResultPage(apiResponse: record['apiResponse'])),
              );
            },
          );
        },
      ),
    );
  }
}