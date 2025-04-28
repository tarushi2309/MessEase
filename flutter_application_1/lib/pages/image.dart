import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

class ImageUploadDialog extends StatefulWidget {
  const ImageUploadDialog({super.key});

  @override
  _ImageUploadDialogState createState() => _ImageUploadDialogState();
}

class _ImageUploadDialogState extends State<ImageUploadDialog> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _errorMessage;

  // Replace with your ImgBB API key
  final String _imgbbApiKey = "321e92bce52209a8c6c4f1271bbec58f";

  Future<void> _pickImage(ImageSource source) async {
  try {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (!mounted) return; // Prevents setState on disposed widget

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _errorMessage = null;
      });
    }
  } catch (e) {
    if (!mounted) return;
    setState(() {
      _errorMessage = "Error selecting image: $e";
    });
  }
}

  // 2) Bottom sheet to choose source
  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.of(context).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _uploadImage() async {
    if (_selectedImage == null) {
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
      final formData = FormData.fromMap({
        'key': _imgbbApiKey,
        'image': await MultipartFile.fromFile(_selectedImage!.path),
      });

      final response = await dio.post(
        "https://api.imgbb.com/1/upload",
        data: formData,
      );

      if (response.statusCode == 200) {
        String imageUrl = response.data['data']['url'];
        Navigator.of(context).pop(imageUrl); // Pass the image URL back to the caller
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
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
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
              child: _selectedImage != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : const Center(child: Text("No image selected")),
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
                  onPressed: !_isUploading ? _showImageSourceActionSheet : null,
                  child: const Text("Select Image"),
                ),
                ElevatedButton(
                  onPressed: !_isUploading ? _uploadImage : null,
                  child:
                      !_isUploading ? const Text("Upload") : const CircularProgressIndicator(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
