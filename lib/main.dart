import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_image == null) return;

    final imageFileLength = await _image!.length();
    if (imageFileLength > 10 * 1024 * 1024) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text('Image size should not exceed 10MB.'),
        ),
      );
      return;
    }

    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('images/${DateTime.now().millisecondsSinceEpoch}.png');
      await storageRef.putFile(_image!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.greenAccent,
          content: Text('Image uploaded successfully!',style: TextStyle(color: Colors.redAccent),),
        ),
      );
    } catch (e) {
      print('Failed to upload image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to upload image. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 56, 176, 212),
        title: const Text('Image To FireBase'),
        leading: const Icon(Icons.menu),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 10),
            child: Icon(Icons.image),
          )
        ],
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 200,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.redAccent, width: 2)),
              child: _image != null
                  ? Image.file(
                      _image!,
                      fit: BoxFit.fitHeight,
                    )
                  : const Text('Select an image ',maxLines: 2,),
            ),
            const SizedBox(
              height: 22,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder()),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.orangeAccent)),
              onPressed: _pickImage,
              child: const Text('Select Image'),
            ),
            const SizedBox(
              height: 35,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  shape: MaterialStateProperty.all(const RoundedRectangleBorder()),
                  backgroundColor:
                      MaterialStateProperty.all(Colors.greenAccent)),
              onPressed: () {
                _uploadImage();
                
              },
              child: const Text(
                'Upload Image',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
