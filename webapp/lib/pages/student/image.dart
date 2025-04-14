import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadDialog extends StatefulWidget {
  const ImageUploadDialog({super.key});

  @override
  _ImageUploadDialogState createState() => _ImageUploadDialogState();
}

class _ImageUploadDialogState extends State<ImageUploadDialog> {
  File? _selectedImage;
  Uint8List? _webImageBytes;
  XFile? _pickedFile;
  bool _isUploading = false;
  String? _errorMessage;

  final String _imgbbApiKey = "321e92bce52209a8c6c4f1271bbec58f";

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        _pickedFile = picked;
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _webImageBytes = bytes;
          });
        } else {
          setState(() {
            _selectedImage = File(picked.path);
          });
        }
        setState(() {
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error selecting image: $e";
      });
    }
  }

  Future<void> _uploadImage() async {
    if ((kIsWeb && _webImageBytes == null) || (!kIsWeb && _selectedImage == null)) {
      setState(() {
        _errorMessage = "Please select an image first";
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = null;
    });

    try {
      final Dio dio = Dio();
      FormData formData;

      if (kIsWeb && _pickedFile != null) {
        final bytes = await _pickedFile!.readAsBytes();
        final multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: _pickedFile!.name,
        );

        formData = FormData.fromMap({
          'key': _imgbbApiKey,
          'image': multipartFile,
        });
      } else {
        formData = FormData.fromMap({
          'key': _imgbbApiKey,
          'image': await MultipartFile.fromFile(_selectedImage!.path),
        });
      }

      final response = await dio.post(
        "https://api.imgbb.com/1/upload",
        data: formData,
      );

      if (response.statusCode == 200) {
        String imageUrl = response.data['data']['url'];
        Navigator.of(context).pop(imageUrl); // Return the image URL
      } else {
        throw Exception("Failed to upload image");
      }
    } catch (e) {
      setState(() {
        _errorMessage = "Error uploading image: $e";
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.8 > 400 ? 400 : screenWidth * 0.8;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        width: dialogWidth.toDouble(),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Upload Profile Picture",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _webImageBytes != null
                    ? Image.memory(_webImageBytes!, fit: BoxFit.cover)
                    : _selectedImage != null
                        ? Image.file(_selectedImage!, fit: BoxFit.cover)
                        : const Center(child: Text("No image selected")),
              ),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: !_isUploading ? _pickImage : null,
                  child: const Text("Select Image"),
                ),
                ElevatedButton(
                  onPressed: !_isUploading ? _uploadImage : null,
                  child: !_isUploading
                      ? const Text("Upload")
                      : const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
