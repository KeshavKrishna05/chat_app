import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserImagePicker extends StatefulWidget {
  UserImagePicker({
    super.key,
    required this.onpickedimage,
  });
  void Function(File pickedImage) onpickedimage;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

File? _pickedImageFile;

class _UserImagePickerState extends State<UserImagePicker> {
  void _pickimage() async {
    final pickedimage = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (pickedimage == null) {
      return;
    }
    setState(
      () {
        _pickedImageFile = File(pickedimage.path);
        widget.onpickedimage(_pickedImageFile!);
      },
    );
  }

  @override
  Widget build(context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
        ),
        TextButton.icon(
            onPressed: _pickimage,
            icon: const Icon(Icons.image),
            label: Text(
              'Add Image',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ))
      ],
    );
  }
}
