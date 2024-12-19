import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageService {
  Future<File?> getLocalImage() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/profile_image.jpg';
    if (File(path).existsSync()) {
      return File(path);
    }
    return null;
  }

  Future<String> saveImageLocally(String imageUrl) async {
    final response = await http.get(Uri.parse(imageUrl));
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/profile_image.jpg');
    await file.writeAsBytes(response.bodyBytes);
    return file.path;
  }
}
