import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Money Denomination Classifier',
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
  String? _result;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future<void> loadModel() async {
    await Tflite.loadModel(
      model: "assets/final.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: source);
      if (pickedImage == null) return;
      final imageTemp = File(pickedImage.path);
      setState(() {
        _image = imageTemp;
        _result = null; // Reset the result when a new image is selected
      });
    } catch (e) {
      print('Failed to pick image: $e');
    }
  }

  void _classifyImage() async {
    if (_image != null) {
      var output = await Tflite.runModelOnImage(
        path: _image!.path,
        numResults: 1,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5,
      );
      setState(() {
        _result = output != null && output.isNotEmpty ? output[0]["label"] : "Could not recognize";
      });
    }
  }

  void _clearImage() {
    setState(() {
      _image = null;
      _result = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Money Denomination Classifier"),
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
                onPressed: _classifyImage,
                child: const Text("Classify"),
              ),
              if (_result != null) ...[
                const SizedBox(height: 20),
                Text(
                  "Classification: $_result",
                  style: TextStyle(
                    color: Colors.blue,
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
