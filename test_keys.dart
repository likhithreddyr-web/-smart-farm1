import 'dart:convert';
import 'dart:io';

void main() async {
  final keys = [
    'AIzaSyDvsVYKn0tQ3zpQSlAvTOWIcY9Dk7w8Z5o', // Original
    'AIzaSyDvsVYKn0tQ3zpQSIAvTOWIcY9Dk7w8Z5o', // l -> I
    'AIzaSyDvsVYKn0tQ3zpQSlAvTOWlcY9Dk7w8Z5o', // I -> l
    'AIzaSyDvsVYKn0tQ3zpQSIAvTOWlcY9Dk7w8Z5o', // both swapped
  ];
  
  final httpClient = HttpClient();
  
  for (var key in keys) {
    final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models?key=' + key);
    try {
      final request = await httpClient.getUrl(url);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      print('Testing ' + key + ': ' + response.statusCode.toString());
      if (response.statusCode == 200) {
        print('SUCCESS! This is the right key.');
        print(responseBody);
        break;
      }
    } catch (e) {
      print('Failed for \$key: \$e');
    }
  }
  
  httpClient.close();
}
