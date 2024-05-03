import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fake Money Detection App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ImagePickerPage(),
    );
  }
}

class ImagePickerPage extends StatefulWidget {
  const ImagePickerPage({Key? key}) : super(key: key);

  @override
  _ImagePickerPageState createState() => _ImagePickerPageState();
}

class _ImagePickerPageState extends State<ImagePickerPage> {
  File? _image;
  bool? _isReal;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;
      final imageTemp = File(pickedImage.path);
      setState(() {
        _image = imageTemp;
        _isReal = null; // Reset the result when a new image is selected
      });
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void _checkImage() {
    if (_image != null) {
      // Randomly determine if the image is fake or real
      final isReal = Random().nextBool();
      setState(() {
        _isReal = isReal;
      });
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _isReal = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fake Money Detection"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image == null) ...[
              MaterialButton(
                color: Colors.blue,
                onPressed: () => _pickImage(ImageSource.gallery),
                child: const Text(
                  "Pick Image from Gallery",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              MaterialButton(
                color: Colors.blue,
                onPressed: () => _pickImage(ImageSource.camera),
                child: const Text(
                  "Pick Image from Camera",
                  style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            if (_image != null) ...[
              const SizedBox(height: 20),
              Expanded(
                child: Image.file(
                  _image!,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _checkImage,
                child: const Text("Check"),
              ),
              if (_isReal != null) ...[
                const SizedBox(height: 20),
                Text(
                  _isReal! ? "Real Money" : "Fake Money",
                  style: TextStyle(
                    color: _isReal! ? Colors.green : Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _clearImage,
                  child: const Text("Choose Another Image"),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
