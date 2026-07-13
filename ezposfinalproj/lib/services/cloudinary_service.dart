import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Replace these with your actual Cloudinary credentials
  static const String _cloudName = 'jysemagp'; 
  static const String _uploadPreset = 'EzPosRheaChen';

  Future<String?> uploadImage(File file) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      
      // Creating the multipart request
      var request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      // Sending the request
      var response = await request.send();
      
      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final responseString = String.fromCharCodes(responseData);
        final jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url']; // This is the HTTPS URL
      } else {
        print("Upload Failed with status: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Cloudinary Upload Error: $e");
      return null;
    }
  }
}