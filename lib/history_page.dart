import 'package:flutter/material.dart';
import 'result_page.dart';

class HistoryPage extends StatelessWidget {
  final List<Map<String, dynamic>> searchHistory;

  const HistoryPage({Key? key, required this.searchHistory}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search History'),
      ),
      body: ListView.builder(
        itemCount: searchHistory.length,
        itemBuilder: (context, index) {
          final record = searchHistory[index];
          return ListTile(
            leading: Image.memory(record['image']),
            title: Text('Search ${index + 1}'),
            subtitle: Text(record['description']),
            onTap: () {
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